from django.contrib import admin
from .models import Residuo, Escaneo


@admin.register(Residuo)
class ResiduoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'categoria', 'puntos_base', 'activo')
    list_filter = ('categoria', 'activo')
    search_fields = ('nombre',)


@admin.register(Escaneo)
class EscaneoAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'residuo', 'modo', 'puntos_obtenidos', 'created_at')
    list_filter = ('modo', 'sincronizado', 'created_at')
    search_fields = ('usuario__username', 'residuo__nombre')