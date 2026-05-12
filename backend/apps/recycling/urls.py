from django.urls import path
from . import views

urlpatterns = [
    # Catálogo de residuos
    path('residuos/', views.ResiduoListView.as_view(), name='residuo-list'),
    
    # Escaneos
    path('scan/', views.EscaneoCreateView.as_view(), name='escanear'),
    path('history/', views.EscaneoHistoryView.as_view(), name='historial'),
    path('history/<int:pk>/', views.EscaneoDetailView.as_view(), name='detalle-escaneo'),
    
    # Sincronización offline
    path('sync/', views.EscaneoSyncView.as_view(), name='sincronizar'),
    
    # Estadísticas
    path('stats/', views.StatsView.as_view(), name='estadisticas'),
]