import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late GoogleMapController mapController;
  LatLng selectedLocation = LatLng(
    21.3891,
    39.8579,
  ); // Default location (Jeddah)

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bankController = TextEditingController();
  final TextEditingController parentPhoneNumberController = TextEditingController();


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Student Signup", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("First Name", "Your Entry", firstNameController),
            _buildTextField("Last Name", "Your Entry", lastNameController),
            _buildTextField("Date of Birth", "DD-MM-YYYY", dateOfBirthController),
            _buildTextField("Phone Number", "+966 5x xxx xxxx", phoneNumberController),
            _buildTextField("Email", "example@example.com", emailController),
            _buildTextField("Password", "Your Password", passwordController, obscureText: true),
            _buildTextField("University", "Your University", universityController),
            _buildTextField("City", "Your City", cityController),
            _buildTextField("District", "Your District", districtController),
            _buildTextField("Location", "Your Location", locationController),
            _buildTextField("Bank", "Your Bank", bankController),
            _buildTextField("Parent Phone Number", "Parent Phone Number", parentPhoneNumberController),
            SizedBox(height: 20),

            Text(
              "Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: selectedLocation,
                      zoom: 12.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("selected-location"),
                        position: selectedLocation,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() {
                            selectedLocation = newPosition;
                          });
                        },
                      ),
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      color: Colors.white.withValues(alpha:0.8),
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          "Drag the pin to select location",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Handle Sign-Up Logic
                signupStudent(
                  email: emailController.text,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  phoneNumber: phoneNumberController.text,
                  dateOfBirth: dateOfBirthController.text,
                  password: passwordController.text,
                  university: universityController.text,
                  city: cityController.text,
                  district: districtController.text,
                  location: locationController.text,
                  bank: bankController.text,
                  parentPhoneNumber: parentPhoneNumberController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Sign Up", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}


Future<void> signupStudent({
  required String email,
  required String firstName,
  required String lastName,
  required String phoneNumber,
  required String dateOfBirth,
  required String password,
  required String university,
  required String city,
  required String district,
  required String location,
  required String bank,
  required String parentPhoneNumber,
}) async {
  final url = Uri.parse('http://localhost:8000/signup/student/');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user': {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth,
        'password': password,
      },
      'university': university,
      'city': city,
      'district': district,
      'location': location,
      'bank': bank,
      'parent_phone_number': parentPhoneNumber,
    }),
  );

  if (response.statusCode == 201) {
    print('Signup successful');
  } else {
    print('Signup failed: ${response.body}');
  }
}