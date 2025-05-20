import datetime

import environ
import hdbscan
import jwt
import numpy as np
from django.contrib.gis.geos import MultiPoint, Point
from django.utils import timezone

from businesses.models import University
from users.models import Driver
from rest_framework.decorators import api_view
from rest_framework.generics import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import viewsets

from .models import Trip, Booking, TripCluster

from .serializers import TripsSerializer
from .utils.clustering import cluster_students_for_trip

env = environ.Env()

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

        trip_time = datetime.datetime.strptime(trip_time, '%H:%M:%S').time()

        to_location = Point(to_location[1], to_location[0])
        from_location = Point(from_location[1], from_location[0])

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


class OptimizeRoutesView(APIView):

    def get(self, request):
        trip_id = request.query_params.get('trip_id')
        recluster = bool(request.query_params.get('recluster'))

        if not TripCluster.objects.filter(trip_id=trip_id).exists() or recluster:
            cluster_students_for_trip(trip_id)
            print('clustered\n')

        university = University.objects.get(id=3)

        trip_clusters = TripCluster.objects.select_related('driver').prefetch_related('students').filter(
            trip_id=trip_id
        )
        trip_clusters_dict = {}

        for cluster in trip_clusters:
            driver_name = f"{cluster.driver.user.first_name} {cluster.driver.user.last_name}"

            if not cluster.route:
                continue  # Skip clusters without a route

            # Get the route from the backend as list of coordinates
            ordered_coords = list(cluster.route.coords)  # [(lng, lat), (lng, lat), ...]

            trip_clusters_dict[driver_name] = {
                "ordered_coordinates": ordered_coords,
                "driver_location": [cluster.driver.location.x, cluster.driver.location.y],
                "university_location": [university.location.x, university.location.y]
            }

        return Response(trip_clusters_dict)


class TripsViewset(viewsets.ModelViewSet):
    serializer_class = [TripsSerializer]
    queryset = Trip.objects.all()
    def get_queryset(self):
        return Trip.objects.all()

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()

        serializer = TripsSerializer(queryset, many=True)
        page = self.paginate_queryset(queryset)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def retrieve(self, request, *args, **kwargs):
        trip_id = self.kwargs.get('pk')
        trip = get_object_or_404(Trip, id=trip_id)

        bookings = Booking.objects.select_related('student', 'trip', 'cluster').filter(trip=trip)

        students_list = [f"{booking.student.user.first_name} {booking.student.user.last_name}" for booking in bookings]
        student_count = len(students_list)
        student_locations = [
            {
                'latitude': booking.student.location.y,
                'longitude': booking.student.location.x
            }
            for booking in bookings
        ]

        drivers_list = [f"{driver.user.first_name} {driver.user.last_name}" for driver in Driver.objects.filter(is_available=True)]

        return Response(
            {
                'trip_type': "Outgoing" if trip.direction == "OUT" else "Return",
                'student_count': student_count,
                'student_locations': student_locations,
                "students_list": students_list,
                "drivers_list": drivers_list
            }
        )

