import os
import random
import time
from pathlib import Path
from dotenv import load_dotenv

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

# --- Firebase ---
from .firebase_utils import FirebaseAuthentication

# --- Gemini ---
from google import genai

# --- Modelos y serializadores locales ---
from .models import Conversacion, Mensaje, TipReciclaje
from .serializers import (
    ConversacionSerializer,
    ConversacionCreateSerializer,
    MensajeSerializer,
    MensajeCreateSerializer,
    TipReciclajeSerializer
)

# ==============================================================
# CARGAR VARIABLES DE ENTORNO
# ==============================================================

BASE_DIR = Path(__file__).resolve().parent.parent.parent
load_dotenv(BASE_DIR / ".env")

# ==============================================================
# CONFIGURAR GEMINI
# ==============================================================

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if GEMINI_API_KEY:
    try:
        client = genai.Client(api_key=GEMINI_API_KEY)
        print("✅ Gemini API configurado correctamente")
    except Exception as e:
        client = None
        print(f"❌ Error configurando Gemini: {e}")
else:
    client = None
    print("⚠️ Gemini API Key no encontrada. Usando respuestas simuladas.")

# ==============================================================
# VISTAS
# ==============================================================

class ConversacionListView(generics.ListAPIView):
    """Listar conversaciones del usuario."""

    serializer_class = ConversacionSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Conversacion.objects.filter(usuario=self.request.user)


class ConversacionCreateView(generics.CreateAPIView):
    """Crear nueva conversación."""

    serializer_class = ConversacionCreateSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)


class MensajeCreateView(APIView):
    """
    Enviar mensaje al chatbot.
    Compatible con JWT y Firebase Authentication.
    """

    authentication_classes = [FirebaseAuthentication] + APIView.authentication_classes
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):

        serializer = MensajeCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        mensaje_usuario = serializer.validated_data['mensaje']
        conversacion_id = serializer.validated_data.get('conversacion_id')

        # ==========================================================
        # CREAR O RECUPERAR CONVERSACIÓN
        # ==========================================================

        if conversacion_id:
            try:
                conversacion = Conversacion.objects.get(
                    id=conversacion_id,
                    usuario=request.user
                )
            except Conversacion.DoesNotExist:
                return Response(
                    {"error": "Conversación no encontrada"},
                    status=404
                )

        else:
            conversacion = Conversacion.objects.create(
                usuario=request.user,
                titulo=mensaje_usuario[:50] + "..."
            )

        # ==========================================================
        # GUARDAR MENSAJE DEL USUARIO
        # ==========================================================

        mensaje_user = Mensaje.objects.create(
            conversacion=conversacion,
            rol='user',
            contenido=mensaje_usuario
        )

        # ==========================================================
        # GENERAR RESPUESTA DEL BOT
        # ==========================================================

        respuesta_bot = self._generar_respuesta(
            mensaje_usuario,
            request.user
        )

        # ==========================================================
        # GUARDAR RESPUESTA DEL BOT
        # ==========================================================

        mensaje_bot = Mensaje.objects.create(
            conversacion=conversacion,
            rol='bot',
            contenido=respuesta_bot
        )

        # ==========================================================
        # RESPUESTA FINAL
        # ==========================================================

        return Response({
            'conversacion_id': conversacion.id,
            'mensaje_usuario': MensajeSerializer(mensaje_user).data,
            'mensaje_bot': MensajeSerializer(mensaje_bot).data,
        })

    # ==============================================================
    # MÉTODO PRINCIPAL DEL CHATBOT
    # ==============================================================

    def _generar_respuesta(self, mensaje, usuario):

        if client:

            prompt = f"""
Eres EcoBot, un asistente experto en reciclaje y medio ambiente de la app SensorIA.

Información del usuario:
- Nombre: {usuario.first_name or 'EcoGuardián'}
- Nivel: {getattr(usuario, 'nivel', 1)}
- Puntos: {getattr(usuario, 'puntos', 0)}

Pregunta del usuario:
{mensaje}

Instrucciones de formato CRÍTICAS:
1. Responde en español de forma amigable, útil y usando emojis ecológicos.
2. Usa máximo 3 oraciones para tu explicación general.
3. SIEMPRE debes incluir una última línea independiente al final de tu respuesta que indique el color de caneca correspondiente para el residuo mencionado en la pregunta.
4. El formato de la última línea debe ser estrictamente: "CANECA: COLOR" (en mayúsculas). 
   - Usa BLANCA si son residuos aprovechables limpios y secos (plástico, vidrio, cartón, papel, metales).
   - Usa VERDE si son residuos orgánicos aprovechables (restos de comida, desechos agrícolas).
   - Usa NEGRA o GRIS si son residuos no aprovechables o especiales.
   - Usa AZUL si son plásticos de un solo uso o envases clásicos.

Ejemplo de salida esperada:
¡Claro que sí! Las botellas de plástico deben estar limpias y secas antes de clasificarlas. Esto ayuda a que el proceso de reciclaje sea mucho más eficiente. 🌱
CANECA: BLANCA
"""

            max_retries = 2

            for intento in range(max_retries):

                try:

                    print("📡 Enviando petición a Gemini...")

                    response = client.models.generate_content(
                        model='gemini-2.5-flash-lite',
                        contents=prompt
                    )

                    print("✅ Respuesta recibida de Gemini")

                    if response.text:
                        return response.text.strip()

                    return "♻️ No pude generar una respuesta en este momento.\nCANECA: GRIS"

                except Exception as e:

                    print("\n========== ERROR GEMINI ==========")
                    print(type(e))
                    print(str(e))
                    print("==================================\n")

                    if '429' in str(e) and intento < max_retries - 1:

                        print(
                            f"⏳ Límite alcanzado. "
                            f"Reintentando en 15 segundos... "
                            f"(Intento {intento + 1})"
                        )

                        time.sleep(15)

                    else:
                        break

        # ==========================================================
        # FALLBACK: TIPS ECOLÓGICOS (Con Caneca Inyectada por Defecto)
        # ==============================================================

        tips = TipReciclaje.objects.filter(activo=True)

        if tips.exists():

            tip = random.choice(tips)

            return f"""
💡 {tip.titulo}

{tip.contenido}
CANECA: GRIS
"""

        # ==========================================================
        # FALLBACK FINAL
        # ==============================================================

        return random.choice([
            "🌍 ¡Cada acción cuenta para salvar el planeta!\nCANECA: GRIS",
            "♻️ Reciclar hoy es cuidar el mañana.\nCANECA: BLANCA",
            "💚 Reduce, reutiliza y recicla.\nCANECA: GRIS",
            "🌱 Ayuda al planeta separando correctamente tus residuos.\nCANECA: VERDE",
        ])


# ==============================================================
# LISTAR TIPS
# ==============================================================

class TipsListView(generics.ListAPIView):

    queryset = TipReciclaje.objects.filter(activo=True)
    serializer_class = TipReciclajeSerializer
    permission_classes = (permissions.IsAuthenticated,)


# ==============================================================
# TIP ALEATORIO
# ==============================================================

class TipRandomView(APIView):

    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):

        categoria = request.query_params.get('categoria')

        tips = TipReciclaje.objects.filter(activo=True)

        if categoria:
            tips = tips.filter(categoria=categoria)

        if tips.exists():

            tip = random.choice(tips)
            return Response(TipReciclajeSerializer(tip).data)
        return Response({"mensaje": "No hay tips disponibles"}, status=status.HTTP_404_NOT_FOUND)