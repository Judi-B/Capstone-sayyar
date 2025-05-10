import datetime

import environ
from django.db import transaction
from django.utils import timezone
from rest_framework.views import APIView

from businesses.models import Company
from .models import Student, Employee, Driver, User
from .serializers import StudentSerializer, EmployeeSerializer, DriverSerializer, StudentLoginSerializer, \
    ContactsSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
import jwt

env = environ.Env()



def get_tokens_for_user(user):
    """Generate JWT tokens for the authenticated user"""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class StudentLoginView(APIView):

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        user = User.objects.get(email=email)

        student = Student.objects.filter(user=user).first()  # Assumes email is used as username

        if (not student) or (not user.check_password(password)):
            return Response({'error': 'Invalid credentials'}, status=400)

        now = timezone.now()

        payload = {
            "id": user.id,
            "exp": now + datetime.timedelta(days=1),
            "iat": now,
        }

        token = jwt.encode(payload, env("SECRET_KEY"), algorithm='HS256')

        response = Response()
        response.set_cookie(key="jwt", value=token, httponly=True)
        response.data = StudentLoginSerializer(student, context={'token': token}).data
        return response


class StudentSubscribeView(APIView):
    def post(self, request):
        company_name = request.data.get('company_name')
        token = request.headers.get('Authorization')

        decoded_token = jwt.decode(token, env("SECRET_KEY"), algorithms=['HS256'])
        user_id = decoded_token['id']
        user = User.objects.get(id=user_id)
        student = Student.objects.filter(user=user).first()
        with transaction.atomic():
            try:
                student.subscribed_company = Company.objects.filter(name=company_name).first()
                student.is_subscribed = True
                student.save()
            except Exception as e:
                return Response({'error': str(e)}, status=400)
        return Response({'message': 'Student subscribed successfully'}, status=status.HTTP_200_OK)


class StudentProfileView(APIView):
    def get(self, request):
        token = request.headers.get('Authorization')
        decoded_token = jwt.decode(token, env("SECRET_KEY"), algorithms=['HS256'])
        user_id = decoded_token['id']
        user = User.objects.get(id=user_id)
        student = Student.objects.filter(user=user).first()

        return Response({
            'name': f'{user.first_name} {user.last_name}',
            'email': user.email,
            'university': student.university,
            'phone': user.phone_number,
            'company_name': student.subscribed_company.name,
            'city': student.city,
            'district': student.district,
        })


class EmployeeLoginView(APIView):

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        user = User.objects.get(email=email)

        employee = Employee.objects.filter(user=user).first()  # Assumes email is used as username

        if (not employee) or (not user.check_password(password)):
            return Response({'error': 'Invalid credentials'}, status=400)

        now = datetime.datetime.now()

        payload = {
            "id": user.id,
            "exp": now + datetime.timedelta(days=1),
            "iat": now,
        }

        token = jwt.encode(payload, env("SECRET_KEY"), algorithm='HS256')

        response = Response()
        response.set_cookie(key="jwt", value=token, httponly=True)
        response.data = {
            "token": token
        }
        return response

class DriverLoginView(APIView):

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        user = User.objects.get(email=email)

        driver = Driver.objects.filter(user=user).first()  # Assumes email is used as username

        if (not driver) or (not user.check_password(password)):
            return Response({'error': 'Invalid credentials'}, status=400)

        now = timezone.now()

        payload = {
            "id": user.id,
            "exp": now + datetime.timedelta(days=1),
            "iat": now,
        }

        token = jwt.encode(payload, env("SECRET_KEY"), algorithm='HS256')

        response = Response()
        response.set_cookie(key="jwt", value=token, httponly=True)
        response.data = {
            "token": token,
            "first_name": user.first_name,
        }
        return response


class DriverProfileDataView(APIView):
    def get(self, request):
        token = request.headers.get('Authorization')
        decoded_token = jwt.decode(token, env("SECRET_KEY"), algorithms=['HS256'])
        user_id = decoded_token['id']
        user = User.objects.get(id=user_id)
        driver = Driver.objects.filter(user=user).first()

        return Response({
            'name': f'{user.first_name} {user.last_name}',
            'email': user.email,
            'licence_number': driver.licence_number,
            'phone': user.phone_number,
            'company_name': driver.company.name,
            'vehicle_plate': driver.vehicle_plate,
        })



class StudentRegisterView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = StudentSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class EmployeeRegisterView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = EmployeeSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DriverRegisterView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = DriverSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ContactsView(APIView):
    def get(self, request):
        token = request.headers.get('Authorization')
        decoded_token = jwt.decode(token, env("SECRET_KEY"), algorithms=['HS256'])
        user_id = decoded_token['id']
        users = User.objects.exclude(id=user_id).all()
        serializer = ContactsSerializer(users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
