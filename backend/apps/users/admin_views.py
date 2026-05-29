import datetime
from django.shortcuts import render
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth import get_user_model
from django.db.models import Count
from django.db.models.functions import TruncDay
from apps.bins.models import Bin
from apps.recycling.models import Escaneo  # Asegúrate de tener este modelo
from apps.recycling.classifier import classifier  # Para verificar TensorFlow
from apps.chatbot.views import client as gemini_model  # Variable global del cliente Gemini

User = get_user_model()

def is_admin(user):
    return user.is_authenticated and (user.rol == 'admin' or user.is_superuser)

@login_required
@user_passes_test(is_admin)
def admin_dashboard(request):
    # 1. Totales
    total_users = User.objects.count()
    total_bins = Bin.objects.count()
    total_recycling = Escaneo.objects.count()

    # 2. Datos semanales para el gráfico
    hoy = datetime.date.today()
    inicio_semana = hoy - datetime.timedelta(days=hoy.weekday())  # Lunes de esta semana
    dias_semana = [inicio_semana + datetime.timedelta(days=i) for i in range(7)]
    
    reciclajes_por_dia = (
        Escaneo.objects
        .filter(created_at__date__gte=inicio_semana)
        .annotate(dia=TruncDay('created_at'))
        .values('dia')
        .annotate(total=Count('id'))
        .order_by('dia')
    )
    
    # Convertir a diccionario {fecha: total}
    datos_diarios = {item['dia'].strftime('%Y-%m-%d'): item['total'] for item in reciclajes_por_dia}
    etiquetas = [dia.strftime('%a') for dia in dias_semana]  # ['Lun', 'Mar', ...]
    valores = [datos_diarios.get(dia.strftime('%Y-%m-%d'), 0) for dia in dias_semana]

    # 3. Estado de las IAs
    gemini_online = gemini_model is not None
    modelo_local_cargado = classifier.model is not None

    # Precisión y estadísticas de escaneos
    total_online = Escaneo.objects.filter(modo='online').count()
    total_offline = Escaneo.objects.filter(modo='offline').count()
    precision_ia = round((total_online / total_recycling * 100) if total_recycling > 0 else 0, 1)

    context = {
        'total_users': total_users,
        'total_recycling': total_recycling,
        'total_bins': total_bins,
        'etiquetas_semana': etiquetas,
        'valores_semana': valores,
        'gemini_online': gemini_online,
        'modelo_local_cargado': modelo_local_cargado,
        'precision_ia': precision_ia,
        'porcentaje_online': round((total_online / total_recycling * 100) if total_recycling > 0 else 0, 1),
        'porcentaje_offline': round((total_offline / total_recycling * 100) if total_recycling > 0 else 0, 1),
    }

    return render(request, 'admin_panel/dashboard.html', context)