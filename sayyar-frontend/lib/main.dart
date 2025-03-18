import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import the splash screen

void main() {
  runApp(SayyarApp());
}

class SayyarApp extends StatelessWidget {
  const SayyarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayyar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
