import 'package:flutter/material.dart';
import 'package:sayyar_commuter/screens/student_login_screen.dart';
import 'package:sayyar_commuter/screens/transport_companies_screen.dart';
import 'dart:async';
import '../session_manager.dart';
import 'home_screen.dart';

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
    bool? isSubscribed = await SessionManager.isSubscribed();

    // Wait a little to show splash effect
    await Future.delayed(Duration(milliseconds: 500));

    if (isAuthenticated && isSubscribed!) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (isAuthenticated){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TransportCompaniesScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentLoginScreen()),
      );
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
