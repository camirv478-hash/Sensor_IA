from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Recompensa, Canje
from .serializers import RecompensaSerializer, CanjeSerializer, CanjeCreateSerializer


class RecompensaListView(generics.ListAPIView):
    """Listar todas las recompensas disponibles."""
    queryset = Recompensa.objects.filter(activo=True)
    serializer_class = RecompensaSerializer
    permission_classes = (permissions.IsAuthenticated,)


class RecompensaDetailView(generics.RetrieveAPIView):
    """Ver detalle de una recompensa."""
    queryset = Recompensa.objects.filter(activo=True)
    serializer_class = RecompensaSerializer
    permission_classes = (permissions.IsAuthenticated,)


class CanjearRecompensaView(APIView):
    """Canjear una recompensa con puntos."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def post(self, request):
        serializer = CanjeCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            recompensa = Recompensa.objects.get(
                id=serializer.validated_data['recompensa_id'],
                activo=True
            )
        except Recompensa.DoesNotExist:
            return Response(
                {"error": "Recompensa no encontrada"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Verificar stock
        if recompensa.stock == 0:
            # Stock 0 = ilimitado, no se verifica
            pass
        elif recompensa.stock == 0 and recompensa.stock != 0:
            return Response(
                {"error": "Recompensa agotada"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Verificar puntos
        if request.user.puntos < recompensa.costo_puntos:
            return Response({
                "error": "Puntos insuficientes",
                "tus_puntos": request.user.puntos,
                "costo": recompensa.costo_puntos,
                "faltan": recompensa.costo_puntos - request.user.puntos
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Crear canje
        canje = Canje.objects.create(
            usuario=request.user,
            recompensa=recompensa
        )
        
        return Response({
            "mensaje": "¡Recompensa canjeada exitosamente!",
            "canje": CanjeSerializer(canje).data,
            "puntos_restantes": request.user.puntos,
        }, status=status.HTTP_201_CREATED)


class HistorialCanjesView(generics.ListAPIView):
    """Historial de canjes del usuario."""
    serializer_class = CanjeSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def get_queryset(self):
        return Canje.objects.filter(usuario=self.request.user)


class DestacadosView(generics.ListAPIView):
    """Recompensas destacadas."""
    queryset = Recompensa.objects.filter(activo=True, destacado=True)
    serializer_class = RecompensaSerializer
    permission_classes = (permissions.IsAuthenticated,)