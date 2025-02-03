from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,  # Get access & refresh tokens
    TokenRefreshView      # Refresh access token
)

urlpatterns = [
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]