from django.contrib import admin
from .models import Desafio, MisionDiaria, ProgresoDesafio, ProgresoMision, Logro, LogroUsuario


@admin.register(Desafio)
class DesafioAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'dificultad', 'tipo_objetivo', 'objetivo_cantidad', 'puntos_recompensa', 'activo')
    list_filter = ('dificultad', 'activo')


@admin.register(MisionDiaria)
class MisionDiariaAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'tipo', 'objetivo_cantidad', 'puntos_recompensa', 'fecha', 'activo')
    list_filter = ('fecha', 'activo')


@admin.register(ProgresoDesafio)
class ProgresoDesafioAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'desafio', 'progreso', 'completado', 'recompensa_obtenida')


@admin.register(ProgresoMision)
class ProgresoMisionAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'mision', 'progreso', 'completado')


@admin.register(Logro)
class LogroAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'categoria', 'condicion_tipo', 'condicion_cantidad', 'puntos_recompensa', 'orden')
    list_filter = ('categoria',)


@admin.register(LogroUsuario)
class LogroUsuarioAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'logro', 'desbloqueado_en')