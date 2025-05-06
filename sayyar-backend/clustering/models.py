from django.db import models
from django.contrib.gis.db import models as geomodels
from users.models import Driver, Student
from django.utils import timezone

DIRECTION_CHOICES = [
        ('OUT', 'Outgoing'),
        ('RET', 'Return'),
    ]


class Trip(models.Model):

    name = models.CharField(max_length=120)
    date = models.DateField()
    direction = models.CharField(max_length=3, choices=DIRECTION_CHOICES)
    time = models.TimeField()  # e.g. 06:00:00, 08:00:00


class TripCluster(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='clusters')
    drivers = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='trips')
    students = models.ForeignKey('users.Student', on_delete=models.CASCADE)
    centroid = geomodels.PointField(geography=True, null=True, blank=True)
    route = geomodels.LineStringField(geography=True, null=True, blank=True)  # use this to store path
    active = models.BooleanField(default=False)


class Booking(models.Model):
    student = models.ForeignKey('users.Student', on_delete=models.CASCADE)
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE)
    cluster = models.ForeignKey(TripCluster, on_delete=models.CASCADE)
    from_location = geomodels.PointField()
    to_location = geomodels.PointField()
    date = models.DateField()
    is_recurring = models.BooleanField(default=False)
    weekdays = models.JSONField(blank=True, null=True)  # e.g. ["Monday", "Wednesday"]

    def __str__(self):
        return f"{self.student.user.first_name} booked for {self.trip} on {self.date}"
