import 'package:flutter/material.dart';
import 'student_register_screen.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final String companyName;

  CompanyDetailsScreen({super.key, required this.companyName});

  static const Map<String, List<String>> companyDetails = {
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

  static const EdgeInsets commonPadding = EdgeInsets.all(20.0);

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
        title: Text(
          companyName,
          style: TextStyle(color: Colors.black, fontFamily: "Roboto"),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: commonPadding,
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor:
                    Colors.grey.shade200, // ✅ Background color added
                child: Icon(
                  Icons.business,
                  size: 40,
                  color: Colors.black,
                ), // ✅ Icon color ensured
              ),
            ),
            SizedBox(height: 20),

            // ✅ Fix: Wrap ListView.builder inside Expanded
            Expanded(
              child: Padding(
                padding: commonPadding,
                child: ListView.builder(
                  itemCount: companyDetails.length,
                  itemBuilder: (context, index) {
                    String key = companyDetails.keys.elementAt(index);
                    return _buildDetailSection(key, companyDetails[key]!);
                  },
                ),
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){},
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
