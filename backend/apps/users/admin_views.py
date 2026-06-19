import datetime
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth import get_user_model
from django.db.models import Count, Q, Sum
from django.db.models.functions import TruncDay
from django.contrib import messages

from apps.bins.models import Bin
from apps.recycling.models import Residuo, Escaneo
from apps.recycling.classifier import classifier  # Para verificar TensorFlow
from apps.chatbot.views import client as gemini_model  # Variable global del cliente Gemini
from apps.marketplace.models import Recompensa, Canje

User = get_user_model()

def is_admin(user):
    return user.is_authenticated and (user.rol == 'admin' or user.is_superuser)

@login_required
@user_passes_test(is_admin)
def admin_dashboard(request):
    total_users = User.objects.count()
    total_bins = Bin.objects.count()
    total_residues = Residuo.objects.filter(activo=True).count()
    total_scans = Escaneo.objects.count()
    total_points = Escaneo.objects.aggregate(total_points=Sum('puntos_obtenidos'))['total_points'] or 0

    hoy = datetime.date.today()
    inicio_semana = hoy - datetime.timedelta(days=hoy.weekday())
    dias_semana = [inicio_semana + datetime.timedelta(days=i) for i in range(7)]

    reciclajes_por_dia = (
        Escaneo.objects
        .filter(created_at__date__gte=inicio_semana)
        .annotate(dia=TruncDay('created_at'))
        .values('dia')
        .annotate(total=Count('id'))
        .order_by('dia')
    )
    datos_diarios = {item['dia'].strftime('%Y-%m-%d'): item['total'] for item in reciclajes_por_dia}
    etiquetas = [dia.strftime('%a') for dia in dias_semana]
    valores = [datos_diarios.get(dia.strftime('%Y-%m-%d'), 0) for dia in dias_semana]

    gemini_online = gemini_model is not None
    modelo_local_cargado = classifier.model is not None

    total_online = Escaneo.objects.filter(modo='online').count()
    total_offline = Escaneo.objects.filter(modo='offline').count()
    precision_ia = round((total_online / total_scans * 100) if total_scans > 0 else 0, 1)

    context = {
        'total_users': total_users,
        'total_bins': total_bins,
        'total_residues': total_residues,
        'total_scans': total_scans,
        'puntos_otorgados': total_points,
        'etiquetas_semana': etiquetas,
        'valores_semana': valores,
        'gemini_online': gemini_online,
        'modelo_local_cargado': modelo_local_cargado,
        'precision_ia': precision_ia,
        'porcentaje_online': round((total_online / total_scans * 100) if total_scans > 0 else 0, 1),
        'porcentaje_offline': round((total_offline / total_scans * 100) if total_scans > 0 else 0, 1),
    }
    return render(request, 'admin_panel/dashboard.html', context)


@login_required
@user_passes_test(is_admin)
def admin_user_list(request):
    query = request.GET.get('q', '').strip()
    role_filter = request.GET.get('role', '').strip()
    min_level = request.GET.get('min_level', '').strip()
    max_level = request.GET.get('max_level', '').strip()

    users = User.objects.all().order_by('-puntos', '-nivel', 'username')

    if query:
        users = users.filter(
            Q(username__icontains=query) |
            Q(email__icontains=query) |
            Q(first_name__icontains=query) |
            Q(last_name__icontains=query)
        )
    if role_filter:
        users = users.filter(rol=role_filter)
    if min_level.isdigit():
        users = users.filter(nivel__gte=int(min_level))
    if max_level.isdigit():
        users = users.filter(nivel__lte=int(max_level))

    roles = [('', 'Todos')] + list(User.ROLES)
    context = {
        'users': users,
        'count': users.count(),
        'query': query,
        'role_filter': role_filter,
        'min_level': min_level,
        'max_level': max_level,
        'roles': roles,
    }
    return render(request, 'admin_panel/users_list.html', context)


@login_required
@user_passes_test(is_admin)
def admin_user_detail(request, user_id):
    user = get_object_or_404(User, id=user_id)

    if request.method == "POST":
        user.first_name = request.POST.get("first_name", "")
        user.last_name = request.POST.get("last_name", "")
        user.email = request.POST.get("email", "")
        nivel = request.POST.get("nivel")
        puntos = request.POST.get("puntos")
        if nivel is not None and nivel.isdigit():
            user.nivel = int(nivel)
        if puntos is not None and puntos.isdigit():
            user.puntos = int(puntos)
        user.save()
        messages.success(request, "Usuario actualizado correctamente.")
        return redirect('admin_user_detail', user_id=user.id)

    # Estadísticas adicionales (puedes ajustar según tu modelo)
    total_scans = Escaneo.objects.filter(usuario=user).count()
    total_logros = 0  # Si tienes modelo de logros, ajusta
    total_canjes = Canje.objects.filter(usuario=user).count() if 'Canje' in globals() else 0

    context = {
        'user': user,
        'total_scans': total_scans,
        'total_logros': total_logros,
        'total_canjes': total_canjes,
    }
    return render(request, 'admin_panel/user_detail.html', context)


@login_required
@user_passes_test(is_admin)
def admin_user_password(request, user_id):
    user = get_object_or_404(User, id=user_id)

    if request.method == 'POST':
        password = request.POST.get('password')
        if password:
            user.set_password(password)
            user.save()
            messages.success(request, 'Contraseña actualizada correctamente.')
            return redirect('admin_user_detail', user_id=user.id)
        else:
            messages.error(request, 'Debes ingresar una nueva contraseña.')
            return redirect('admin_user_detail', user_id=user.id)

    # Si es GET, redirige al detalle (no hay página separada)
    return redirect('admin_user_detail', user_id=user.id)


@login_required
@user_passes_test(is_admin)
def admin_recycling(request):
    total_scans = Escaneo.objects.count()
    scans_today = Escaneo.objects.filter(created_at__date=datetime.date.today()).count()
    total_points = Escaneo.objects.aggregate(total=Sum('puntos_obtenidos'))['total'] or 0
    total_residues = Residuo.objects.filter(activo=True).count()
    latest_scans = Escaneo.objects.select_related('usuario', 'residuo').order_by('-created_at')[:10]
    residuos_stats = Escaneo.objects.values('residuo__nombre').annotate(total=Count('id')).order_by('-total')

    context = {
        'total_scans': total_scans,
        'scans_today': scans_today,
        'total_points': total_points,
        'total_residues': total_residues,
        'latest_scans': latest_scans,
        'residuos_stats': residuos_stats,
        'gemini_online': gemini_model is not None,
        'modelo_local': classifier.model is not None,
    }
    return render(request, 'admin_panel/recycling.html', context)


@login_required
@user_passes_test(is_admin)
def admin_gemini(request):
    return render(request, 'admin_panel/gemini.html')


@login_required
@user_passes_test(is_admin)
def admin_marketplace(request):
    total_rewards = Recompensa.objects.count()
    active_rewards = Recompensa.objects.filter(activo=True).count()
    total_redemptions = Canje.objects.count()
    total_points_spent = Canje.objects.aggregate(total=Sum('puntos_gastados'))['total'] or 0
    rewards = Recompensa.objects.order_by('-destacado', 'costo_puntos')
    latest_redemptions = Canje.objects.select_related('usuario', 'recompensa').order_by('-created_at')[:10]

    context = {
        'total_rewards': total_rewards,
        'active_rewards': active_rewards,
        'total_redemptions': total_redemptions,
        'total_points_spent': total_points_spent,
        'rewards': rewards,
        'latest_redemptions': latest_redemptions,
    }
    return render(request, 'admin_panel/marketplace.html', context)


@login_required
@user_passes_test(is_admin)
def reward_create(request):
    if request.method == 'POST':
        Recompensa.objects.create(
            nombre=request.POST.get('nombre'),
            descripcion=request.POST.get('descripcion'),
            categoria=request.POST.get('categoria'),
            costo_puntos=request.POST.get('costo_puntos'),
            stock=request.POST.get('stock'),
            imagen=request.POST.get('imagen'),
            codigo=request.POST.get('codigo'),
            activo='activo' in request.POST,
            destacado='destacado' in request.POST,
        )
        messages.success(request, 'La recompensa ha sido creada exitosamente.')
        return redirect('admin_marketplace')
    return render(request, 'admin_panel/reward_create.html', {'categorias': Recompensa.CATEGORIAS})


@login_required
@user_passes_test(is_admin)
def reward_edit(request, reward_id):
    reward = get_object_or_404(Recompensa, id=reward_id)
    if request.method == 'POST':
        reward.nombre = request.POST.get('nombre')
        reward.descripcion = request.POST.get('descripcion')
        reward.categoria = request.POST.get('categoria')
        reward.costo_puntos = request.POST.get('costo_puntos')
        reward.stock = request.POST.get('stock')
        reward.imagen = request.POST.get('imagen')
        reward.codigo = request.POST.get('codigo')
        reward.activo = 'activo' in request.POST
        reward.destacado = 'destacado' in request.POST
        reward.save()
        messages.success(request, 'Recompensa actualizada.')
        return redirect('admin_marketplace')
    return render(request, 'admin_panel/reward_edit.html', {'reward': reward, 'categorias': Recompensa.CATEGORIAS})


@login_required
@user_passes_test(is_admin)
def admin_redemptions(request):
    canjes = Canje.objects.select_related('usuario', 'recompensa').order_by('-created_at')
    return render(request, 'admin_panel/redemptions.html', {'canjes': canjes})


@login_required
@user_passes_test(is_admin)
def redemption_update_status(request, canje_id, estado):
    canje = get_object_or_404(Canje, id=canje_id)
    if estado in ['pendiente', 'aprobado', 'entregado', 'cancelado']:
        canje.estado = estado
        canje.save()
    return redirect('admin_redemptions')