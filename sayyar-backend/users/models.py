from django.db import models

# Create your models here.
from django.db import models
from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from rest_framework.fields import CharField


# This class is created to modify the authentication requirements
class CustomUserManager(BaseUserManager):
    def create_user(self, phone_number, email, first_name, last_name, password):
        if not phone_number:
            raise ValueError('A phone number is needed.')
        if not email:
            raise ValueError('An email is needed.')
        if not first_name:
            raise ValueError('Please enter your first name')
        if not last_name:
            raise ValueError('Please enter your last name.')
        if not password:
            raise ValueError('A password is needed.')

        user = self.model(email=email, first_name=first_name, last_name=last_name)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, phone_number, email, first_name, last_name, password):
        if not phone_number:
            raise ValueError('A phone number is needed.')
        if not email:
            raise ValueError('An email is needed.')
        if not first_name:
            raise ValueError('Please enter your first name')
        if not last_name:
            raise ValueError('Please enter your last name.')
        if not password:
            raise ValueError('A password is needed.')

        user = self.create_user(phone_number, email, first_name, last_name, password)
        user.is_superuser = True
        user.is_staff = True
        user.save()
        return user


# Custom user class
class User(AbstractBaseUser, PermissionsMixin):
    phone_number = models.CharField(max_length=100, null=True, blank=True, unique=True)
    first_name = models.CharField(max_length=255, null=False)
    last_name = models.CharField(max_length=255, null=False)
    email = models.EmailField(max_length=255, null=False, unique=True)
    date_of_birth = models.DateField(blank=True, null=True)
    auth_token = models.CharField(max_length=255, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    updated_at = models.DateTimeField(auto_now=True, blank=True, null=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'date_of_birth']

    objects = CustomUserManager()

    def __str__(self):
        return f"User: {self.id}, Name: {self.first_name} {self.last_name}, Phone Number: {self.phone_number}"
