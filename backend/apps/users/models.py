from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Usuario personalizado de SensorIA.
    Extiende AbstractUser para añadir campos de gamificación.
    """
    puntos = models.PositiveIntegerField(default=0, verbose_name="Puntos acumulados")
    nivel = models.PositiveIntegerField(default=1, verbose_name="Nivel del usuario")
    avatar = models.ImageField(
        upload_to='avatars/',
        null=True,
        blank=True,
        verbose_name="Foto de perfil"
    )
    fecha_nacimiento = models.DateField(null=True, blank=True)
    biografia = models.TextField(max_length=500, blank=True, default='')

    class Meta:
        verbose_name = "Usuario"
        verbose_name_plural = "Usuarios"
        ordering = ['-puntos']

    def __str__(self):
        return f"{self.username} - Nivel {self.nivel} - {self.puntos} pts"

    def subir_nivel(self):
        """Sube de nivel cuando alcanza ciertos puntos."""
        if self.puntos >= self.nivel * 100:
            self.nivel += 1
            self.save()