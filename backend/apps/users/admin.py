from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'rol', 'nivel', 'puntos', 'is_active')
    list_filter = ('rol', 'is_active')
    fieldsets = UserAdmin.fieldsets + (
        ('Gamificación', {
            'fields': ('puntos', 'nivel', 'avatar', 'biografia', 'rol')
        }),
    )