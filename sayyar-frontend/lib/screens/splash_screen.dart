import 'package:flutter/material.dart';
import 'dart:async';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    });
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
