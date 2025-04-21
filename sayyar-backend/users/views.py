import datetime

import environ

import firebase_admin
from django.contrib.auth.hashers import make_password
from firebase_admin import credentials
from django.contrib.auth import authenticate, get_user_model
from rest_framework.views import APIView
from .serializers import StudentSerializer
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


class LoginView(APIView):

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        user = authenticate(username=email, password=password)  # Assumes email is used as username

        if (not user) or (not user.check_password(password)):
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
        #
        # refresh = RefreshToken.for_user(user)  # JWT Token generation
        # return Response({
        #     'token': str(refresh.access_token),
        #     'refresh': str(refresh),
        # })



class RegisterView(APIView):
    """
    Allows users to sign up using Email & Password (Django authentication).
    """

    def post(self, request):
        data = request.data

        if "email" in data and "password" in data:
            return self.django_signup(data["email"], data["password"], data.get("username", ""))

        return Response(
            {"error": "Invalid request. Provide valid 'email' & 'password'"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    def django_signup(self, email, password, username):
        """Handle Signup using Email & Password"""
        if User.objects.filter(email=email).exists():
            return Response({"error": "Email already in use"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create(email=email, password=make_password(password))
        tokens = get_tokens_for_user(user)

        return Response({"message": "Signup successful", "jwt": tokens}, status=status.HTTP_201_CREATED)

class StudentRegisterView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = StudentSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)