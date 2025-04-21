import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sayyar_frontend/screens/onboarding_1.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  _StudentRegisterScreenState createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  late GoogleMapController mapController;
  LatLng selectedLocation = LatLng(
    21.3891,
    39.8579,
  ); // Default location (Jeddah)

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final universityController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final locationController = TextEditingController();
  final bankController = TextEditingController();
  final parentPhoneNumberController = TextEditingController();
  String? selectedUniversity;

  final List<Map<String, String>> universities = [
    {'value': 'KAU', 'label': 'King Abdulaziz University'},
    {'value': 'DAH', 'label': 'Dar Al-Hekma University'},
  ];

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    String result = await registerStudent(
      emailController.text,
      firstNameController.text,
      lastNameController.text,
      phoneNumberController.text,
      passwordController.text,
      selectedUniversity,
      cityController.text,
      districtController.text,
      selectedLocation,
      parentPhoneNumberController.text,
      context,
    );

    setState(() {
      _isLoading = false;
    });
    if (!result.startsWith("Error")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Onboarding1()),
      );
    } else {
      print(result);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Register as a Student",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Roboto",
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
          // elevation: 0,
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  InputField(
                    controller: firstNameController,
                    label: "First Name",
                    hintText: "e.g.: Ahmad",
                    icon: Icons.person,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "First Name is required";
                      }
                      if (RegExp(r"[^A-Za-z_]").hasMatch(text)) {
                        return "Invalid characters, allowed characters: A-Z, a-z, _";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  InputField(
                    controller: lastNameController,
                    label: "Last Name",
                    hintText: "e.g.: AlHarbi",
                    icon: Icons.person_outline,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Last name is required";
                      }
                      if (RegExp(r"[^A-Za-z_]").hasMatch(text)) {
                        return "Invalid characters, allowed characters: A-Z, a-z, _";
                      }
                      return null;
                    },
                  ), // Last Name Field
                  const SizedBox(height: 30),
                  IntlPhoneField(
                    initialCountryCode: "SA",
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "50 000 0000",
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: "Roboto",
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: "Roboto",
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: const Color(0xFF907FFD),
                          width: 2.0,
                        ), // Takes effect
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: const Color(0xFF907FFD),
                      ),
                    ),
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return "Phone Number is required";
                      }
                      if (!RegExp(r"^\d+$").hasMatch(phone.number)) {
                        return "Invalid Characters!";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 10),
                  InputField(
                    controller: emailController,
                    label: "Email",
                    hintText: "example@example.com",
                    icon: Icons.mail,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Email is required";
                      }
                      if (!EmailValidator.validate(text)) {
                        return "Invalid Email Format";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  InputField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Password cannot be empty";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "University",
                      hintText: "Dar Al-Hekma University",
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: "Roboto",
                      ),
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: "Roboto"),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: const Color(0xFF907FFD),
                          width: 2.0,
                        ), // Takes effect
                      ),
                      prefixIcon: Icon(Icons.school, color: const Color(0xFF907FFD)),
                    ),
                    value: selectedUniversity,
                    items:
                        universities.map((university) {
                          return DropdownMenuItem<String>(
                            value: university['value'],
                            child: Text(university['label']!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUniversity = value;
                      });
                    },
                    validator:
                      (value) =>
                          value == null ? 'Please select a university' : null,
                  ),
                  const SizedBox(height: 30),
                  InputField(
                    label: "City",
                    hintText: "e.g.: Jeddah",
                    controller: cityController,
                    icon: Icons.location_city,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "City is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  InputField(
                    label: "District",
                    hintText: "e.g.: Al Faisaliah",
                    controller: districtController,
                    icon: Icons.location_pin,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "District is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  IntlPhoneField(
                    controller: parentPhoneNumberController,
                    initialCountryCode: "SA",
                    decoration: InputDecoration(
                      labelText: "Guardian Phone Number (optional)",
                      hintText: "50 000 0000",
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: "Roboto",
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: "Roboto",
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: const Color(0xFF907FFD),
                          width: 2.0,
                        ), // Takes effect
                      ),
                      prefixIcon: Icon(
                        Icons.phonelink_lock_rounded,
                        color: const Color(0xFF907FFD),
                      ),
                    ),
                    validator: (phone) {
                      if ((phone != null) &&
                          !RegExp(r"^\d+$").hasMatch(phone.number)) {
                        return "Invalid Characters!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Text(
              "Location",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
              ),
            ),
            const SizedBox(height: 10),
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
                      color: Colors.white.withValues(alpha: 0.8),
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
            const SizedBox(height: 20),
            PrimaryButton(
              text: _isLoading ? "Signing Up..." : "Sign Up",
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _isLoading ? null : _handleRegister();
              },
              color: _isLoading ? Colors.grey : const Color(0xFFC2EA4C),
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?) validator;

  const InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.hintText = "",
    this.obscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontFamily: "Roboto",
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: "Roboto"),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: const Color(0xFF907FFD),
            width: 2.0,
          ), // Takes effect
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF907FFD)),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
          ),
        ),
      ),
    );
  }
}

Future<String> registerStudent(
  String email,
  String firstName,
  String lastName,
  String phoneNumber,
  String password,
  String? university,
  String city,
  String district,
  LatLng location,
  String parentPhoneNumber,
  BuildContext context,
) async {
  const String apiUrl = 'http://192.168.0.156:8000/api/register/student/';
  try {
    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user': {
              'email': email,
              'first_name': firstName,
              'last_name': lastName,
              'phone_number': phoneNumber,
              'password': password,
            },
            'university': university,
            'city': city,
            'district': district,
            'location': {"lat": location.latitude, "lng": location.longitude},
            'parent_phone_number': parentPhoneNumber,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return 'Signup successful';
    } else {
      return 'Error: Signup failed: ${response.body}';
    }
  } on TimeoutException catch (_) {
    return "Error: Login timed out. Please try again.";
  } catch (error) {
    return "Error: Failed to connect: $error";
  }
}
