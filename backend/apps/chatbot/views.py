from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Conversacion, Mensaje, TipReciclaje
from .serializers import (
    ConversacionSerializer, ConversacionCreateSerializer,
    MensajeSerializer, MensajeCreateSerializer, TipReciclajeSerializer
)
import random


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
        """Simulación simple del chatbot con respuestas ecológicas."""
        mensaje_lower = mensaje.lower()
        
        # Respuestas predefinidas
        if any(p in mensaje_lower for p in ['hola', 'buenas', 'hey', 'saludos']):
            return random.choice([
                f"¡Hola {usuario.first_name or 'EcoGuardián'}! 🌱 ¿En qué puedo ayudarte con el reciclaje hoy?",
                f"¡Saludos {usuario.first_name or 'reciclador'}! 🌍 ¿Listo para salvar el planeta?",
            ])
        
        if 'plástico' in mensaje_lower or 'plastico' in mensaje_lower:
            return "El plástico tarda entre 100 y 1000 años en degradarse. ¡Reciclar una botella ahorra suficiente energía para mantener encendida una bombilla por 6 horas! ♻️🔋"
        
        if 'vidrio' in mensaje_lower:
            return "¡El vidrio es 100% reciclable infinitamente! Una botella de vidrio reciclada ahorra un 30% de energía. 🫙✨"
        
        if 'papel' in mensaje_lower or 'cartón' in mensaje_lower or 'carton' in mensaje_lower:
            return "Reciclar una tonelada de papel salva 17 árboles. ¡Sigue así! 📄🌳"
        
        if 'metal' in mensaje_lower or 'lata' in mensaje_lower or 'aluminio' in mensaje_lower:
            return "Reciclar una lata de aluminio ahorra el 95% de la energía necesaria para hacer una nueva. ⚡🥫"
        
        if 'orgánico' in mensaje_lower or 'organico' in mensaje_lower:
            return "Los residuos orgánicos pueden convertirse en compost. ¡Un excelente fertilizante natural! 🌱🪱"
        
        if any(p in mensaje_lower for p in ['punto', 'puntos', 'nivel', 'ranking']):
            return f"Tienes {usuario.puntos} puntos y eres nivel {usuario.nivel}. ¡Sigue reciclando para subir! 📊🏆"
        
        if 'tip' in mensaje_lower or 'consejo' in mensaje_lower:
            tips = TipReciclaje.objects.filter(activo=True)
            if tips.exists():
                tip = random.choice(tips)
                return f"💡 {tip.titulo}:\n{tip.contenido}"
        
        # Respuesta por defecto
        return random.choice([
            "¡Excelente pregunta! Sigue reciclando y acumulando puntos. ¿Necesitas tips sobre algún material específico? 🌱",
            "Como tu EcoBot, te recomiendo separar siempre los residuos. ¿Quieres saber más sobre algún material? ♻️",
            "¡Cada reciclaje cuenta! Has ganado puntos por tus acciones. ¿En qué más puedo ayudarte? 🌍",
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