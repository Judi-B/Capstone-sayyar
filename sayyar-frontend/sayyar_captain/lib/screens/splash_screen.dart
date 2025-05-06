import 'package:flutter/material.dart';

import '../session_manager.dart';
import 'driver_login_screen.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverLoginScreen()),
      );
    } else if (isAuthenticated){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverLoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverLoginScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF907FFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_purple_back.png',
              fit: BoxFit.cover,
            ),
            Text(
              "Ready When You Are!",
              style: TextStyle(fontFamily: "Zen Dots", fontSize: 24, color: const Color(0xFFFAFAFA)),
            ),
          ],
        ),
      ),
    );
  }
}
