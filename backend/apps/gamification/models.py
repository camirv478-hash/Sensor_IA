from django.db import models
from django.conf import settings


class Desafio(models.Model):
    """Desafíos semanales/mensuales para los usuarios."""
    
    DIFICULTAD = [
        ('facil', 'Fácil'),
        ('medio', 'Medio'),
        ('dificil', 'Difícil'),
        ('legendario', 'Legendario'),
    ]
    
    TIPO_OBJETIVO = [
        ('escaneos_totales', 'Total de escaneos'),
        ('categoria_especifica', 'Categoría específica'),
        ('puntos', 'Puntos acumulados'),
        ('dias_consecutivos', 'Días consecutivos'),
    ]
    
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    dificultad = models.CharField(max_length=15, choices=DIFICULTAD, default='facil')
    tipo_objetivo = models.CharField(max_length=30, choices=TIPO_OBJETIVO)
    objetivo_cantidad = models.PositiveIntegerField(help_text="Ej: 50 escaneos, 1000 puntos")
    categoria_objetivo = models.CharField(max_length=20, blank=True, help_text="Solo si el tipo es 'categoria_especifica'")
    puntos_recompensa = models.PositiveIntegerField(default=100)
    badge_recompensa = models.CharField(max_length=100, blank=True, help_text="Nombre del badge en assets")
    fecha_inicio = models.DateTimeField()
    fecha_fin = models.DateTimeField()
    activo = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Desafío"
        verbose_name_plural = "Desafíos"
        ordering = ['-fecha_inicio']
    
    def __str__(self):
        return f"{self.nombre} - {self.get_dificultad_display()}"


class MisionDiaria(models.Model):
    """Misiones que se renuevan cada día."""
    
    TIPO = [
        ('escanear', 'Escanear residuos'),
        ('categoria', 'Escanear categoría específica'),
        ('puntos', 'Ganar puntos'),
        ('compartir', 'Compartir logro'),
    ]
    
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    tipo = models.CharField(max_length=20, choices=TIPO)
    objetivo_cantidad = models.PositiveIntegerField(default=3)
    categoria_objetivo = models.CharField(max_length=20, blank=True)
    puntos_recompensa = models.PositiveIntegerField(default=30)
    fecha = models.DateField()
    activo = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = "Misión Diaria"
        verbose_name_plural = "Misiones Diarias"
        ordering = ['-fecha']
    
    def __str__(self):
        return f"{self.nombre} - {self.fecha}"


class ProgresoDesafio(models.Model):
    """Progreso de un usuario en un desafío."""
    
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    desafio = models.ForeignKey(Desafio, on_delete=models.CASCADE)
    progreso = models.PositiveIntegerField(default=0)
    completado = models.BooleanField(default=False)
    fecha_completado = models.DateTimeField(null=True, blank=True)
    recompensa_obtenida = models.BooleanField(default=False)
    
    class Meta:
        verbose_name = "Progreso Desafío"
        verbose_name_plural = "Progresos Desafíos"
        unique_together = ['usuario', 'desafio']
    
    def __str__(self):
        return f"{self.usuario.username} - {self.desafio.nombre} ({self.progreso}/{self.desafio.objetivo_cantidad})"
    
    def verificar_completado(self):
        if self.progreso >= self.desafio.objetivo_cantidad and not self.completado:
            self.completado = True
            from django.utils import timezone
            self.fecha_completado = timezone.now()
            self.save()


class ProgresoMision(models.Model):
    """Progreso de un usuario en una misión diaria."""
    
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    mision = models.ForeignKey(MisionDiaria, on_delete=models.CASCADE)
    progreso = models.PositiveIntegerField(default=0)
    completado = models.BooleanField(default=False)
    fecha_completado = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = "Progreso Misión"
        verbose_name_plural = "Progresos Misiones"
        unique_together = ['usuario', 'mision']
    
    def __str__(self):
        return f"{self.usuario.username} - {self.mision.nombre}"


class Logro(models.Model):
    """Logros/Badges desbloqueables."""
    
    CATEGORIAS_LOGRO = [
        ('principiante', 'Principiante'),
        ('intermedio', 'Intermedio'),
        ('avanzado', 'Avanzado'),
        ('experto', 'Experto'),
        ('leyenda', 'Leyenda'),
    ]
    
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    categoria = models.CharField(max_length=20, choices=CATEGORIAS_LOGRO, default='principiante')
    icono = models.CharField(max_length=100, help_text="Ruta del badge: assets/badges/...")
    condicion_tipo = models.CharField(max_length=30, choices=Desafio.TIPO_OBJETIVO)
    condicion_cantidad = models.PositiveIntegerField()
    condicion_categoria = models.CharField(max_length=20, blank=True)
    puntos_recompensa = models.PositiveIntegerField(default=50)
    orden = models.PositiveIntegerField(default=0)
    
    class Meta:
        verbose_name = "Logro"
        verbose_name_plural = "Logros"
        ordering = ['orden']
    
    def __str__(self):
        return f"{self.nombre} - {self.get_categoria_display()}"


class LogroUsuario(models.Model):
    """Logros desbloqueados por un usuario."""
    
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='logros')
    logro = models.ForeignKey(Logro, on_delete=models.CASCADE)
    desbloqueado_en = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Logro de Usuario"
        verbose_name_plural = "Logros de Usuarios"
        unique_together = ['usuario', 'logro']
    
    def __str__(self):
        return f"{self.usuario.username} - {self.logro.nombre}"