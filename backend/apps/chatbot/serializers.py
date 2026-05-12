from rest_framework import serializers
from .models import Conversacion, Mensaje, TipReciclaje


class MensajeSerializer(serializers.ModelSerializer):
    rol_display = serializers.CharField(source='get_rol_display', read_only=True)
    
    class Meta:
        model = Mensaje
        fields = ['id', 'conversacion', 'rol', 'rol_display', 'contenido', 'created_at']
        read_only_fields = ['conversacion']


class ConversacionSerializer(serializers.ModelSerializer):
    mensajes = MensajeSerializer(many=True, read_only=True)
    ultimo_mensaje = serializers.SerializerMethodField()
    
    class Meta:
        model = Conversacion
        fields = ['id', 'titulo', 'mensajes', 'ultimo_mensaje', 'created_at']
    
    def get_ultimo_mensaje(self, obj):
        ultimo = obj.mensajes.last()
        if ultimo:
            return MensajeSerializer(ultimo).data
        return None


class ConversacionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Conversacion
        fields = ['titulo']


class MensajeCreateSerializer(serializers.Serializer):
    mensaje = serializers.CharField()
    conversacion_id = serializers.IntegerField(required=False)


class TipReciclajeSerializer(serializers.ModelSerializer):
    categoria_display = serializers.CharField(source='get_categoria_display', read_only=True)
    
    class Meta:
        model = TipReciclaje
        fields = '__all__'