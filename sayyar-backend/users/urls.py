from django.urls import path
from rest_framework import routers
from rest_framework_simplejwt.views import (
    TokenObtainPairView,  # Get access & refresh tokens
    TokenRefreshView  # Refresh access token
)
from .views import StudentRegisterView, StudentSubscribeView, DriverProfileDataView, ContactsView, StudentProfileView, \
    EmployeeProfileDataView, DriversViewset, StudentsViewset
from .views import DriverRegisterView
from .views import DriverLoginView
from .views import EmployeeRegisterView
from .views import EmployeeLoginView
from .views import StudentLoginView

default_router = routers.DefaultRouter()
default_router.register(r'drivers', DriversViewset)
default_router.register(r'students', StudentsViewset)

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
    path('user-data/employee/', EmployeeProfileDataView.as_view(), name='employee-data'),
    path('user-data/student/', StudentProfileView.as_view(), name='student-data'),
    path('contacts/', ContactsView.as_view(), name='contacts'),
]

urlpatterns += default_router.urls
