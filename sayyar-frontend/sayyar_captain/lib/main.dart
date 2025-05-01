import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sayyar_captain/screens/driver_login_screen.dart';
import 'package:sayyar_captain/screens/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(SayyarCaptainApp());
}

class SayyarCaptainApp extends StatelessWidget {

  const SayyarCaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayyar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DriverLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
