from rest_framework import serializers
from .models import Recompensa, Canje


class RecompensaSerializer(serializers.ModelSerializer):
    categoria_display = serializers.CharField(source='get_categoria_display', read_only=True)
    disponible = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = Recompensa
        fields = '__all__'


class CanjeSerializer(serializers.ModelSerializer):
    recompensa_nombre = serializers.CharField(source='recompensa.nombre', read_only=True)
    recompensa_imagen = serializers.CharField(source='recompensa.imagen', read_only=True)
    recompensa_categoria = serializers.CharField(source='recompensa.get_categoria_display', read_only=True)
    estado_display = serializers.CharField(source='get_estado_display', read_only=True)
    
    class Meta:
        model = Canje
        fields = [
            'id', 'recompensa', 'recompensa_nombre', 'recompensa_imagen',
            'recompensa_categoria', 'puntos_gastados', 'estado',
            'estado_display', 'codigo_canje', 'created_at'
        ]
        read_only_fields = ['usuario', 'puntos_gastados', 'codigo_canje']


class CanjeCreateSerializer(serializers.Serializer):
    """Serializador para canjear una recompensa."""
    recompensa_id = serializers.IntegerField()