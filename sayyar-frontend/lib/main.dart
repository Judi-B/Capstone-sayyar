import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sayyar_frontend/screens/role_selection_screen.dart';
import 'package:sayyar_frontend/screens/transport_companies_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SayyarApp());
}

class SayyarApp extends StatelessWidget {
  const SayyarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayyar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TransportCompaniesScreen(); // Show home screen if logged in
          } else {
            return RoleSelectionScreen(); // Show login screen if logged out
          }
        },
      ),
    );
  }
}
