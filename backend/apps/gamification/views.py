from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils import timezone
from django.db.models import Count, Sum, Q
from django.contrib.auth import get_user_model

from .models import (
    Desafio, MisionDiaria, ProgresoDesafio,
    ProgresoMision, Logro, LogroUsuario
)
from .serializers import (
    DesafioSerializer, ProgresoDesafioSerializer,
    MisionDiariaSerializer, ProgresoMisionSerializer,
    LogroSerializer, LogroUsuarioSerializer, LeaderboardSerializer
)

User = get_user_model()


# ============================================
# DESAFÍOS
# ============================================

class DesafioListView(generics.ListAPIView):
    """Listar desafíos activos."""
    serializer_class = DesafioSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def get_queryset(self):
        return Desafio.objects.filter(activo=True, fecha_fin__gte=timezone.now())


class UnirseDesafioView(APIView):
    """Unirse a un desafío."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def post(self, request, desafio_id):
        try:
            desafio = Desafio.objects.get(id=desafio_id, activo=True)
        except Desafio.DoesNotExist:
            return Response({"error": "Desafío no encontrado"}, status=404)
        
        progreso, created = ProgresoDesafio.objects.get_or_create(
            usuario=request.user,
            desafio=desafio
        )
        
        return Response({
            "mensaje": "Te has unido al desafío",
            "progreso": ProgresoDesafioSerializer(progreso).data
        })


class MisDesafiosView(generics.ListAPIView):
    """Ver mis desafíos activos."""
    serializer_class = ProgresoDesafioSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def get_queryset(self):
        return ProgresoDesafio.objects.filter(
            usuario=self.request.user,
            desafio__activo=True
        )


# ============================================
# MISIONES DIARIAS
# ============================================

class MisionDiariaListView(generics.ListAPIView):
    """Listar misiones del día."""
    serializer_class = MisionDiariaSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def get_queryset(self):
        hoy = timezone.now().date()
        return MisionDiaria.objects.filter(fecha=hoy, activo=True)


class MiMisionDiariaView(generics.ListAPIView):
    """Ver progreso de mis misiones de hoy."""
    serializer_class = ProgresoMisionSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def get_queryset(self):
        hoy = timezone.now().date()
        # Crear progreso automáticamente si no existe
        misiones = MisionDiaria.objects.filter(fecha=hoy, activo=True)
        for mision in misiones:
            ProgresoMision.objects.get_or_create(
                usuario=self.request.user,
                mision=mision
            )
        
        return ProgresoMision.objects.filter(
            usuario=self.request.user,
            mision__fecha=hoy
        )


# ============================================
# LOGROS
# ============================================

class LogroListView(generics.ListAPIView):
    """Listar todos los logros disponibles."""
    queryset = Logro.objects.all()
    serializer_class = LogroSerializer
    permission_classes = (permissions.IsAuthenticated,)


class MisLogrosView(generics.ListAPIView):
    """Ver mis logros desbloqueados."""
    serializer_class = LogroUsuarioSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def get_queryset(self):
        return LogroUsuario.objects.filter(usuario=self.request.user)


# ============================================
# LEADERBOARD
# ============================================

class LeaderboardView(APIView):
    """Ranking de usuarios por puntos."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def get(self, request):
        periodo = request.query_params.get('periodo', 'general')  # general, semanal, mensual
        
        usuarios = User.objects.annotate(
            total_escaneos=Count('escaneos')
        ).order_by('-puntos')[:50]
        
        ranking = []
        for i, user in enumerate(usuarios, 1):
            ranking.append({
                'posicion': i,
                'username': user.username,
                'nivel': user.nivel,
                'puntos': user.puntos,
                'total_escaneos': user.total_escaneos,
            })
        
        # Posición del usuario actual
        mi_posicion = next((r for r in ranking if r['username'] == request.user.username), None)
        
        return Response({
            'ranking': ranking,
            'mi_posicion': mi_posicion,
        })