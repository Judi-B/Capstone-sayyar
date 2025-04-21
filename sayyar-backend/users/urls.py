from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,  # Get access & refresh tokens
    TokenRefreshView      # Refresh access token
)
from .views import LoginView, RegisterView, StudentRegisterView

urlpatterns = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('login/student/', LoginView.as_view(), name='student-login'),
    path('register/student/', StudentRegisterView.as_view(), name='student-register'),
]
