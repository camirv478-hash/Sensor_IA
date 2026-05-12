from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Residuo, Escaneo

from .classifier import classifier
import os

from .serializers import (
    ResiduoSerializer,
    EscaneoSerializer,
    EscaneoCreateSerializer,
    EscaneoSyncSerializer,
)


class ResiduoListView(generics.ListAPIView):
    """Listar todos los residuos del catálogo."""
    queryset = Residuo.objects.filter(activo=True)
    serializer_class = ResiduoSerializer
    permission_classes = (permissions.IsAuthenticated,)


class EscaneoCreateView(generics.CreateAPIView):
    """Registrar un nuevo escaneo con clasificación IA."""
    serializer_class = EscaneoCreateSerializer
    permission_classes = (permissions.IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)
    
    def perform_create(self, serializer):
        # Obtener imagen si se envió
        imagen = self.request.FILES.get('imagen')
        
        if imagen:
            # Guardar imagen temporalmente
            from django.core.files.storage import default_storage
            temp_path = default_storage.save(f'temp/{imagen.name}', imagen)
            temp_full_path = os.path.join(settings.MEDIA_ROOT, temp_path)
            
            try:
                # Clasificar con IA
                resultado_ia = classifier.clasificar(temp_full_path)
                
                # Buscar residuo en catálogo
                from .models import Residuo
                residuo = Residuo.objects.filter(
                    categoria=resultado_ia['categoria'],
                    activo=True
                ).first()
                
                if not residuo:
                    # Crear residuo si no existe
                    residuo = Residuo.objects.create(
                        nombre=resultado_ia['categoria_display'],
                        categoria=resultado_ia['categoria'],
                        puntos_base=resultado_ia['puntos_base'],
                    )
                
                serializer.save(
                    usuario=self.request.user,
                    residuo=residuo,
                    imagen=imagen,
                    confianza_ia=resultado_ia['confianza'],
                    puntos_obtenidos=residuo.puntos_base,
                )
                
            finally:
                # Limpiar archivo temporal
                if os.path.exists(temp_full_path):
                    os.remove(temp_full_path)
        else:
            # Sin imagen, usar el residuo enviado manualmente
            residuo_id = self.request.data.get('residuo')
            if residuo_id:
                from .models import Residuo
                try:
                    residuo = Residuo.objects.get(id=residuo_id)
                except Residuo.DoesNotExist:
                    residuo = None
                
                serializer.save(
                    usuario=self.request.user,
                    residuo=residuo,
                    puntos_obtenidos=residuo.puntos_base if residuo else 0,
                )
            else:
                serializer.save(usuario=self.request.user)

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
    """Sincronizar escaneos realizados offline."""
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
            'puntos_actuales': request.user.puntos,
            'nivel_actual': request.user.nivel,
            'escaneos': escaneos_sincronizados,
        }, status=status.HTTP_201_CREATED)


class StatsView(generics.GenericAPIView):
    """Estadísticas de reciclaje del usuario."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def get(self, request):
        user = request.user
        escaneos = Escaneo.objects.filter(usuario=user)
        
        stats = {
            'total_escaneos': escaneos.count(),
            'total_puntos': user.puntos,
            'nivel_actual': user.nivel,
            'puntos_para_siguiente_nivel': (user.nivel * 100) - user.puntos,
            'por_categoria': {},
            'escaneos_online': escaneos.filter(modo='online').count(),
            'escaneos_offline': escaneos.filter(modo='offline').count(),
            'ultimo_escaneo': None,
        }
        
        # Conteo por categoría
        for residuo in Residuo.objects.all():
            count = escaneos.filter(residuo=residuo).count()
            if count > 0:
                stats['por_categoria'][residuo.get_categoria_display()] = count
        
        # Último escaneo
        ultimo = escaneos.first()
        if ultimo:
            stats['ultimo_escaneo'] = {
                'residuo': ultimo.residuo.nombre if ultimo.residuo else 'Desconocido',
                'fecha': ultimo.created_at,
                'puntos': ultimo.puntos_obtenidos,
            }
        
        return Response(stats)