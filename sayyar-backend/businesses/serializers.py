from rest_framework import serializers

from businesses.models import University


class UniversitySerializer(serializers.ModelSerializer):
    lat = serializers.SerializerMethodField()
    lon = serializers.SerializerMethodField()
    class Meta:
        model = University
        fields = [
            'name',
            'lat',
            'lon'
        ]

    def get_lat(self, obj):
        return obj.location.y

    def get_lon(self, obj):
        return obj.location.x