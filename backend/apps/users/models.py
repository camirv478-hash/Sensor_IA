from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    """Manager personalizado para el modelo User con campos adicionales."""

    def create_user(self, username, email=None, password=None, **extra_fields):
        """Crea y guarda un usuario con los campos obligatorios (username) y los extra."""
        if not username:
            raise ValueError("El campo username es obligatorio.")
        if not password:
            raise ValueError("La contraseña es obligatoria.")

        email = self.normalize_email(email)
        user = self.model(username=username, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, email=None, password=None, **extra_fields):
        """Crea y guarda un superusuario con permisos de administrador."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('rol', 'admin')

        if extra_fields.get('is_staff') is not True:
            raise ValueError('El superusuario debe tener is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('El superusuario debe tener is_superuser=True.')

        return self.create_user(username, email, password, **extra_fields)


class User(AbstractUser):
    """
    Usuario personalizado de SensorIA.
    Extiende AbstractUser para añadir campos de gamificación.
    """
    ROLES = [
        ('admin', 'Administrador'),
        ('user', 'Usuario normal'),
        ('collector', 'Recolector'),
    ]

    rol = models.CharField(
        max_length=20,
        choices=ROLES,
        default='user',
        verbose_name="Rol del usuario"
    )
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

    objects = UserManager()  # Manager personalizado

    class Meta:
        verbose_name = "Usuario"
        verbose_name_plural = "Usuarios"
        ordering = ['-puntos']

    def __str__(self):
        return f"{self.username} - {self.rol} - Nivel {self.nivel} - {self.puntos} pts"

    def subir_nivel(self):
        """Sube de nivel cuando alcanza ciertos puntos."""
        if self.puntos >= self.nivel * 100:
            self.nivel += 1
            self.save(update_fields=['nivel'])

    @property
    def es_admin(self):
        return self.rol == 'admin' or self.is_superuser