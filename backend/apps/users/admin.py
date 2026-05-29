from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from apps.users.models import User
from apps.bins.models import Bin  

@login_required
def admin_dashboard(request):

    total_users = User.objects.count()
    total_recycling = RecyclingRecord.objects.count()
    total_bins = SmartBin.objects.count()

    context = {
        'total_users': total_users,
        'total_recycling': total_recycling,
        'total_bins': total_bins,
    }

    return render(
        request,
        'admin_panel/dashboard.html',
        context
    )