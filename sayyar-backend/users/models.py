from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.gis.db import models
from django.db.models import TextChoices

from businesses.models import Company


class UniversityChoices(TextChoices):
    kau = "KAU", "King Abdulaziz University"
    dah = "DAH", "Dar Al-Hekma University"

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

        user = self.model(phone_number=phone_number, email=email, first_name=first_name, last_name=last_name)
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
    auth_token = models.CharField(max_length=255, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    updated_at = models.DateTimeField(auto_now=True, blank=True, null=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'phone_number']

    objects = CustomUserManager()

    def __str__(self):
        return f"User: {self.id}, Name: {self.first_name} {self.last_name}, Phone Number: {self.phone_number}"

# Student model
class Student(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    university = models.CharField(max_length=255, choices=UniversityChoices)
    city = models.CharField(max_length=255)
    district = models.CharField(max_length=255)
    location = models.PointField(geography=True)
    bank = models.CharField(max_length=255, blank=True, null=True)
    parent_phone_number = models.CharField(max_length=100, blank=True, null=True)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.user = User.objects.create(
                email=kwargs.get("email"),
                first_name=kwargs.get("first_name"),
                last_name=kwargs.get("last_name"),
                phone_number=kwargs.get("phone_number")
            )
        super().save(*args, **kwargs)
    class Meta:
        permissions = [
            ("edit_student", "Can edit student"),
        ]

    def __str__(self):
        return f"Student: {self.user.first_name} {self.user.last_name}"


# Employee model
class Employee(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    role = models.CharField(max_length=255)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.user = User.objects.create(
                email=kwargs.get("email"),
                first_name=kwargs.get("first_name"),
                last_name=kwargs.get("last_name"),
                phone_number=kwargs.get("phone_number")
            )
        super().save(*args, **kwargs)

    class Meta:
        permissions = [
            ("edit_employee", "Can edit employee"),
        ]

    def __str__(self):
        return f"Employee: {self.user.first_name} {self.user.last_name}, Role: {self.role}"


# Driver model
class Driver(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    license_number = models.CharField(max_length=255)
    status = models.CharField(max_length=255, null=True, blank=True)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.user = User.objects.create(
                email=kwargs.get("email"),
                first_name=kwargs.get("first_name"),
                last_name=kwargs.get("last_name"),
                phone_number=kwargs.get("phone_number")
            )
        super().save(*args, **kwargs)

    class Meta:
        permissions = [
            ("edit_driver", "Can edit driver"),
        ]

    def __str__(self):
        return f"Driver: {self.user.first_name} {self.user.last_name}, License: {self.license_number}"