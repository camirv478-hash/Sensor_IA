from django.urls import path
from . import views

urlpatterns = [
    path('rewards/', views.RecompensaListView.as_view(), name='recompensas'),
    path('rewards/<int:pk>/', views.RecompensaDetailView.as_view(), name='detalle-recompensa'),
    path('rewards/featured/', views.DestacadosView.as_view(), name='destacados'),
    path('redeem/', views.CanjearRecompensaView.as_view(), name='canjear'),
    path('history/', views.HistorialCanjesView.as_view(), name='historial-canjes'),
]