import json

from django.contrib.gis.geos import GEOSGeometry
import environ
import hdbscan

from django.utils import timezone
from sklearn.cluster import KMeans
from collections import defaultdict

from geopy.distance import geodesic
import numpy as np

from sklearn.preprocessing import StandardScaler
import requests

from businesses.models import University
from ..models import Booking, Trip, TripCluster
from users.models import Driver

env = environ.Env()

def format_duration(seconds):
    minutes = seconds // 60
    remaining_seconds = seconds % 60
    return f"{minutes} Minutes, {remaining_seconds:.1f} seconds"


def cluster_students_for_trip(trip_id):
    trip = Trip.objects.get(id=trip_id)
    bookings = Booking.objects.filter(trip=trip)

    university = University.objects.get(id=3)

    # Step 1: Prepare the coordinates
    coordinates = []
    student_ids = []
    for b in bookings:
        lng, lat = b.from_location.x, b.from_location.y
        coordinates.append([lng, lat])
        student_ids.append(b.student.user_id)

    if len(coordinates) < 2:
        return  # Not enough data to cluster

    # Step 2: Run clustering
    available_drivers = list(Driver.objects.filter(is_available=True))
    if len(available_drivers) == 0:
        return

    scaler = StandardScaler()
    coords_scaled = scaler.fit_transform(coordinates)
    clusterer = hdbscan.HDBSCAN(min_cluster_size=2, metric='haversine', max_cluster_size=12, cluster_selection_method='leaf')
    labels = clusterer.fit_predict(coords_scaled)


    noise_points = []
    clusters = defaultdict(list)
    for label, student_id, coord in zip(labels, student_ids, coordinates):
        if label == -1:
            noise_points.append((student_id, coord))
            continue
        clusters[label].append((student_id, coord))

    clusters = merge_clusters(clusters, len(available_drivers))
    clusters = split_largest_clusters(clusters, len(available_drivers))

    centroids = {
        label: np.mean([coord for _, coord in members], axis=0)
        for label, members in clusters.items()
    }

    for student_id, noise_coord in noise_points:
        closest_label = min(
            centroids.keys(),
            key=lambda label: geodesic(noise_coord[::-1], centroids[label][::-1]).meters
        )
        clusters[closest_label].append((student_id, noise_coord))

    print('\nno of clusters:', len(clusters), '\n')

    for label, students in clusters.items():
        if not available_drivers:
            break  # No more drivers to assign

        driver = available_drivers.pop(0)
        cluster = TripCluster.objects.create(trip=trip, driver=driver)

        for student_id, _ in students:
            cluster.students.add(student_id)

        for _, (lng, lat) in students:
            assert -90 <= lat <= 90, f"Invalid latitude: {lat}"
            assert -180 <= lng <= 180, f"Invalid longitude: {lng}"

        # Step 4: Generate route using Mapbox API
        origin = [driver.location.x, driver.location.y]
        waypoints = [coord for _, coord in students[1:]]
        destination = [university.location.x, university.location.y]  # replace with actual endpoint

        coordinates = [origin] + waypoints + [destination]
        coord_str = ";".join(f"{lng},{lat}" for lng, lat in coordinates)

        optimize_url = (
            f"https://api.mapbox.com/optimized-trips/v1/mapbox/driving/{coord_str}"
            f"?source=first&destination=last&roundtrip=false&geometries=geojson&access_token={env('MAPBOX_TOKEN')}"
        )

        response = requests.get(optimize_url)

        data = response.json()
        print(data, '\n')
        if data.get("code") != "Ok":
            print("Mapbox API error:", data.get("message", "Unknown error"))
            continue  # Skip this cluster
        if data["code"] == 'Ok':
            line_string_points = data["trips"][0]["geometry"]["coordinates"]

            geojson_line = {
                "type": "LineString",
                "coordinates": line_string_points  # from Mapbox
            }

            geometry = GEOSGeometry(json.dumps(geojson_line), srid=4326)
            cluster.route = geometry

            duration_seconds = data["trips"][0]["duration"]
            cluster.duration = timezone.timedelta(seconds=duration_seconds)
            cluster.save()


def merge_clusters(clusters, target_count):
    while len(clusters) > target_count:
        # Compute centroids
        centroids = {
            label: np.mean([coord for _, coord in members], axis=0)
            for label, members in clusters.items()
        }

        # Find closest pair of clusters
        labels_list = list(centroids.keys())
        min_distance = float("inf")
        to_merge = (None, None)

        for i in range(len(labels_list)):
            for j in range(i + 1, len(labels_list)):
                c1, c2 = labels_list[i], labels_list[j]
                dist = geodesic(centroids[c1][::-1], centroids[c2][::-1]).meters
                if dist < min_distance:
                    min_distance = dist
                    to_merge = (c1, c2)

        # Merge clusters
        l1, l2 = to_merge
        clusters[l1].extend(clusters[l2])
        del clusters[l2]

    return clusters


def split_largest_clusters(clusters, target_count):
    while len(clusters) < target_count:
        # Find the largest cluster
        largest_label = max(clusters, key=lambda l: len(clusters[l]))
        largest_cluster = clusters.pop(largest_label)

        coords = np.array([coord for _, coord in largest_cluster])
        ids = [sid for sid, _ in largest_cluster]

        if len(coords) < 2:
            clusters[largest_label] = largest_cluster  # put it back
            break

        kmeans = KMeans(n_clusters=2, n_init='auto').fit(coords)
        new_labels = kmeans.labels_

        label_a = max(clusters.keys(), default=0) + 1
        label_b = label_a + 1

        clusters[label_a] = [(ids[i], coords[i].tolist()) for i in range(len(ids)) if new_labels[i] == 0]
        clusters[label_b] = [(ids[i], coords[i].tolist()) for i in range(len(ids)) if new_labels[i] == 1]

    return clusters


def clean_coordinates_with_map_matching(coords):
    """
    Snap raw coordinates to the road network using Mapbox Map Matching API.
    Input: list of [lng, lat] pairs.
    Output: list of [lng, lat] pairs snapped to the nearest road.
    """
    if len(coords) < 2:
        return coords  # too few points to map match

    coord_str = ";".join(f"{lng},{lat}" for lng, lat in coords)
    url = (
        f"https://api.mapbox.com/matching/v5/mapbox/driving/{coord_str}"
        f"?geometries=geojson&tidy=true&access_token={env('MAPBOX_TOKEN')}"
    )

    try:
        response = requests.get(url)
        data = response.json()

        if data.get("code") == "Ok" and data.get("matchings"):
            return data["matchings"][0]["geometry"]["coordinates"]
        else:
            print("Map matching failed:", data.get("message", "Unknown error"))
    except Exception as e:
        print("Map matching error:", str(e))

    return coords  # fallback to original if anything goes wrong
