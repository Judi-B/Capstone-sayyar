from django.urls import path

from clustering.views import BookTripView

urlpatterns = [
    path('book/', BookTripView.as_view(), name='book_trip'),
]
