import 'dart:async';
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../session_manager.dart';
import 'home_screen.dart';
import 'student_register_screen.dart';
import 'transport_companies_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  _StudentLoginScreenState createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String result = await loginStudent(
      emailController.text,
      passwordController.text,
      context,
    );

    setState(() {
      _isLoading = false;
    });
    if (!result.startsWith("Error")) {
      Fluttertoast.showToast(
        msg: "Successfully Logged In."
      );
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('is_subscribed')!) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TransportCompaniesScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: result
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Flexible(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color(0xFFFFFFFF),
                      child: Image.asset(
                          'assets/images/logo_white_back.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Welcome Back, Commuter!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Zen Dots",
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        controller: emailController,
                        label: "Email",
                        hintText: "example@example.com",
                        icon: Icons.mail,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Email cannot be empty";
                          }
                          if (!EmailValidator.validate(text)) {
                            return "Invalid Email Format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot your password?",
                            style: TextStyle(color: Color(0xFF907FFD)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        text: _isLoading ? "Logging in..." : "Log In",
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          _isLoading ? null : _handleLogin();
                        },
                        color:
                            _isLoading ? Colors.grey : const Color(0xFFC2EA4C),
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "New to Sayyar? Sign up",
                          style: TextStyle(color: Color(0xFF907FFD)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransportCompaniesScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Continue as a Guest",
                          style: TextStyle(color: Color(0xFF907FFD)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500),
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

Future<String> loginStudent(
  String email,
  String password,
  BuildContext context,
) async {
  const String apiUrl =
      'http://192.168.0.156:8000/api/login/student/'; // Change this to your actual backend URL

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // Successful login
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      final name = responseData['first_name'];
      final isSubscribed = responseData['is_subscribed'];
      final subscribedCompany = responseData['subscribed_company'];
      if (token != null) {
        await SessionManager.saveToken(token, name, isSubscribed, subscribedCompany);
        return "Login successful!";
      } else {
        return "Error: Token not found in response.";
      }
    } else {
      // Failed login
      return "Error: ${response.body}";
    }
  } on TimeoutException catch (_) {
    return "Error: Login timed out. Please try again.";
  }
    catch (error) {
    return "Error: $error";
  }
}
