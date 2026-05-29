from django.contrib import admin
from .models import Bin, BinScan

@admin.register(Bin)
class BinAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'tipo', 'zona', 'fill_level', 'is_active', 'qr_code')

@admin.register(BinScan)
class BinScanAdmin(admin.ModelAdmin):
    list_display = ('bin', 'scanned_by', 'scanned_at')