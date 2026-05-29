from rest_framework import serializers
from .models import Bin, BinScan


class BinSerializer(serializers.ModelSerializer):
    tipo_display = serializers.CharField(source='get_tipo_display', read_only=True)
    
    class Meta:
        model = Bin
        fields = '__all__'
        read_only_fields = ('qr_code', 'created_at', 'updated_at')


class BinCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bin
        fields = ['nombre', 'zona', 'tipo', 'latitude', 'longitude']


class BinStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bin
        fields = ['fill_level', 'is_active']


class BinScanSerializer(serializers.ModelSerializer):
    bin_nombre = serializers.CharField(source='bin.nombre', read_only=True)
    
    class Meta:
        model = BinScan
        fields = '__all__'