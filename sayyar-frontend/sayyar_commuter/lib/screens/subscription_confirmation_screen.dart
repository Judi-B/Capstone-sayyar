import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sayyar_commuter/screens/student_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session_manager.dart';
import 'home_screen.dart';

class SubscriptionConfirmationScreen extends StatefulWidget {
  final String subscriptionPlan;
  final String companyName;

  const SubscriptionConfirmationScreen({super.key, required this.subscriptionPlan, required this.companyName});

  @override
  _SubscriptionConfirmationScreenState createState() => _SubscriptionConfirmationScreenState();
}

class _SubscriptionConfirmationScreenState extends State<SubscriptionConfirmationScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool authenticated = await SessionManager.isAuthenticated();
    await Future.delayed(Duration(milliseconds: 500));

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString("first_name") ?? '';
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentLoginScreen()),
      );
    }
  }

  void _handleSubscribe() async {
    setState(() {
      _isLoading = true;
    });

    String result = await subscribeStudent(
      widget.companyName,
      context,
    );

    setState(() {
      _isLoading = false;
    });
    if (!result.startsWith("Error")) {
      Fluttertoast.showToast(
          msg: "Successfully Subscribed."
      );
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()), (
            Route<dynamic> route) => false,);
    } else {
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Subscription Confirmed",
          style: TextStyle(
            color: const Color(0xFF030318),
            fontFamily: "Roboto",
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFFC2EA4C),
                size: 100),
            const SizedBox(height: 30),
            Text(
              "You're all set!",
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Thank you for subscribing to the ${widget
                  .subscriptionPlan} plan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: "Roboto",
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                    Icons.account_circle, size: 40, color: Color(0xFF907FFD)),
                title: Text(
                  username!,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Subscription Plan: ${widget.subscriptionPlan}",
                  style: TextStyle(fontFamily: "Roboto"),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // You can navigate to the home screen or dashboard here
                _handleSubscribe();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC2EA4C),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0)),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: const Color(0xFF030318),
                  fontSize: 16,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Future<String> subscribeStudent(String companyName, BuildContext context,) async {
  const String apiUrl = 'http://10.0.2.2:8000/api/users/subscribe/student/';
  try {
    String? token = await SessionManager.getToken();
    print(token);
    final response = await http
        .post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'company_name': companyName
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return 'Subscription successful';
    } else {
      return 'Error: Subscription failed: ${response.body}';
    }
  } on TimeoutException catch (_) {
    return "Error: request timed out. Please try again.";
  } catch (error) {
    return "Error: Failed to connect: $error";
  }
}
