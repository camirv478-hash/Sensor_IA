from django.contrib import admin
from .models import Recompensa, Canje


@admin.register(Recompensa)
class RecompensaAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'categoria', 'costo_puntos', 'stock', 'destacado', 'activo')
    list_filter = ('categoria', 'destacado', 'activo')
    search_fields = ('nombre',)


@admin.register(Canje)
class CanjeAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'recompensa', 'puntos_gastados', 'estado', 'codigo_canje', 'created_at')
    list_filter = ('estado',)