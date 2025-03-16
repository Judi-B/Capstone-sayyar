import environ

import firebase_admin
from django.contrib.auth.hashers import make_password
from firebase_admin import credentials, auth as firebase_auth
from django.contrib.auth import authenticate, get_user_model
from rest_framework.views import APIView
from .serializers import StudentSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

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
    """
    Supports two login methods:
    1. Google Authentication using Firebase ID token.
    2. Django Authentication using email & password.
    """

    def post(self, request):
        data = request.data

        if "firebase_token" in data:
            return self.google_login(data["firebase_token"])

        elif "email" in data and "password" in data:
            return self.django_login(data["email"], data["password"])

        return Response(
            {"error": "Invalid request, provide either 'firebase_token' or 'email' & 'password'"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    def google_login(self, firebase_token):
        """Handle Google Login using Firebase Token"""
        try:
            decoded_token = firebase_auth.verify_id_token(firebase_token)
            uid = decoded_token.get("uid")
            email = decoded_token.get("email")
            name = decoded_token.get("name")

            if not email:
                return Response({"error": "Email not found in Firebase response"}, status=status.HTTP_400_BAD_REQUEST)

            # Create or retrieve user
            user, created = User.objects.get_or_create(email=email, defaults={"username": name})

            # Generate JWT
            tokens = get_tokens_for_user(user)
            return Response({"message": "Google login successful", "jwt": tokens}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    def django_login(self, email, password):
        """Handle Django Authentication using Email & Password"""
        user = authenticate(username=email, password=password)
        if user is not None:
            tokens = get_tokens_for_user(user)
            return Response({"message": "Django login successful", "jwt": tokens}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "Invalid email or password"}, status=status.HTTP_400_BAD_REQUEST)


class SignupView(APIView):
    """
    Allows users to sign up using:
    1. Email & Password (Django authentication).
    2. Google Authentication (Firebase token).
    """

    def post(self, request):
        data = request.data

        if "firebase_token" in data:
            return self.google_signup(data["firebase_token"])

        elif "email" in data and "password" in data:
            return self.django_signup(data["email"], data["password"], data.get("username", ""))

        return Response(
            {"error": "Invalid request. Provide either 'firebase_token' or 'email' & 'password'"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    def google_signup(self, firebase_token):
        """Handle Signup using Google Firebase Token"""
        try:
            decoded_token = firebase_auth.verify_id_token(firebase_token)
            uid = decoded_token.get("uid")
            email = decoded_token.get("email")
            name = decoded_token.get("name", "User")

            if not email:
                return Response({"error": "Email not found in Firebase response"}, status=status.HTTP_400_BAD_REQUEST)

            # Create user if not exists
            user, created = User.objects.get_or_create(email=email, defaults={"username": name})

            # Generate JWT
            tokens = get_tokens_for_user(user)
            return Response({"message": "Signup successful", "jwt": tokens}, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    def django_signup(self, email, password, username):
        """Handle Signup using Email & Password"""
        if User.objects.filter(email=email).exists():
            return Response({"error": "Email already in use"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create(email=email, password=make_password(password))
        tokens = get_tokens_for_user(user)

        return Response({"message": "Signup successful", "jwt": tokens}, status=status.HTTP_201_CREATED)

class StudentSignupView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = StudentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)