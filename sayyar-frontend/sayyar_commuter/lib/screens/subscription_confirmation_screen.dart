import 'package:flutter/material.dart';
import 'package:sayyar_commuter/screens/student_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session_manager.dart';

class SubscriptionConfirmationScreen extends StatefulWidget {
  final String subscriptionPlan;

  const SubscriptionConfirmationScreen({super.key, required this.subscriptionPlan});

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
            color: Colors.black,
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
            Icon(Icons.check_circle_outline, color: Color(0xFFC2EA4C), size: 100),
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
              "Thank you for subscribing to the ${widget.subscriptionPlan} plan.",
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
                leading: Icon(Icons.account_circle, size: 40, color: Color(0xFF907FFD)),
                title: Text(
                  "Welcome, $username",
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC2EA4C),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.black,
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
