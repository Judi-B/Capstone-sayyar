import environ
import hdbscan
import jwt
import numpy as np
from django.contrib.gis.geos import MultiPoint
from rest_framework.decorators import api_view
from rest_framework.generics import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from users.models import User
from .models import Trip, Booking, TripCluster
from django.utils.dateparse import parse_date


env = environ.Env()

@api_view(['POST'])
def cluster_bookings_for_trip(request):
    trip_id = request.data.get("trip_id")
    trip = get_object_or_404(Trip, id=trip_id)

    bookings = Booking.objects.filter(trip=trip, cluster__isnull=True)
    if not bookings:
        return Response({"message": "No unclustered bookings for this trip."})

    coords = np.array([[b.location.y, b.location.x] for b in bookings])
    clusterer = hdbscan.HDBSCAN(min_cluster_size=3)
    labels = clusterer.fit_predict(coords)

    clusters = {}
    for i, label in enumerate(labels):
        if label == -1:
            continue  # noise
        clusters.setdefault(label, []).append(bookings[i])

    for label, cluster_bookings in clusters.items():
        points = [b.location for b in cluster_bookings]
        centroid = MultiPoint(points).centroid

        trip_cluster = TripCluster.objects.create(
            trip=trip,
            centroid=centroid,
            # driver can be auto-assigned here if desired
        )

        for booking in cluster_bookings:
            booking.cluster = trip_cluster
            booking.save()

        # Route generation using Google Maps can be triggered here

    return Response({"message": f"{len(clusters)} clusters created for trip {trip.id}."})


class BookTripView(APIView):

    """
    {
        "student_id": student_id,
        "trip_id": trip_id,
        "date": date,
        "is_recurring": is_recurring,
        "weekdays": [
            "Sunday",
            "Tuesday"
        ]
    }
    """
    def post(self, request):
        trip_type = request.data.get("trip_type")
        trip_time = request.data.get("trip_time")
        from_location = request.data.get("from_location", False)
        to_location = request.data.get("to_location", False)
        weekdays = request.data.get("weekdays", [])

        token = request.headers.get('Authorization')

        decoded_token = jwt.decode(token, env("SECRET_KEY"), algorithms=['HS256'])
        user_id = decoded_token['id']

        trip = Trip.objects.filter(direction=trip_type, time=trip_time).first()

        booking = Booking.objects.create(
            student_id=user_id,
            trip=trip,
            from_location=from_location,
            to_location=to_location,
            weekdays=weekdays
        )

        return Response({"message": "Trip booked successfully"}, status=status.HTTP_201_CREATED)
