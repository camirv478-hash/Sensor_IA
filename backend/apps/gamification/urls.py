from django.urls import path
from . import views

urlpatterns = [
    # Desafíos
    path('challenges/', views.DesafioListView.as_view(), name='desafios'),
    path('challenges/<int:desafio_id>/join/', views.UnirseDesafioView.as_view(), name='unirse-desafio'),
    path('my-challenges/', views.MisDesafiosView.as_view(), name='mis-desafios'),
    
    # Misiones diarias
    path('daily-missions/', views.MisionDiariaListView.as_view(), name='misiones-diarias'),
    path('my-daily-missions/', views.MiMisionDiariaView.as_view(), name='mis-misiones'),
    
    # Logros
    path('achievements/', views.LogroListView.as_view(), name='logros'),
    path('my-achievements/', views.MisLogrosView.as_view(), name='mis-logros'),
    
    # Leaderboard
    path('leaderboard/', views.LeaderboardView.as_view(), name='leaderboard'),
]