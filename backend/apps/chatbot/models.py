from django.db import models
from django.conf import settings


class Conversacion(models.Model):
    """Historial de conversaciones del chatbot."""
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='conversaciones')
    titulo = models.CharField(max_length=200, default="Nueva conversación")
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Conversación"
        verbose_name_plural = "Conversaciones"
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.usuario.username} - {self.titulo}"


class Mensaje(models.Model):
    """Mensajes dentro de una conversación."""
    ROLES = [
        ('user', 'Usuario'),
        ('bot', 'EcoBot'),
        ('system', 'Sistema'),
    ]
    
    conversacion = models.ForeignKey(Conversacion, on_delete=models.CASCADE, related_name='mensajes')
    rol = models.CharField(max_length=10, choices=ROLES)
    contenido = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Mensaje"
        verbose_name_plural = "Mensajes"
        ordering = ['created_at']
    
    def __str__(self):
        return f"{self.get_rol_display()}: {self.contenido[:50]}"


class TipReciclaje(models.Model):
    """Tips precargados sobre reciclaje."""
    CATEGORIAS = [
        ('general', 'General'),
        ('plastico', 'Plástico'),
        ('vidrio', 'Vidrio'),
        ('papel', 'Papel'),
        ('metal', 'Metal'),
        ('organico', 'Orgánico'),
        ('electronico', 'Electrónico'),
    ]
    
    titulo = models.CharField(max_length=200)
    contenido = models.TextField()
    categoria = models.CharField(max_length=20, choices=CATEGORIAS, default='general')
    activo = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = "Tip de Reciclaje"
        verbose_name_plural = "Tips de Reciclaje"
    
    def __str__(self):
        return self.titulo