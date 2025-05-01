import 'package:flutter/material.dart';
import 'employee_login_screen.dart';

class BusinessLoginOptionsScreen extends StatelessWidget {
  const BusinessLoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/images/bus_image.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
              color: Colors.blueGrey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Continue as a...",
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),
                  _RoleButton(
                    label: "New Business",
                    onPressed: () {}
                  ),
                  const SizedBox(height: 30),
                  _RoleButton(
                    label: "Employee",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmployeeLoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _RoleButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade200,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
        onPressed: onPressed ?? () {},
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: "Roboto",
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
