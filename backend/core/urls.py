"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

"""
URL configuration for core project.
"""

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

from rest_framework_simplejwt.views import TokenRefreshView
from apps.users.views import CustomTokenObtainPairView

# Vistas del panel administrativo general
from apps.users.admin_views import (
    admin_dashboard,
    admin_user_list,
    admin_user_detail,
    admin_recycling,
    admin_gemini,
    admin_marketplace,
    reward_create,
    reward_edit,
    admin_redemptions,
    redemption_update_status,
    admin_user_password,
)

# Vistas de canecas (app bins)
from apps.bins.views import (
    bin_list_web,
    bin_create_web,
    bin_scan_web,
    bin_update_status_web,
    bins_map_data_web,
)

urlpatterns = [
    # Django Admin
    path('admin/', admin.site.urls),

    # ==========================
    # AUTENTICACIÓN JWT
    # ==========================
    path('api/auth/login/',CustomTokenObtainPairView.as_view(),name='token_obtain_pair'),
    path('api/auth/refresh/',TokenRefreshView.as_view(),name='token_refresh'),

    # ==========================
    # APIS
    # ==========================
    path('api/users/',include('apps.users.urls')),
    path('api/recycling/',include('apps.recycling.urls')),
    path('api/gamification/',include('apps.gamification.urls')),
    path('api/marketplace/',include('apps.marketplace.urls')),
    path('api/chatbot/',include('apps.chatbot.urls')),

    # API de canecas
    path('api/admin/bins/',include('apps.bins.urls')),

    # ==========================
    # PANEL ADMINISTRATIVO
    # ==========================

    # Usuarios
    path('admin-panel/users/',admin_user_list,name='admin_user_list'),
    path('admin-panel/users/<int:user_id>/',admin_user_detail,name='admin_user_detail'),

    # Canecas
    path('admin-panel/bins/',bin_list_web,name='admin_bin_list'),
    path('admin-panel/bins/create/',bin_create_web,name='admin_bin_create'),
    path('admin-panel/bins/scan/',bin_scan_web,name='admin_bin_scan'),
    path('admin-panel/bins/update-status/',bin_update_status_web,name='admin_bin_update_status'),
    path('admin-panel/bins/map-data/',bins_map_data_web,name='bins_map_data_web'),

    # Otras secciones del panel
    path('admin-panel/recycling/',admin_recycling,name='admin_recycling'),
    path('admin-panel/gemini/',admin_gemini,name='admin_gemini'),
    path('admin-panel/marketplace/',admin_marketplace,name='admin_marketplace'),

    # Dashboard principal
    path('admin-panel/',admin_dashboard,name='admin_dashboard'),

    # Rutas para gestión de recompensas en el marketplace
    path('admin-panel/marketplace/rewards/create/',reward_create,name='reward_create'),
    path('admin-panel/marketplace/rewards/edit/<int:reward_id>/',reward_edit,name='reward_edit'),
    path('admin-panel/marketplace/redemptions/',admin_redemptions,name='admin_redemptions'),
    path('admin-panel/marketplace/redemptions/<int:canje_id>/<str:estado>/',redemption_update_status,name='redemption_update_status'),

    # Rutas para gestión de usuarios
    path('admin-panel/users/<int:user_id>/password/',admin_user_password,name='admin_user_password'),
]

urlpatterns += static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT
)