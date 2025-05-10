import 'package:flutter/material.dart';
import 'onboarding_2.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Image.asset(
                'assets/images/onboarding1.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stress-Free, Effortless Travel",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF030318),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Track your ride in real-time from home to hall.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: const Color(0xFF030318)),
                  SizedBox(width: 5),
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  SizedBox(width: 5),
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: const Color(0xFF030318),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Onboarding2()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
