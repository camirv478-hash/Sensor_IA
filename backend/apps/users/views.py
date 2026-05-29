from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from .serializers import RegisterSerializer, UserProfileSerializer

from rest_framework.parsers import MultiPartParser, FormParser

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    """Registro público de nuevos usuarios."""
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer


class UserListView(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = (permissions.IsAdminUser,)

class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Perfil del usuario autenticado.
    GET: ver perfil
    PUT/PATCH: editar perfil
    """
    serializer_class = UserProfileSerializer
    permission_classes = (permissions.IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)  # Para subir imágenes

    def get_object(self):
        return self.request.user


class UserPointsView(APIView):
    """Consultar puntos y nivel del usuario autenticado."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        user = request.user
        return Response({
            'username': user.username,
            'puntos': user.puntos,
            'nivel': user.nivel,
            'puntos_para_siguiente_nivel': (user.nivel * 100) - user.puntos,
        })

class PasswordResetView(APIView):
    """Solicitar recuperación de contraseña."""
    permission_classes = (permissions.AllowAny,)
    
    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({"error": "Email requerido"}, status=400)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"error": "Usuario no encontrado"}, status=404)
        
        # Generar código de 6 dígitos
        import random
        codigo = str(random.randint(100000, 999999))
        
        # Guardar en sesión o caché (simplificado: guardar en DB)
        user.set_password(codigo)  # Temporal
        user.save()
        
        # En producción: enviar email
        print(f"🔑 Código para {email}: {codigo}")
        
        return Response({
            "mensaje": "Código enviado a tu correo (revisa la consola del servidor)",
            "codigo": codigo,  # Solo desarrollo, quitar en producción
        })


class PasswordResetConfirmView(APIView):
    """Confirmar código y cambiar contraseña."""
    permission_classes = (permissions.AllowAny,)
    
    def post(self, request):
        email = request.data.get('email')
        codigo = request.data.get('codigo')
        new_password = request.data.get('new_password')
        
        if not all([email, codigo, new_password]):
            return Response({"error": "Todos los campos son requeridos"}, status=400)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"error": "Usuario no encontrado"}, status=404)
        
        # Verificar código
        import hashlib
        temp_hash = hashlib.sha256(codigo.encode()).hexdigest()
        
        # Simplificado: comparar directamente (producción usa tokens)
        if user.check_password(codigo):
            user.set_password(new_password)
            user.save()
            return Response({"mensaje": "Contraseña actualizada correctamente"})
        
        return Response({"error": "Código inválido"}, status=400)