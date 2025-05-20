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
    direction = models.CharField(max_length=3, choices=DIRECTION_CHOICES)
    time = models.TimeField()  # e.g. 06:00:00, 08:00:00


class TripCluster(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='clusters')
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='clusters')
    students = models.ManyToManyField('users.Student', related_name='clusters')
    centroid = geomodels.PointField(geography=True, null=True, blank=True)
    route = geomodels.LineStringField(geography=True, null=True, blank=True)  # use this to store path
    active = models.BooleanField(default=False)
    duration = models.DurationField(null=True, blank=True)


class Booking(models.Model):
    student = models.ForeignKey('users.Student', on_delete=models.DO_NOTHING)
    trip = models.ForeignKey(Trip, on_delete=models.SET_NULL, null=True, blank=True)
    cluster = models.ForeignKey(TripCluster, on_delete=models.SET_NULL, null=True, blank=True)
    from_location = geomodels.PointField()
    to_location = geomodels.PointField()
    weekdays = models.JSONField()  # e.g. ["Monday", "Wednesday"]

    def __str__(self):
        return f"{self.student.user.first_name} booked for {self.trip}"


# from users.models import Student
# from businesses.models import University
# from clustering.models import Trip
# from clustering.models import Booking
# university = University.objects.get(id=3)
# students = [s for s in Student.objects.filter(university_id=3)]
#
# students = [s for s in Student.objects.filter(subscribed_company_id=2)]
# trip = Trip.objects.get(id=1)
# bookings = [Booking(student=s, from_location=s.location, to_location=university.location, trip=trip, weekdays=['Sunday']) for s in students]
# Booking.objects.bulk_create(bookings)