from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,  # Get access & refresh tokens
    TokenRefreshView      # Refresh access token
)
from .views import LoginView, SignupView, StudentSignupView

urlpatterns = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('login/', LoginView.as_view(), name='login'),
    path('signup/', SignupView.as_view(), name='signup'),
    path('signup/student/', StudentSignupView.as_view(), name='student-signup'),
]
