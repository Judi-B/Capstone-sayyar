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
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? username = '';

  Future<void> _checkLoginStatus() async {
    bool authenticated = await SessionManager.isAuthenticated();

    await Future.delayed(Duration(milliseconds: 500));

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString("first_name");
      setState(() {
        _isAuthenticated = true;
        username = username ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentLoginScreen(),
          ),
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        title: Text(
        "Confirm Your Subscription",
        style: TextStyle(color: Colors.black, fontFamily: "Roboto"),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: const Color(0xFFFAFAFA),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text("Company Name:"),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
