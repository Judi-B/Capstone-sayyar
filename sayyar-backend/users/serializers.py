from django.contrib.gis.geos import Point
from django.db import transaction
from rest_framework import serializers
from .models import User, Student
from rest_framework_gis.serializers import GeoFeatureModelSerializer

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'email',
            'first_name',
            'last_name',
            'phone_number',
            'password'
        ]
        extra_kwargs = {
            'password': {
                'write_only': True
            }
        }

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        instance = self.Meta.model(**validated_data)
        if password is not None:
            instance.set_password(password)
        instance.save()
        return instance

class StudentSerializer(serializers.ModelSerializer):

    user = UserSerializer()

    class Meta:
        model = Student
        fields = [
            'user',
            'university',
            'city',
            'district',
            'location',
            'parent_phone_number'
        ]

    def create(self, validated_data):
        with transaction.atomic():
            location_data = validated_data.pop('location', None)

            validated_data['location'] = Point(location_data['lng'], location_data['lat'])
            user_data = validated_data.pop('user')
            user = User.objects.create_user(**user_data)
            student = Student.objects.create(user=user, **validated_data)
            return student