import os
import random
from google import genai
from dotenv import load_dotenv
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Conversacion, Mensaje, TipReciclaje
from .serializers import (
    ConversacionSerializer, ConversacionCreateSerializer,
    MensajeSerializer, MensajeCreateSerializer, TipReciclajeSerializer
)

# Cargar variables de entorno
load_dotenv()

# Configurar Gemini
GEMINI_API_KEY = "AIzaSyAwicxrECx_zmnRvyqJjWu-AmZDfZi74FY"
if GEMINI_API_KEY:
    client = genai.Client(api_key="AIzaSyAwicxrECx_zmnRvyqJjWu-AmZDfZi74FY")
    gemini_model = client
    print("✅ Gemini API configurado correctamente")
else:
    gemini_model = None
    print("⚠️ Gemini API Key no encontrada. Usando respuestas simuladas.")


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
    """Enviar mensaje al chatbot y recibir respuesta."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def post(self, request):
        serializer = MensajeCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        mensaje_usuario = serializer.validated_data['mensaje']
        conversacion_id = serializer.validated_data.get('conversacion_id')
        
        # Crear o recuperar conversación
        if conversacion_id:
            try:
                conversacion = Conversacion.objects.get(
                    id=conversacion_id,
                    usuario=request.user
                )
            except Conversacion.DoesNotExist:
                return Response({"error": "Conversación no encontrada"}, status=404)
        else:
            conversacion = Conversacion.objects.create(
                usuario=request.user,
                titulo=mensaje_usuario[:50] + "..."
            )
        
        # Guardar mensaje del usuario
        mensaje_user = Mensaje.objects.create(
            conversacion=conversacion,
            rol='user',
            contenido=mensaje_usuario
        )
        
        # Generar respuesta del bot
        respuesta_bot = self._generar_respuesta(mensaje_usuario, request.user)
        
        mensaje_bot = Mensaje.objects.create(
            conversacion=conversacion,
            rol='bot',
            contenido=respuesta_bot
        )
        
        return Response({
            'conversacion_id': conversacion.id,
            'mensaje_usuario': MensajeSerializer(mensaje_user).data,
            'mensaje_bot': MensajeSerializer(mensaje_bot).data,
        })
    
    def _generar_respuesta(self, mensaje, usuario):
        """Respuesta con Gemini AI o fallback simulado."""
        
        # Intentar con Gemini
        if gemini_model:
            try:
                prompt = f"""Eres EcoBot, un asistente experto en reciclaje y medio ambiente de la app SensorIA.
                
Usuario: {usuario.first_name or 'EcoGuardián'}
Nivel: {usuario.nivel}
Puntos: {usuario.puntos}

Pregunta: {mensaje}

Responde de forma amigable, corta (máximo 3 oraciones) y útil. Usa emojis ecológicos.
Si te preguntan por puntos o nivel del usuario, usa los datos proporcionados arriba.
Responde en español."""

                response = gemini_model.models.generate_content(
                    model='gemini-2.0-flash-lite',
                    contents=prompt
                )
                return response.text.strip()
            except Exception as e:
                print(f"Error con Gemini: {e}")
        
        # Fallback simulado
        mensaje_lower = mensaje.lower()
        
        if any(p in mensaje_lower for p in ['hola', 'buenas', 'hey', 'saludos']):
            return f"¡Hola {usuario.first_name or 'EcoGuardián'}! 🌱 ¿En qué puedo ayudarte con el reciclaje hoy?"
        
        if 'punto' in mensaje_lower or 'nivel' in mensaje_lower:
            return f"Tienes {usuario.puntos} puntos y eres nivel {usuario.nivel}. ¡Sigue reciclando para subir! ⭐"
        
        return random.choice([
            "¡Excelente pregunta! Sigue reciclando y acumulando puntos. ¿Necesitas tips? 🌱",
            "Cada reciclaje cuenta. ¿Quieres saber sobre algún material específico? ♻️",
            "¡Hola! Como tu EcoBot, te recomiendo separar siempre los residuos. 🌍",
        ])


class TipsListView(generics.ListAPIView):
    """Listar tips de reciclaje."""
    queryset = TipReciclaje.objects.filter(activo=True)
    serializer_class = TipReciclajeSerializer
    permission_classes = (permissions.IsAuthenticated,)


class TipRandomView(APIView):
    """Obtener un tip aleatorio."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def get(self, request):
        categoria = request.query_params.get('categoria')
        tips = TipReciclaje.objects.filter(activo=True)
        if categoria:
            tips = tips.filter(categoria=categoria)
        
        if tips.exists():
            tip = random.choice(tips)
            return Response(TipReciclajeSerializer(tip).data)
        return Response({"mensaje": "No hay tips disponibles"}, status=404)