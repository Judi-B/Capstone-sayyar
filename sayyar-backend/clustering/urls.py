from django.urls import path
from rest_framework import routers

from clustering.views import BookTripView, TripsViewset, OptimizeRoutesView

default_router = routers.DefaultRouter()
default_router.register('trips', TripsViewset)

urlpatterns = [
    path('book/', BookTripView.as_view(), name='book_trip'),
    path('optimize-routes/', OptimizeRoutesView.as_view(), name='optimize_routes')
]

urlpatterns += default_router.urls
