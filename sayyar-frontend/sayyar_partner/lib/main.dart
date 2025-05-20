import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sayyar_partner/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SayyarPartner());
}

class SayyarPartner extends StatelessWidget {
  const SayyarPartner({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayyar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
