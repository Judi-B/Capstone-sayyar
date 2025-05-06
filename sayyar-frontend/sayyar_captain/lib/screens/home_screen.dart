import 'package:flutter/material.dart';
import 'package:sayyar_captain/screens/profile_screen.dart';
import 'package:sayyar_captain/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session_manager.dart';
import 'direct_messages_screen.dart';
import 'driver_login_screen.dart';


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
  }

  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? username = '';
  String? companyName = '';

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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverLoginScreen()));
      });
    }
  }




  @override
  Widget build(BuildContext context) {
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
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.location_pin, color: Color(0xFF907FFD)),
                  title: const Text("Pickup/Dropoff point"),
                  subtitle: const Text("Home, 123 St, Jeddah"),
                ),
              ),
              const SizedBox(height: 20),
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ListTile(
                          title:Text(
                            'Upcoming trip:',
                          ),
                          subtitle: Text(
                              'Trip 1, Dec 23, 2024 at 5:30 AM'
                          )
                      ),
                      ListTile(
                          title:Text(
                            'From:',
                          ),
                          subtitle: Text(
                              'Home'
                          )
                      ),
                      ListTile(
                          title:Text(
                            'To:',
                          ),
                          subtitle: Text(
                              'Dar Al-Hekma University'
                          )
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _tripButton(String label, VoidCallback onPressed, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC2EA4C),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFFFFF),
            child: Icon(icon),
          ),
          const SizedBox(height: 20,),
          Text(
            label,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
