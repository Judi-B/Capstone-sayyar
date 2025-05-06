import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
      title: 'Sayyar Captain App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

