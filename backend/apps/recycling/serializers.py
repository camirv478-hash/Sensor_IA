from rest_framework import serializers
from .models import Residuo, Escaneo


class ResiduoSerializer(serializers.ModelSerializer):
    """Serializador para el catálogo de residuos."""
    categoria_display = serializers.CharField(source='get_categoria_display', read_only=True)
    
    class Meta:
        model = Residuo
        fields = '__all__'


class EscaneoSerializer(serializers.ModelSerializer):
    """Serializador para registrar y listar escaneos."""
    residuo_nombre = serializers.CharField(source='residuo.nombre', read_only=True)
    residuo_categoria = serializers.CharField(source='residuo.categoria', read_only=True)
    username = serializers.CharField(source='usuario.username', read_only=True)
    
    class Meta:
        model = Escaneo
        fields = [
            'id', 'usuario', 'username', 'residuo', 'residuo_nombre',
            'residuo_categoria', 'imagen', 'modo', 'confianza_ia',
            'puntos_obtenidos', 'sincronizado', 'latitud', 'longitud',
            'notas', 'created_at'
        ]
        read_only_fields = ['usuario', 'puntos_obtenidos', 'created_at']


class EscaneoCreateSerializer(serializers.ModelSerializer):
    """Serializador para crear un nuevo escaneo."""
    
    class Meta:
        model = Escaneo
        fields = ['residuo', 'imagen', 'modo', 'confianza_ia', 'latitud', 'longitud']
        # Sin read_only_fields
    
    def create(self, validated_data):
        # El usuario y residuo se asignan en la vista
        return Escaneo.objects.create(**validated_data)


class EscaneoSyncSerializer(serializers.Serializer):
    """Serializador para sincronizar escaneos offline."""
    escaneos = serializers.ListField(
        child=serializers.DictField(),
        help_text="Lista de escaneos offline para sincronizar"
    )