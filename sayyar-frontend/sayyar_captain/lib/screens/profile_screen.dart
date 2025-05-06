import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../session_manager.dart';
import 'direct_messages_screen.dart';
import 'driver_login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{


  Map<String, dynamic> data = {
    'name': '',
    'email': '',
    'licence_number': '',
    'phone': '',
    'company_name': '',
    'vehicle_plate': '',
  };

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    fetchUserData();
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
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DriverLoginScreen()), (Route<dynamic> route) => false,);
      });
    }
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('http://192.168.0.156:8000/api/user-data/driver/');

    try {
      setState(() {
        _isLoading = true;
      });
      final token = await SessionManager.getToken();
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // If needed
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedData = json.decode(response.body);

        setState(() {
          data = fetchedData;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(year2023: true,), // or any loading widget
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Dark navy background
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 24, bottom: 12),
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 40,
                child: const Icon(Icons.person),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Welcome, $username",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    _sectionTitle("Personal"),
                    _infoTile(Icons.person, "Name", data['name'], editable: true),
                    _infoTile(Icons.email, "Email", data['email'], verified: true),
                    _infoTile(Icons.phone, "Phone Number", data['phone'], editable: true),
                    _infoTile(Icons.location_pin, "Home Location", "Home, 123, Doe St.",
                        editable: true),
                    SizedBox(height: 30),
                    _sectionTitle("Work"),
                    _infoTile(Icons.business, "Company", data['company_name'], verified: true),
                    _infoTile(Icons.verified_user, "Licence Number", data['licence_number'], verified: true),
                    _infoTile(Icons.numbers, "Vehicle Plate Number", data['vehicle_plate']?? '', editable: true),
                    _sectionTitle("Financial"),
                    _infoTile(Icons.attach_money, "Payment method", "•••• 1234", editable: false),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF907FFD),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        ],
        onTap: (index){
          switch (index){
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));

            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DirectMessagesScreen()));
          }
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value,
      {bool editable = false, bool verified = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: TextStyle(color: Colors.black54)),
      subtitle: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: verified
          ? Icon(Icons.check_circle, color: Colors.green)
          : editable
          ? Icon(Icons.edit, color: Colors.grey)
          : null,
    );
  }
}
