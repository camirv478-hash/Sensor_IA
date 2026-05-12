from django.contrib import admin
from .models import Conversacion, Mensaje, TipReciclaje


@admin.register(Conversacion)
class ConversacionAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'titulo', 'created_at')


@admin.register(Mensaje)
class MensajeAdmin(admin.ModelAdmin):
    list_display = ('conversacion', 'rol', 'contenido_corto', 'created_at')
    
    def contenido_corto(self, obj):
        return obj.contenido[:60]


@admin.register(TipReciclaje)
class TipReciclajeAdmin(admin.ModelAdmin):
    list_display = ('titulo', 'categoria', 'activo')
    list_filter = ('categoria', 'activo')