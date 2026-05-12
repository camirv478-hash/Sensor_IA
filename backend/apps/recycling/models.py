from django.db import models
from django.conf import settings


class Residuo(models.Model):
    """Catálogo de tipos de residuos reciclables."""
    
    CATEGORIAS = [
        ('plastico', 'Plástico'),
        ('vidrio', 'Vidrio'),
        ('papel', 'Papel'),
        ('carton', 'Cartón'),
        ('metal', 'Metal'),
        ('organico', 'Orgánico'),
        ('electronico', 'Electrónico'),
        ('textil', 'Textil'),
        ('peligroso', 'Peligroso'),
        ('otro', 'Otro'),
    ]
    
    nombre = models.CharField(max_length=100)
    categoria = models.CharField(max_length=20, choices=CATEGORIAS)
    descripcion = models.TextField(blank=True)
    puntos_base = models.PositiveIntegerField(default=10)
    icono = models.CharField(max_length=50, blank=True, help_text="Nombre del icono en Flutter")
    activo = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Residuo"
        verbose_name_plural = "Residuos"
        ordering = ['categoria', 'nombre']
    
    def __str__(self):
        return f"{self.nombre} ({self.get_categoria_display()}) - {self.puntos_base} pts"


class Escaneo(models.Model):
    """Registro de cada escaneo realizado por un usuario."""
    
    MODOS = [
        ('online', 'Online - IA en servidor'),
        ('offline', 'Offline - IA local'),
    ]
    
    usuario = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='escaneos'
    )
    residuo = models.ForeignKey(
        Residuo,
        on_delete=models.SET_NULL,
        null=True,
        related_name='escaneos'
    )
    imagen = models.ImageField(
        upload_to='escaneos/',
        null=True,
        blank=True
    )
    modo = models.CharField(max_length=10, choices=MODOS, default='online')
    confianza_ia = models.FloatField(
        null=True, blank=True,
        help_text="Porcentaje de confianza de la IA (0-100)"
    )
    puntos_obtenidos = models.PositiveIntegerField(default=0)
    sincronizado = models.BooleanField(default=True)
    latitud = models.FloatField(null=True, blank=True)
    longitud = models.FloatField(null=True, blank=True)
    notas = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Escaneo"
        verbose_name_plural = "Escaneos"
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.usuario.username} - {self.residuo} - {self.puntos_obtenidos} pts"
    
    def save(self, *args, **kwargs):
        """Asignar puntos automáticamente si no se especificaron."""
        if not self.puntos_obtenidos and self.residuo:
            self.puntos_obtenidos = self.residuo.puntos_base
        
        super().save(*args, **kwargs)
        
        # Sumar puntos al usuario
        if self.puntos_obtenidos > 0:
            self.usuario.puntos += self.puntos_obtenidos
            self.usuario.save()
            # Verificar si sube de nivel
            self.usuario.subir_nivel()