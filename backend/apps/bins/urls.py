from django.urls import path
from . import views

urlpatterns = [
    path('list/', views.BinListView.as_view(), name='bin-list'),
    path('create/', views.BinCreateView.as_view(), name='bin-create'),
    path('detail/<str:qr_code>/', views.BinDetailView.as_view(), name='bin-detail'),
    path('status/', views.BinUpdateStatusView.as_view(), name='bin-status'),
    path('scan/', views.BinScanView.as_view(), name='bin-scan'),
]