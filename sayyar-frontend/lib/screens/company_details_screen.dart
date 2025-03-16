import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final String companyName;

  CompanyDetailsScreen({super.key, required this.companyName});

  final Map<String, List<String>> companyDetails = {
    "Coverage": ["City-wide transport", "Inter-city travel"],
    "Destination": ["Jeddah, Mecca, Riyadh"],
    "Target Customers": ["Students", "Working Professionals", "Tourists"],
    "Pricing Options": ["Fixed Monthly Plans", "Pay per Ride"],
    "Available Time Intervals": [
      "Morning: 6 AM - 9 AM",
      "Evening: 5 PM - 9 PM",
    ],
    "Pickup/Dropoff Options": [
      "University Gates",
      "Metro Stations",
      "Residential Areas",
    ],
    "Cancellation": ["Free cancellation up to 24 hours before ride"],
  };

  Widget _buildDetailSection(String title, List<String> details) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          ...details.map(
            (detail) => ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text(detail, style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(companyName, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: CircleAvatar(radius: 40, child: Text("😊"))),
            SizedBox(height: 20),
            _buildDetailSection("Coverage", companyDetails["Coverage"]!),
            _buildDetailSection("Destination", companyDetails["Destination"]!),
            _buildDetailSection(
              "Target Customers",
              companyDetails["Target Customers"]!,
            ),
            _buildDetailSection(
              "Pricing Options",
              companyDetails["Pricing Options"]!,
            ),
            _buildDetailSection(
              "Available Time Intervals",
              companyDetails["Available Time Intervals"]!,
            ),
            _buildDetailSection(
              "Pickup/Dropoff Options",
              companyDetails["Pickup/Dropoff Options"]!,
            ),
            _buildDetailSection(
              "Cancellation",
              companyDetails["Cancellation"]!,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                "Hit the Gas - Join Us!",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
