from django.db import models
from django.conf import settings


class Recompensa(models.Model):
    """Productos y recompensas canjeables con puntos."""
    
    CATEGORIAS = [
        ('cupon', 'Cupón de descuento'),
        ('producto', 'Producto físico'),
        ('digital', 'Recompensa digital'),
        ('donacion', 'Donación benéfica'),
        ('experiencia', 'Experiencia'),
        ('mascota', 'Accesorio EcoBot'),
        ('insignia', 'Insignia especial'),
    ]
    
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    categoria = models.CharField(max_length=20, choices=CATEGORIAS)
    costo_puntos = models.PositiveIntegerField()
    stock = models.PositiveIntegerField(default=1, help_text="0 = ilimitado")
    imagen = models.CharField(max_length=100, help_text="Ruta en assets/rewards/")
    descuento = models.PositiveIntegerField(default=0, help_text="Porcentaje si es cupón")
    codigo = models.CharField(max_length=50, blank=True, help_text="Código de canje")
    activo = models.BooleanField(default=True)
    destacado = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Recompensa"
        verbose_name_plural = "Recompensas"
        ordering = ['costo_puntos']
    
    def __str__(self):
        return f"{self.nombre} - {self.costo_puntos} pts"
    
    @property
    def disponible(self):
        return self.stock > 0 or self.stock == 0


class Canje(models.Model):
    """Registro de recompensas canjeadas por usuarios."""
    
    ESTADOS = [
        ('pendiente', 'Pendiente'),
        ('aprobado', 'Aprobado'),
        ('entregado', 'Entregado'),
        ('cancelado', 'Cancelado'),
    ]
    
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='canjes')
    recompensa = models.ForeignKey(Recompensa, on_delete=models.CASCADE, related_name='canjes')
    puntos_gastados = models.PositiveIntegerField()
    estado = models.CharField(max_length=15, choices=ESTADOS, default='pendiente')
    codigo_canje = models.CharField(max_length=50, blank=True, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Canje"
        verbose_name_plural = "Canjes"
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.usuario.username} canjeó {self.recompensa.nombre}"
    
    def save(self, *args, **kwargs):
        import uuid
        if not self.codigo_canje:
            self.codigo_canje = f"SENSORIA-{uuid.uuid4().hex[:8].upper()}"
        
        if not self.pk:  # Solo al crear
            self.puntos_gastados = self.recompensa.costo_puntos
            # Descontar puntos
            self.usuario.puntos -= self.puntos_gastados
            self.usuario.save()
            # Descontar stock
            if self.recompensa.stock > 0:
                self.recompensa.stock -= 1
                self.recompensa.save()
        
        super().save(*args, **kwargs)