from django.contrib.gis.geos import Point
from django.db import transaction
from rest_framework import serializers

from businesses.models import Company
from .models import User, Student, Employee, Driver
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


class StudentLoginSerializer(serializers.ModelSerializer):

    token = serializers.SerializerMethodField()
    first_name = serializers.CharField(source='user.first_name')
    is_subscribed = serializers.BooleanField()
    subscribed_company = serializers.CharField(source='subscribed_company.name')

    class Meta:
        model = Student
        fields = [
            'token',
            'first_name',
            'is_subscribed',
            'subscribed_company'
        ]

    def get_token(self, obj):
        return self.context.get('token')



class EmployeeSerializer(serializers.ModelSerializer):

    user = UserSerializer()
    role = serializers.CharField(max_length=255)
    company = serializers.CharField(max_length=255)

    class Meta:
        model = Employee
        fields = [
            'user',
            'role',
            'company'
        ]

    def create(self, validated_data):
        with transaction.atomic():
            company_name = validated_data.pop('company', None)
            if company_name and Company.objects.filter(name=company_name).exists():
                validated_data['company'] = Company.objects.get(name=company_name)
            user_data = validated_data.pop('user')
            user = User.objects.create_user(**user_data)
            employee = Employee.objects.create(user=user, **validated_data)
            return employee


class DriverSerializer(serializers.ModelSerializer):

    user = UserSerializer()
    licence_number = serializers.CharField(max_length=255)
    company = serializers.CharField(max_length=255)

    class Meta:
        model = Driver
        fields = [
            'user',
            'licence_number',
            'company'
        ]

    def create(self, validated_data):
        with transaction.atomic():
            company_name = validated_data.pop('company', None)
            if company_name and Company.objects.filter(name=company_name).exists():
                validated_data['company'] = Company.objects.get(name=company_name)
            user_data = validated_data.pop('user')
            user = User.objects.create_user(**user_data)
            driver = Driver.objects.create(user=user, **validated_data)
            return driver


class ContactsSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField()
    name = serializers.SerializerMethodField()
    phone_number = serializers.CharField()
    role = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'name',
            'phone_number',
            'role'
        ]
    def get_name(self, obj):
        return f'{obj.first_name} {obj.last_name}'

    def get_role(self, obj):
        if Student.objects.filter(user=obj).exists():
            return 'student'
        elif Employee.objects.filter(user=obj).exists():
            return 'employee'
        else:
            return 'driver'
