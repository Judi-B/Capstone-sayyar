from django.urls import path

from businesses.views import UniversityView

urlpatterns = [
    path('universities/', UniversityView.as_view(), name='get_universities'),
]
