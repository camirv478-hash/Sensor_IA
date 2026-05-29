from django.db import models


class Bin(models.Model):
    TIPOS = [
        ('plastic', 'Plástico'),
        ('paper', 'Papel'),
        ('metal', 'Metal'),
        ('glass', 'Vidrio'),
        ('organic', 'Orgánico'),
        ('electronic', 'Electrónico'),
    ]
    
    nombre = models.CharField(max_length=200)
    zona = models.CharField(max_length=200)
    tipo = models.CharField(max_length=20, choices=TIPOS)
    latitude = models.FloatField()
    longitude = models.FloatField()
    fill_level = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    qr_code = models.CharField(max_length=100, blank=True, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Caneca"
        verbose_name_plural = "Canecas"
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.nombre} - {self.get_tipo_display()} ({self.zona})"
    
    def save(self, *args, **kwargs):
        if not self.qr_code:
            import uuid
            self.qr_code = f"BIN-{uuid.uuid4().hex[:8].upper()}"
        super().save(*args, **kwargs)


class BinScan(models.Model):
    bin = models.ForeignKey(Bin, on_delete=models.CASCADE, related_name='scans')
    scanned_by = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True)
    qr_code = models.CharField(max_length=100)
    scanned_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Escaneo QR"
        verbose_name_plural = "Escaneos QR"
    
    def __str__(self):
        return f"{self.bin.nombre} - {self.scanned_at}"