import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Choose Your Role",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: Text("I am a Student")),
          ElevatedButton(onPressed: () {}, child: Text("I am a Driver")),
          ElevatedButton(onPressed: () {}, child: Text("I am a Business")),
        ],
      ),
    );
  }
}
