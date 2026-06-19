from django.urls import path
from . import views

urlpatterns = [
    # ========== RUTAS WEB (panel admin) ==========
    path('', views.bin_list_web, name='admin_bin_list'),
    path('create/', views.bin_create_web, name='admin_bin_create'),
    path('update-status/', views.bin_update_status_web, name='admin_bin_update_status'),
    path('scan/', views.bin_scan_web, name='admin_bin_scan'),
    path('map-data/', views.bins_map_data_web, name='bins_map_data_web'),

    # ========== RUTAS API (para móvil) ==========
    path('api/list/', views.BinListView.as_view(), name='bin-list'),
    path('api/map/', views.BinMapView.as_view(), name='bin-map'),
    path('api/create/', views.BinCreateView.as_view(), name='bin-create'),
    path('api/detail/<str:qr_code>/', views.BinDetailView.as_view(), name='bin-detail'),
    path('api/status/', views.BinUpdateStatusView.as_view(), name='bin-status'),
    path('api/scan/', views.BinScanView.as_view(), name='bin-scan'),
]