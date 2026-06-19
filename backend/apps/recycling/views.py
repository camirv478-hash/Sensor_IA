import os
import json
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.conf import settings
from django.core.files.storage import default_storage

from .models import Residuo, Escaneo
from .serializers import (
    ResiduoSerializer,
    EscaneoSerializer,
    EscaneoCreateSerializer,
    EscaneoSyncSerializer,
)
# Usamos directamente nuestra instancia unificada del clasificador inteligente
from .classifier import classifier


# ============================================================
# VISTA PARA CREAR UN NUEVO ESCANEO (CON IA LOCAL + GEMINI)
# ============================================================
class EscaneoCreateView(generics.CreateAPIView):
    """
    Registrar un nuevo escaneo con clasificación IA.
    Modo 'auto' u 'online': usa Gemini Vision y conmuta a TensorFlow local por cuota/fallos.
    Modo 'offline': fuerza el uso de TensorFlow local.
    """
    serializer_class = EscaneoCreateSerializer
    permission_classes = (permissions.IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)

    def perform_create(self, serializer):
        imagen = self.request.FILES.get('imagen')
        modo_solicitado = self.request.data.get('modo', 'online')  # 'online', 'offline' o 'auto'

        if not imagen:
            serializer.save(usuario=self.request.user)
            self._extra_response = {}
            return

        # Guardar archivo temporal de manera segura
        temp_path = default_storage.save(f'temp/{imagen.name}', imagen)
        temp_full_path = os.path.join(settings.MEDIA_ROOT, temp_path)

        try:
            # -----------------------------------------------------------------
            # Delegamos toda la lógica de conmutación inteligente al clasificador
            # -----------------------------------------------------------------
            resultado = classifier.clasificar(
                imagen_path=temp_full_path, 
                modo=modo_solicitado, 
                umbral_confianza=60
            )

            # Control de respuestas de error o baja confianza controladas por el clasificador
            if 'error' in resultado and resultado['categoria'] == 'error':
                self._extra_response = {
                    'error': 'tecnico',
                    'mensaje': resultado.get('error', 'Error técnico en la clasificación.'),
                }
                return

            if resultado.get('categoria') == 'baja_confianza':
                self._extra_response = {
                    'error': 'baja_confianza',
                    'mensaje': resultado.get('descripcion', 'No se pudo identificar con certeza.'),
                    'confianza': resultado.get('confianza', 0),
                }
                return

            if resultado.get('categoria') == 'no_residuo':
                self._extra_response = {
                    'error': 'no_residuo',
                    'mensaje': resultado.get('descripcion', 'La imagen no contiene un residuo válido.'),
                }
                return

            # -------------------------------------------------
            # Crear o recuperar el residuo en la base de datos
            # -------------------------------------------------
            residuo, _ = Residuo.objects.get_or_create(
                categoria=resultado['categoria'],
                defaults={
                    'nombre': resultado['categoria_display'],
                    'puntos_base': resultado['puntos_base'],
                    'activo': True,
                }
            )

            # Obtener el modo real final utilizado por el motor (online_gemini, offline_tensorflow, etc.)
            metodo_final = resultado.get('metodo', 'desconocido')
            modo_db = 'online' if 'online' in metodo_final else 'offline'

            # -------------------------------------------------
            # Guardar el registro del escaneo en la Base de Datos
            # -------------------------------------------------
            serializer.save(
                usuario=self.request.user,
                residuo=residuo,
                imagen=imagen,
                confianza_ia=resultado['confianza'],
                puntos_obtenidos=residuo.puntos_base,
                modo=modo_db,
            )

            # Respuesta mapeada con éxito para el frontend móvil de SensorIA
            self._extra_response = {
                'escaneo_id': serializer.instance.id,
                'categoria': resultado['categoria_display'],
                'confianza': resultado['confianza'],
                'puntos': residuo.puntos_base,
                'modo': modo_db,
                'analisis_ia': f"Motor: {metodo_final}",
                'caneca': resultado['caneca'],
                'color_caneca': resultado['color_caneca'],
                'descripcion': resultado.get('descripcion', ''),
            }

        except Exception as e:
            print(f"Error crítico en controlador de escaneo: {e}")
            self._extra_response = {
                'error': 'excepcion',
                'mensaje': str(e)
            }
        finally:
            # Garantizar la eliminación del archivo temporal del almacenamiento local
            if os.path.exists(temp_full_path):
                os.remove(temp_full_path)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        response_data = getattr(self, '_extra_response', {})
        
        if 'error' in response_data:
            return Response(response_data, status=status.HTTP_400_BAD_REQUEST)
            
        return Response(response_data, status=status.HTTP_201_CREATED)


# ============================================================
# RESTO DE VISTAS (Catálogo, Historial, Sincronización y Estadísticas)
# ============================================================
class ResiduoListView(generics.ListAPIView):
    """Listar todos los residuos del catálogo."""
    queryset = Residuo.objects.filter(activo=True)
    serializer_class = ResiduoSerializer
    permission_classes = (permissions.IsAuthenticated,)


class EscaneoHistoryView(generics.ListAPIView):
    """Historial de escaneos del usuario autenticado."""
    serializer_class = EscaneoSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Escaneo.objects.filter(usuario=self.request.user)


class EscaneoDetailView(generics.RetrieveAPIView):
    """Ver detalle de un escaneo específico."""
    serializer_class = EscaneoSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Escaneo.objects.filter(usuario=self.request.user)


class EscaneoSyncView(generics.GenericAPIView):
    """Sincronizar escaneos realizados offline desde el dispositivo móvil."""
    serializer_class = EscaneoSyncSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        escaneos_sincronizados = []
        puntos_totales = 0

        for escaneo_data in serializer.validated_data['escaneos']:
            residuo_id = escaneo_data.get('residuo_id')
            try:
                residuo = Residuo.objects.get(id=residuo_id, activo=True)
            except Residuo.DoesNotExist:
                continue

            escaneo = Escaneo.objects.create(
                usuario=request.user,
                residuo=residuo,
                modo='offline',
                confianza_ia=escaneo_data.get('confianza_ia'),
                sincronizado=True,
                latitud=escaneo_data.get('latitud'),
                longitud=escaneo_data.get('longitud'),
            )
            escaneos_sincronizados.append(EscaneoSerializer(escaneo).data)
            puntos_totales += escaneo.puntos_obtenidos

        return Response({
            'mensaje': f'Sincronizados {len(escaneos_sincronizados)} escaneos',
            'puntos_totales': puntos_totales,
            'puntos_actuales': getattr(request.user, 'points', 0),  
            'nivel_actual': getattr(request.user, 'level', 1),     
            'escaneos': escaneos_sincronizados,
        }, status=status.HTTP_201_CREATED)


class StatsView(generics.GenericAPIView):
    """Estadísticas globales para el panel de administración web."""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        total_escaneos = Escaneo.objects.count()
        total_residuos = Residuo.objects.count()

        stats = {
            'total_escaneos': total_escaneos,
            'total_residuos': total_residuos,
            'escaneos_online': Escaneo.objects.filter(modo='online').count(),
            'escaneos_offline': Escaneo.objects.filter(modo='offline').count(),
        }
        
        return Response(stats)