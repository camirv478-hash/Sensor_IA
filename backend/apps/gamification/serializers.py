from rest_framework import serializers
from .models import (
    Desafio, MisionDiaria, ProgresoDesafio, 
    ProgresoMision, Logro, LogroUsuario
)


class DesafioSerializer(serializers.ModelSerializer):
    dificultad_display = serializers.CharField(source='get_dificultad_display', read_only=True)
    
    class Meta:
        model = Desafio
        fields = '__all__'


class ProgresoDesafioSerializer(serializers.ModelSerializer):
    desafio_nombre = serializers.CharField(source='desafio.nombre', read_only=True)
    desafio_dificultad = serializers.CharField(source='desafio.get_dificultad_display', read_only=True)
    desafio_puntos = serializers.IntegerField(source='desafio.puntos_recompensa', read_only=True)
    porcentaje = serializers.SerializerMethodField()
    
    class Meta:
        model = ProgresoDesafio
        fields = [
            'id', 'desafio', 'desafio_nombre', 'desafio_dificultad',
            'desafio_puntos', 'progreso', 'objetivo_cantidad',
            'porcentaje', 'completado', 'recompensa_obtenida'
        ]
        read_only_fields = ['usuario', 'completado', 'fecha_completado']
    
    def get_porcentaje(self, obj):
        if obj.desafio.objetivo_cantidad > 0:
            return round((obj.progreso / obj.desafio.objetivo_cantidad) * 100, 1)
        return 0
    
    @property
    def objetivo_cantidad(self):
        return self.desafio.objetivo_cantidad if hasattr(self, 'desafio') else 0


class MisionDiariaSerializer(serializers.ModelSerializer):
    tipo_display = serializers.CharField(source='get_tipo_display', read_only=True)
    
    class Meta:
        model = MisionDiaria
        fields = '__all__'


class ProgresoMisionSerializer(serializers.ModelSerializer):
    mision_nombre = serializers.CharField(source='mision.nombre', read_only=True)
    mision_puntos = serializers.IntegerField(source='mision.puntos_recompensa', read_only=True)
    porcentaje = serializers.SerializerMethodField()
    
    class Meta:
        model = ProgresoMision
        fields = [
            'id', 'mision', 'mision_nombre', 'mision_puntos',
            'progreso', 'objetivo_cantidad', 'porcentaje', 'completado'
        ]
    
    def get_porcentaje(self, obj):
        if obj.mision.objetivo_cantidad > 0:
            return round((obj.progreso / obj.mision.objetivo_cantidad) * 100, 1)
        return 0
    
    @property
    def objetivo_cantidad(self):
        return self.mision.objetivo_cantidad if hasattr(self, 'mision') else 0


class LogroSerializer(serializers.ModelSerializer):
    categoria_display = serializers.CharField(source='get_categoria_display', read_only=True)
    
    class Meta:
        model = Logro
        fields = '__all__'


class LogroUsuarioSerializer(serializers.ModelSerializer):
    logro_nombre = serializers.CharField(source='logro.nombre', read_only=True)
    logro_icono = serializers.CharField(source='logro.icono', read_only=True)
    logro_categoria = serializers.CharField(source='logro.get_categoria_display', read_only=True)
    
    class Meta:
        model = LogroUsuario
        fields = ['id', 'logro', 'logro_nombre', 'logro_icono', 'logro_categoria', 'desbloqueado_en']


class LeaderboardSerializer(serializers.Serializer):
    """Serializador para el ranking."""
    username = serializers.CharField()
    nivel = serializers.IntegerField()
    puntos = serializers.IntegerField()
    total_escaneos = serializers.IntegerField()
    posicion = serializers.IntegerField()