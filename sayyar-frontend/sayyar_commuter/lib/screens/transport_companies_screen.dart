import 'package:flutter/material.dart';
import 'package:sayyar_commuter/screens/student_login_screen.dart';
import 'package:sayyar_commuter/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'company_details_screen.dart';

class TransportCompaniesScreen extends StatefulWidget {
  const TransportCompaniesScreen({super.key});

  @override
  _TransportCompaniesScreenState createState() => _TransportCompaniesScreenState();
}

class _TransportCompaniesScreenState extends State<TransportCompaniesScreen>{

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? username = '';

  Future<void> _checkLoginStatus() async {
    bool authenticated = await SessionManager.isAuthenticated();

    await Future.delayed(Duration(milliseconds: 500));

    print(authenticated);
    if (authenticated){
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString("first_name");
      setState(() {
        _isAuthenticated = true;
        username = username ?? '';
        _isLoading = false;
      });
    }
    else {
      setState(() {
        _isAuthenticated = false;
        username = 'Guest';
        _isLoading = false;
      });
    }
  }


  final List<Map<String, dynamic>> companies = [
    {
      "name": "Arab Masters Transport Company",
      "description": "We transfer to all Jeddah universities",
      "rating": 4.5,
    },
    {
      "name": "Wosol Transport Company",
      "description": "Excellence and leadership in transportation services",
      "rating": 4.2,
    },
    {
      "name": "Al Khalid Transport Company",
      "description": "Excellence in Logistics",
      "rating": 3.9,
    },
    {
      "name": "Al-Qaliti Transport Company",
      "description": "Student transportation service from Mecca to Jeddah",
      "rating": 4.8,
    },
    {
      "name": "Al Samer Transport Company",
      "description": "Student transportation service from Mecca to Jeddah",
      "rating": 4.0,
    },
  ];

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (hasHalfStar && index == fullStars) {
          return Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // or any loading widget
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isAuthenticated? "Welcome, $username": "Welcome, Guest", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_isAuthenticated){
                SessionManager.clearToken();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentLoginScreen()),
                );
              }
              else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentLoginScreen()),
                );
              }
            }, // Implement Login action if needed
            child: Text(_isAuthenticated? "Log Out": "Log In", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.business)),
                    title: Text(
                      companies[index]["name"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(companies[index]["description"]!),
                        SizedBox(height: 5),
                        _buildStarRating(
                          companies[index]["rating"],
                        ), // Add star rating here
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CompanyDetailsScreen(
                                companyName: companies[index]["name"]!,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
