import 'package:flutter/material.dart';
import 'dart:async';
import '../session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isAuthenticated = await SessionManager.isAuthenticated();

    // Wait a little to show splash effect
    await Future.delayed(Duration(milliseconds: 500));

    if (isAuthenticated) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => StudentHomeScreen()),
      // );
    } else {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      // );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_white_back.png',
              fit: BoxFit.cover,
            ),
            Text(
              "Ready When You Are!",
              style: TextStyle(fontFamily: "Zen Dots", fontSize: 24, color: Colors.grey.shade900),
            ),
          ],
        ),
      ),
    );
  }
}
