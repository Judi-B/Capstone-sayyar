from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,  # Get access & refresh tokens
    TokenRefreshView      # Refresh access token
)
from .views import StudentRegisterView, StudentSubscribeView, DriverProfileDataView, ContactsView
from .views import DriverRegisterView
from .views import DriverLoginView
from .views import EmployeeRegisterView
from .views import EmployeeLoginView
from .views import StudentLoginView

urlpatterns = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('login/student/', StudentLoginView.as_view(), name='student-login'),
    path('register/student/', StudentRegisterView.as_view(), name='student-register'),
    path('subscribe/student/', StudentSubscribeView.as_view(), name='student-subscribe'),
    path('login/employee/', EmployeeLoginView.as_view(), name='employee-login'),
    path('register/employee/', EmployeeRegisterView.as_view(), name='employee-register'),
    path('login/driver/', DriverLoginView.as_view(), name='driver-login'),
    path('register/driver/', DriverRegisterView.as_view(), name='driver-register'),
    path('user-data/driver/', DriverProfileDataView.as_view(), name='driver-data'),
    path('contacts/', ContactsView.as_view(), name='contacts'),
]
