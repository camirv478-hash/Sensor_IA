from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Bin, BinScan
from .serializers import (
    BinSerializer, BinCreateSerializer,
    BinStatusSerializer, BinScanSerializer
)


class BinListView(generics.ListAPIView):
    """Listar todas las canecas."""
    queryset = Bin.objects.all()
    serializer_class = BinSerializer
    permission_classes = (permissions.IsAuthenticated,)


class BinCreateView(generics.CreateAPIView):
    """Crear nueva caneca (solo admin)."""
    serializer_class = BinCreateSerializer
    permission_classes = (permissions.IsAuthenticated,)
    
    def perform_create(self, serializer):
        serializer.save()


class BinDetailView(generics.RetrieveAPIView):
    """Ver detalle de una caneca por QR."""
    queryset = Bin.objects.all()
    serializer_class = BinSerializer
    permission_classes = (permissions.IsAuthenticated,)
    lookup_field = 'qr_code'


class BinUpdateStatusView(APIView):
    """Actualizar nivel de llenado y estado."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def post(self, request):
        serializer = BinStatusSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Buscar caneca por QR o ID
        qr_code = request.data.get('qr_code')
        bin_id = request.data.get('bin_id')
        
        if qr_code:
            bin_obj = Bin.objects.get(qr_code=qr_code)
        elif bin_id:
            bin_obj = Bin.objects.get(id=bin_id)
        else:
            bin_obj = Bin.objects.first()
        
        bin_obj.fill_level = serializer.validated_data.get('fill_level', bin_obj.fill_level)
        bin_obj.is_active = serializer.validated_data.get('is_active', bin_obj.is_active)
        bin_obj.save()
        
        return Response(BinSerializer(bin_obj).data)


class BinScanView(APIView):
    """Registrar escaneo QR de caneca."""
    permission_classes = (permissions.IsAuthenticated,)
    
    def post(self, request):
        qr_code = request.data.get('qr_code')
        
        try:
            bin_obj = Bin.objects.get(qr_code=qr_code)
        except Bin.DoesNotExist:
            return Response({"error": "Caneca no encontrada"}, status=404)
        
        scan = BinScan.objects.create(
            bin=bin_obj,
            scanned_by=request.user,
            qr_code=qr_code
        )
        
        return Response({
            "mensaje": "Escaneo registrado",
            "caneca": BinSerializer(bin_obj).data,
            "escaneo": BinScanSerializer(scan).data,
        })