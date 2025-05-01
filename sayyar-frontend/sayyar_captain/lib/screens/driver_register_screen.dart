import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  _DriverRegisterScreenState createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final companyController = TextEditingController();
  final licenceNumberController = TextEditingController();

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    String result = await registerDriver(
      emailController.text,
      firstNameController.text,
      lastNameController.text,
      phoneNumberController.text,
      passwordController.text,
      companyController.text,
      licenceNumberController.text,
      context,
    );

    setState(() {
      _isLoading = false;
    });
    if (!result.startsWith("Error")) {

    } else {
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Register as a Driver",
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
                  InputField(
                    label: "Company",
                    hintText: "e.g.: Jeddah",
                    controller: companyController,
                    icon: Icons.business,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Company is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  InputField(
                    label: "Licence Number",
                    controller: licenceNumberController,
                    icon: Icons.directions_car,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Licence Number is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
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

Future<String> registerDriver(
    String email,
    String firstName,
    String lastName,
    String phoneNumber,
    String password,
    String company,
    String licence_number,
    BuildContext context,
    ) async {
  const String apiUrl = 'http://192.168.0.156:8000/api/register/driver/';
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
        'company': company,
        'licence_number': licence_number,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return 'Signup successful';
    } else {
      return 'Error: Signup failed: ${response.body}';
    }
  } on TimeoutException catch (_) {
    return "Error: Signup timed out. Please try again.";
  } catch (error) {
    return "Error: Failed to connect: $error";
  }
}
