import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sayyar_partner/screens/profile_screen.dart';
import 'package:sayyar_partner/screens/settings_screen.dart';
import 'package:sayyar_partner/screens/trip_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session_manager.dart';
import 'direct_messages_screen.dart';
import 'employee_login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _getUpcomingTrips();
    _getAvailableDrivers();
    _getSubscribedStudents();
  }

  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? username = '';
  String? companyName = '';

  List<dynamic> upcomingTrips = [];
  List<dynamic> availableDrivers = [];
  List<dynamic> subscribedStudents = [];

  Future<void> _checkLoginStatus() async {
    bool authenticated = await SessionManager.isAuthenticated();

    await Future.delayed(Duration(milliseconds: 500));

    if (authenticated){
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString("first_name");
      companyName = prefs.getString('subscribed_company');
      setState(() {
        _isAuthenticated = true;
        username = username ?? '';
        companyName = companyName ?? '';
        _isLoading = false;
      });
    }
    else {
      setState(() {
        _isAuthenticated = false;
        username = 'Guest';
        _isLoading = false;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmployeeLoginScreen()));
      });
    }
  }

  Future<void> _getUpcomingTrips() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8000/api/system/trips/');

    final token = await SessionManager.getToken();

    try{
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        }
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);

        setState(() {
          upcomingTrips = fetchedData;
          _isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Error: ${response.statusCode}"
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error: $e"
      );
    }
  }


  Future<void> _getAvailableDrivers() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8000/api/users/drivers/');

    final token = await SessionManager.getToken();

    try{
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        }
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);

        setState(() {
          availableDrivers = fetchedData;
          if (upcomingTrips.isNotEmpty){
            _isLoading = false;
          }
        });
      } else {
        Fluttertoast.showToast(
            msg: "Error: ${response.statusCode}"
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error: $e"
      );
    }
  }


  Future<void> _getSubscribedStudents() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8000/api/users/students/');

    final token = await SessionManager.getToken();

    try{
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        }
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);

        setState(() {
          subscribedStudents = fetchedData;
          if (upcomingTrips.isNotEmpty && availableDrivers.isNotEmpty){
            _isLoading = false;
          }
        });
      } else {
        Fluttertoast.showToast(
            msg: "Error: ${response.statusCode}"
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error: $e"
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day + 1);
    String formattedDate = DateFormat.yMMMd().format(nowDate);

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
        title: Text("Welcome, $username", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Upcoming trips:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(15),
                      itemCount: upcomingTrips.length,
                      separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final trip = upcomingTrips[index];
                        final tripTime = DateFormat.Hms().parse(trip['time']); // '06:30:00'
                        final formattedTime = DateFormat.jm().format(tripTime); // → 6:30 AM

                        return ListTile(
                          title: Text(trip['name']?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('$formattedDate at $formattedTime', style: TextStyle(fontSize: 14)),
                          trailing: Icon(Icons.check_box, color: Colors.grey.shade400),
                          onTap: (){

                            Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip)));
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Available Drivers:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(15),
                      itemCount: availableDrivers.length,
                      separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final driver = availableDrivers[index];
                        return ListTile(
                          title: Text(driver['name']?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('Phone Number: ${driver['phone_number']?? ''}', style: TextStyle(fontSize: 14)),
                          trailing: Icon(driver['is_available']? Icons.check_circle : Icons.cancel, color: driver['is_available']? Colors.green.shade400 : Colors.red.shade300),
                          onTap: (){},
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Subscribed Students:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(15),
                      itemCount: subscribedStudents.length,
                      separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final student = subscribedStudents[index];

                        return ListTile(
                          title: Text(student['name']?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('University: ${student['university']}', style: TextStyle(fontSize: 12)),
                          trailing: Icon(student['is_subscribed']? Icons.attach_money: Icons.money_off, color: student['is_subscribed']? Colors.green.shade400: Colors.red.shade300),
                          onTap: (){},
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));

            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DirectMessagesScreen()));
          }
        },
      ),
    );
  }
  }