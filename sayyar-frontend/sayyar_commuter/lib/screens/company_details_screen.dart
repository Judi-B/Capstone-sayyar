import 'package:flutter/material.dart';
import 'package:sayyar_commuter/screens/student_login_screen.dart';
import 'package:sayyar_commuter/screens/subscription_confirmation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session_manager.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final String companyName;

  const CompanyDetailsScreen({super.key, required this.companyName});

  @override
  _CompanyDetailsScreenState createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? username = '';
  String plan = '';

  Future<void> _checkLoginStatus() async {
    bool authenticated = await SessionManager.isAuthenticated();

    await Future.delayed(Duration(milliseconds: 500));

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString("first_name");
      setState(() {
        _isAuthenticated = true;
        username = username ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAuthenticated = false;
        username = 'Guest';
        _isLoading = false;
      });
    }
  }

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
          widget.companyName,
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
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: commonPadding,
                child: ListView.builder(
                  itemCount: companyDetails.length + 1,
                  itemBuilder: (context, index) {
                    if (index < companyDetails.length) {
                      String key = companyDetails.keys.elementAt(index);
                      return _buildDetailSection(key, companyDetails[key]!);
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subscription plans",
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black, fontFamily: "Roboto", fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicWidth(
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: (){
                                      plan = "800 SAR/month";
                                      if (_isAuthenticated){
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubscriptionConfirmationScreen(subscriptionPlan: plan, companyName: widget.companyName,),
                                          ),
                                        );
                                      }
                                      else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const StudentLoginScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shadowColor: const Color(0x00000000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      backgroundColor: const Color(0x00000000),
                                    ),
                                    child: Card(
                                      color: const Color(0xFFFAFAFA),
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundColor: Colors.yellow.shade700,
                                              child: Image.asset(
                                                'assets/images/minivan_iso.png',
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text("800 SAR/month"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: (){
                                      plan = "2500 SAR/Semester";
                                      if (_isAuthenticated){
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubscriptionConfirmationScreen(subscriptionPlan: plan, companyName: widget.companyName,),
                                          ),
                                        );
                                      }
                                      else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const StudentLoginScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shadowColor: const Color(0x00000000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      backgroundColor: const Color(0x00000000),
                                    ),
                                    child: Card(
                                      color: const Color(0xFFFAFAFA),
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundColor:
                                                  Colors.lightBlue.shade200,
                                              child: Image.asset(
                                                'assets/images/minivan_iso.png',
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text("2500 SAR/Semester"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
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
