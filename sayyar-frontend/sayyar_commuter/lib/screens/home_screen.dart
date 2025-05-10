import 'package:flutter/material.dart';
import 'package:sayyar_commuter/screens/profile_screen.dart';
import 'package:sayyar_commuter/screens/ride_booking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session_manager.dart';
import 'direct_messages_screen.dart';
import 'settings_screen.dart';
import 'track_driver_screen.dart';

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

    print(authenticated);
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
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Welcome, $username", style: TextStyle(color: const Color(0xFF030318))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: const Color(0xFF030318)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.access_time_filled, color: Color(0xFF907FFD)),
                  title: const Text(
                    'Days till subscription end:',
                  ),
                  subtitle: const Text(
                    '20 Days',
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC2EA4C),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackDriverScreen()));
                      },
                      icon: const Icon(Icons.location_searching, color: const Color(0xFF030318)),
                      label: const Text(
                        "Track Your Ride",
                        style: TextStyle(color: const Color(0xFF030318), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC2EA4C),
                        foregroundColor: const Color(0xFF030318),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RideBookingScreen()));
                      },
                      child: Text(
                        "Book a ride",
                        style: TextStyle(color: const Color(0xFF030318), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading:
                    CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  title:
                    Text(
                      'Your subscription:',
                    ),
                  subtitle: Text(
                    '$companyName'
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
        foregroundColor: const Color(0xFF030318),
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
            style: TextStyle(color: const Color(0xFF030318), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
