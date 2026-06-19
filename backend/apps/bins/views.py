from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.http import JsonResponse
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Bin, BinScan
from .serializers import (
    BinSerializer, BinCreateSerializer,
    BinStatusSerializer, BinScanSerializer
)

# ============================================================
# PERMISOS PERSONALIZADOS
# ============================================================
class IsAdminUser(permissions.BasePermission):
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return getattr(request.user, 'rol', None) == 'admin' or request.user.is_superuser


# ============================================================
# VISTAS API (para la aplicación móvil)
# ============================================================
class BinListView(generics.ListAPIView):
    """Listar todas las canecas (usuarios autenticados)."""
    queryset = Bin.objects.all()
    serializer_class = BinSerializer
    permission_classes = (permissions.IsAuthenticated,)


class BinMapView(BinListView):
    """Listar canecas para el mapa en la app móvil."""
    pass


class BinCreateView(generics.CreateAPIView):
    """Crear caneca vía API (solo administradores)."""
    serializer_class = BinCreateSerializer
    permission_classes = (IsAdminUser,)

    def perform_create(self, serializer):
        serializer.save()


class BinDetailView(generics.RetrieveAPIView):
    """Ver detalle de una caneca por QR (código)."""
    queryset = Bin.objects.all()
    serializer_class = BinSerializer
    permission_classes = (permissions.IsAuthenticated,)
    lookup_field = 'qr_code'


class BinUpdateStatusView(APIView):
    """Actualizar nivel de llenado y estado (vía API)."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        serializer = BinStatusSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        qr_code = request.data.get('qr_code')
        bin_id = request.data.get('bin_id')

        if qr_code:
            bin_obj = get_object_or_404(Bin, qr_code=qr_code)
        elif bin_id:
            bin_obj = get_object_or_404(Bin, id=bin_id)
        else:
            bin_obj = Bin.objects.first()
            if not bin_obj:
                return Response({"error": "No hay canecas registradas"}, status=404)

        bin_obj.fill_level = serializer.validated_data.get('fill_level', bin_obj.fill_level)
        bin_obj.is_active = serializer.validated_data.get('is_active', bin_obj.is_active)
        bin_obj.save()

        return Response(BinSerializer(bin_obj).data)


class BinScanView(APIView):
    """Registrar escaneo QR de una caneca (vía API)."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        qr_code = request.data.get('qr_code')
        if not qr_code:
            return Response({"error": "qr_code requerido"}, status=400)

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


# ============================================================
# VISTAS WEB (para el panel de administración)
# ============================================================
@staff_member_required
def bin_list_web(request):
    """Listado de canecas en formato HTML."""
    canecas = Bin.objects.all()
    return render(request, 'admin_panel/bin_list.html', {'canecas': canecas})


@staff_member_required
def bin_create_web(request):
    """Formulario para crear una caneca desde el panel web."""
    if request.method == 'POST':
        print("POST DATA:", request.POST)
        nombre = request.POST.get('nombre')
        tipo = request.POST.get('tipo')
        zona = request.POST.get('zona', '')
        latitud = request.POST.get('latitude')
        longitud = request.POST.get('longitude')

        if not nombre or not latitud or not longitud:
            messages.error(request, '❌ Faltan datos obligatorios (nombre, latitud, longitud).')
        else:
            try:
                Bin.objects.create(
                    nombre=nombre,
                    zona=zona,
                    tipo=tipo,
                    latitude=float(latitud),
                    longitude=float(longitud),
                    is_active=True,
                    fill_level=0
                )
                messages.success(request, '✅ Caneca creada correctamente.')
                return redirect('admin_bin_list')
            except Exception as e:
                print("=" * 50)
                print("ERROR CREANDO CANECA")
                print(repr(e))
                print("=" * 50)

                messages.error(request, f'❌ Error al guardar: {e}')

    return render(request, 'admin_panel/bin_create.html')


@staff_member_required
def bin_update_status_web(request):
    """Formulario para actualizar nivel de llenado (web)."""
    if request.method == 'POST':
        bin_id = request.POST.get('bin_id')
        fill_level = request.POST.get('fill_level')
        try:
            bin_obj = Bin.objects.get(id=bin_id)
            bin_obj.fill_level = int(fill_level)
            bin_obj.save()
            messages.success(request, f'✅ Nivel de llenado de {bin_obj.nombre} actualizado a {fill_level}%')
        except Exception as e:
            messages.error(request, f'❌ Error: {e}')
        return redirect('admin_bin_list')
    return render(request, 'admin_panel/bin_update_status.html')


@staff_member_required
def bin_scan_web(request):
    """Simular escaneo QR desde el panel web (para pruebas)."""
    if request.method == 'POST':
        qr_code = request.POST.get('qr_code')
        try:
            bin_obj = Bin.objects.get(qr_code=qr_code)
            BinScan.objects.create(
                bin=bin_obj,
                scanned_by=request.user,
                qr_code=qr_code
            )
            messages.success(request, f'✅ Escaneo registrado para {bin_obj.nombre}')
        except Bin.DoesNotExist:
            messages.error(request, '❌ Código QR no válido')
        return redirect('admin_bin_list')
    return render(request, 'admin_panel/bin_scan.html')


@staff_member_required
def bins_map_data_web(request):
    """Endpoint JSON para el mapa interactivo del dashboard web."""
    canecas = Bin.objects.filter(latitude__isnull=False, longitude__isnull=False)
    data = [{
        'id': c.id,
        'nombre': c.nombre,
        'latitude': float(c.latitude),
        'longitude': float(c.longitude),
        'is_active': c.is_active,
        'fill_level': c.fill_level,
    } for c in canecas]
    return JsonResponse(data, safe=False)