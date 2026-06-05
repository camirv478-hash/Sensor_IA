import os
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
from .classifier import classifier

# Importar el cliente de Gemini desde el módulo compartido de chatbot
from apps.chatbot.views import client as gemini_model


# ============================================================
# VISTA PARA CREAR UN NUEVO ESCANEO (CON IA LOCAL + GEMINI)
# ============================================================
class EscaneoCreateView(generics.CreateAPIView):
    """
    Registrar un nuevo escaneo con clasificación IA.
    """
    serializer_class = EscaneoCreateSerializer
    permission_classes = (permissions.IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)

    def perform_create(self, serializer):
        imagen = self.request.FILES.get('imagen')

        if imagen:
            temp_path = default_storage.save(f'temp/{imagen.name}', imagen)
            temp_full_path = os.path.join(settings.MEDIA_ROOT, temp_path)

            try:
                # -------------------------------------------------
                # 1. IA LOCAL - clasificar el residuo
                # -------------------------------------------------
                resultado_ia = classifier.clasificar(temp_full_path)

                categoria = resultado_ia['categoria']
                categoria_display = resultado_ia['categoria_display']
                confianza = resultado_ia['confianza']
                puntos_base = resultado_ia['puntos_base']

                residuo = Residuo.objects.filter(
                    categoria=categoria,
                    activo=True
                ).first()

                if not residuo:
                    residuo = Residuo.objects.create(
                        nombre=categoria_display,
                        categoria=categoria,
                        puntos_base=puntos_base,
                    )

                # -------------------------------------------------
                # 2. GEMINI ONLINE – consejo ecológico + caneca
                # -------------------------------------------------
                modo = 'offline'
                analisis_ia = ""

                if gemini_model:
                    try:
                        prompt = f"""Eres EcoBot de SensorIA, un asistente de reciclaje.
El usuario acaba de clasificar un residuo como: {categoria_display}.
Responde EXACTAMENTE en el siguiente formato, sin saludos ni despedidas:

CONSEJO: [Un breve consejo ecológico sobre cómo reciclar este residuo]
CANECA: [Nombre del color de la caneca donde debe depositarlo según SensorIA: Caneca Blanca, Caneca Verde, Caneca Gris, Caneca Azul o Caneca Marrón]

Ejemplo para Plástico:
CONSEJO: El plástico tarda cientos de años en degradarse. ¡Recíclalo siempre!
CANECA: Caneca Blanca"""

                        response = gemini_model.models.generate_content(
                            model="gemini-2.0-flash-lite",
                            contents=prompt
                        )
                        if response.text:
                            analisis_ia = response.text.strip()
                            modo = 'online'
                    except Exception as e:
                        print(f"Gemini offline: {e}")

                # -------------------------------------------------
                # 3. Guardar el escaneo
                # -------------------------------------------------
                serializer.save(
                    usuario=self.request.user,
                    residuo=residuo,
                    imagen=imagen,
                    confianza_ia=confianza,
                    puntos_obtenidos=residuo.puntos_base,
                    modo=modo,
                )

                self._extra_response = {
                    'escaneo_id': serializer.instance.id,
                    'categoria': categoria_display,
                    'confianza': confianza,
                    'puntos': residuo.puntos_base,
                    'modo': modo,
                    'analisis_ia': analisis_ia,
                }

            finally:
                if os.path.exists(temp_full_path):
                    os.remove(temp_full_path)

        else:
            serializer.save(usuario=self.request.user)
            self._extra_response = {}

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)

        response_data = self._extra_response if hasattr(self, '_extra_response') else {}
        return Response(response_data, status=status.HTTP_201_CREATED)


# ============================================================
# RESTO DE VISTAS (sin cambios)
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
    """
    Estadísticas globales para panel admin web.
    """
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