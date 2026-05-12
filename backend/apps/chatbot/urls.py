from django.urls import path
from . import views

urlpatterns = [
    path('conversations/', views.ConversacionListView.as_view(), name='conversaciones'),
    path('conversations/create/', views.ConversacionCreateView.as_view(), name='crear-conversacion'),
    path('send/', views.MensajeCreateView.as_view(), name='enviar-mensaje'),
    path('tips/', views.TipsListView.as_view(), name='tips'),
    path('tips/random/', views.TipRandomView.as_view(), name='tip-random'),
]