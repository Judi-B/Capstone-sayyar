from rest_framework import serializers

from clustering.models import Trip


class TripsSerializer(serializers.ModelSerializer):
    name = serializers.CharField()
    time = serializers.TimeField()
    id = serializers.IntegerField()
    class Meta:
        model = Trip
        fields = [
            'id',
            'name',
            'time',
        ]