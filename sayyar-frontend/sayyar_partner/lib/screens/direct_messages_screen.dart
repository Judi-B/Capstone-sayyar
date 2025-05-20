import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sayyar_partner/screens/profile_screen.dart';
import '../../session_manager.dart';
import 'home_screen.dart';

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({super.key});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  List<dynamic> contacts = [
    {'name': '',
      'phone_number': ''}
  ];

  final List<String> messages = [
    'Ride request accepted!',
    'Be right there!',
    '5 minutes away.',
    'Almost There.',
    'Please rate your ride!',
    'At the traffic light.',
    'Waiting outside.',
  ];

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/users/contacts/');

    try {
      _isLoading = true;
      final token = await SessionManager.getToken();
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // If needed
      });
      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);

        setState(() {
          contacts = fetchedData;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load contacts');
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
          child: CircularProgressIndicator()
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFFAFAFA),
          elevation: 0,
          selectedItemColor: const Color(0xFF907FFD),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          ],
          currentIndex: 1,
          onTap: (index){
            switch (index){
              case 0:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));

              case 2:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
            }
          },
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Dark navy background
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Direct Messages',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        child: const Icon(Icons.person),
                      ),
                      title: Text(contact['name']?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(contact['role']?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Icon(Icons.check_box, color: Colors.grey.shade400),
                      onTap: (){

                        // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: '1',)));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        selectedItemColor: const Color(0xFF907FFD),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
        currentIndex: 1,
        onTap: (index){
          switch (index){
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));

            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }
        },
      ),
    );
  }

  String getChatId(String userA, String userB) {
    final sortedIds = [userA, userB]..sort();  // Sort alphabetically
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
  //
  // Future<dynamic> _get_users_data() async{
  //   const apiUrl = 'http://10.0.2.2:8000/api/chat/get-users/';
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(apiUrl),
  //     ).timeout(const Duration(seconds: 10));
  //
  //     if (response.statusCode == 200) {
  //       // Successful login
  //       final responseData = jsonDecode(response.body);
  //       return responseData;
  //
  //     } else {
  //       // Failed login
  //       return "Error: ${response.body}";
  //     }
  //   } on TimeoutException catch (_) {
  //     return "Error: Login timed out. Please try again.";
  //   }
  //   catch (error) {
  //     return "Error: $error";
  //   }
  // }
}
