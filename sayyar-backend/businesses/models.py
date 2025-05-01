from django.db import models

from django.contrib.gis.db import models


class Company(models.Model):
    name = models.CharField(max_length=255)
    bank = models.CharField(max_length=255, null=True, blank=True)


class University(models.Model):
    name = models.CharField(max_length=255)
    location = models.PointField()


