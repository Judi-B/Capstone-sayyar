import datetime

import environ

import firebase_admin
from firebase_admin import credentials
from django.contrib.auth import get_user_model
from rest_framework.views import APIView

from .models import Student, Employee, Driver
from .serializers import StudentSerializer, EmployeeSerializer, DriverSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
import jwt

env = environ.Env()

# Initialize Firebase Admin SDK
cred = credentials.Certificate(env("FIREBASE_API_JSON_PATH"))
firebase_admin.initialize_app(cred)

User = get_user_model()


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
            "token": token,
            "first_name": user.first_name,
            "is_subscribed": student.is_subscribed,
            "subscribed_company": student.subscribed_company,
        }
        return response

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