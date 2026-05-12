from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from .serializers import RegisterSerializer, UserProfileSerializer

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    """Registro público de nuevos usuarios."""
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer


class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Perfil del usuario autenticado.
    GET: ver perfil
    PUT/PATCH: editar perfil
    """
    serializer_class = UserProfileSerializer
    permission_classes = (permissions.IsAuthenticated,)

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