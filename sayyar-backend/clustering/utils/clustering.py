import environ

import hdbscan
from sklearn.preprocessing import StandardScaler
import requests

from ..models import Booking, Trip, TripCluster
from users.models import Driver


env = environ.Env()


def cluster_students_for_trip(trip_id):
    trip = Trip.objects.get(id=trip_id)
    bookings = Booking.objects.filter(trip=trip)

    # Step 1: Prepare the coordinates
    coordinates = []
    student_ids = []
    for b in bookings:
        lng, lat = b.location.coords
        coordinates.append([lat, lng])
        student_ids.append(b.student.id)

    if len(coordinates) < 2:
        return  # Not enough data to cluster

    # Step 2: Run clustering
    scaler = StandardScaler()
    coords_scaled = scaler.fit_transform(coordinates)
    clusterer = hdbscan.HDBSCAN(min_cluster_size=2)
    labels = clusterer.fit_predict(coords_scaled)

    # Step 3: Group by cluster
    clusters = {}
    for label, student_id, coord in zip(labels, student_ids, coordinates):
        if label == -1:  # Noise
            continue
        clusters.setdefault(label, []).append((student_id, coord))

    available_drivers = list(Driver.objects.filter(is_available=True))

    for label, students in clusters.items():
        if not available_drivers:
            break  # No more drivers to assign

        driver = available_drivers.pop(0)
        cluster = TripCluster.objects.create(trip=trip, driver=driver)

        for student_id, _ in students:
            cluster.students.add(student_id)

        # Step 4: Generate route using Google Maps API
        origin = f"{students[0][1][0]},{students[0][1][1]}"
        waypoints = "|".join(f"{lat},{lng}" for _, (lat, lng) in students[1:])
        destination = "UNIVERSITY_LAT,UNIVERSITY_LNG"  # replace with actual endpoint

        directions_url = (
            "https://maps.googleapis.com/maps/api/directions/json"
            f"?origin={origin}&destination={destination}&waypoints={waypoints}"
            f"&key={env('GOOGLE_MAPS_API_KEY')}"
        )

        response = requests.get(directions_url)
        data = response.json()

        if data["status"] == "OK":
            polyline = data["routes"][0]["overview_polyline"]["points"]
            cluster.route_polyline = polyline
            cluster.save()
