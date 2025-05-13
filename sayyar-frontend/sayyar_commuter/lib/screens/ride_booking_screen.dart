import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../session_manager.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  String _pickupAddress = '';
  String _dropoffAddress = '';
  String _tripTime = '';


  DateTime selectedDate = DateTime.now();
  String tripType = 'outgoing';
  bool _isLoading = false;

  List<dynamic> choices = [];
  List<DropdownMenuEntry<dynamic>> tripTimesOutgoing = [
    DropdownMenuEntry(value: "6:30 AM - 7:30 AM", label: '1st Trip: Starts on 6:30 AM, Arrives by 7:30 AM'),
    DropdownMenuEntry(value: "8:00 AM - 9:00 AM", label: '2nd Trip: Starts on 8:00 AM, Arrives by 9:00 AM'),
    DropdownMenuEntry(value: "10:00 AM - 11:00 AM", label: '3rd Trip: Starts on 10:00 AM, Arrives by 11:00 AM'),
  ];

  List<DropdownMenuEntry<dynamic>> tripTimesReturn = [
      DropdownMenuEntry(value: "11:00 AM - 12:00 PM", label: '1st Trip: Starts on 11:00 AM'),
      DropdownMenuEntry(value: "2:30 PM - 3:30 PM", label: '2nd Trip: Starts on 2:30 PM'),
      DropdownMenuEntry(value: "4:00 PM - 5:00 PM", label: '3rd Trip: Starts on 4:00 PM'),
    ];

  List<String?> selectedDaysList = [];

  final List<String> weekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  Map<String, bool> selectedDays = {
    for (var day in ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']) day: false
  };

  Future<void> _getDropOffLocations() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8000/api/business/universities/');
    try {
    _isLoading = true;
    final token = await SessionManager.getToken();
    final response = await http.get(apiUrl, headers: {
      'Content-Type': 'application/json',
      'Authorization': '$token', // If needed
    }).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final List<dynamic> fetchedData = json.decode(response.body);

      setState(() {
        choices = fetchedData;
        print(choices);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load contacts');
    }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      }
      );
    }
  }

  Future<String> _bookTrip(
      LatLng pickupLocation,
      LatLng dropoffLocation,
      List<String> days,
      String tripType,
      String tripTime,
      BuildContext context
      ) async {
    final apiUrl = Uri.parse('http://10.0.2.2:8000/api/trips/book/');
    final token = await SessionManager.getToken();
    final body = jsonEncode(
      {
        'from_location': pickupLocation,
        'to_location': dropoffLocation,
        'weekdays': days,
        'trip_type': tripType,
        'trip_time': tripTime,
      }
    );

    try{
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token'
        },
        body: body
      );
      if (response.statusCode != 201){
        return "Error: ${response.body}";
      }
      return "Successfully Booked a Trip";
    } catch (e){
      return "Error: $e";
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
  }

  void _onMapTap(LatLng position) async {
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final address = placemarks.first.street ?? 'Selected location';
    setState(() {
      _pickupLocation = position;
      _pickupAddress = address;
      _pickupController.text = address;
    });
  }

  void _onSelectedDropOff(dynamic position) async {
    if (position != ''){
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final address = placemarks.first.street ?? 'Selected location';
      setState(() {
        _dropoffLocation = position;
        _dropoffAddress = address;
        _dropoffController.text = address;
      });
    }
  }

  void _updateSelectedDaysList(){
    selectedDays.forEach(
      (day, isSelected) {
        isSelected? selectedDaysList.add(day): null;
      }
    );
  }

  TextEditingController _pickupController = TextEditingController();
  TextEditingController _dropoffController = TextEditingController();
  TextEditingController _tripTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _getDropOffLocations();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Regular Ride')),
      body: Stack(
        children: [
          GoogleMap(
            cameraTargetBounds: CameraTargetBounds(LatLngBounds(northeast: LatLng(21.867117, 39.903015), southwest: LatLng(21.144274, 39.070801))),
            initialCameraPosition: const CameraPosition(
              target: LatLng(21.3891, 39.8579), // Jeddah default
              zoom: 12,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,

            markers: {
              if (_pickupLocation != null)
                Marker(
                  markerId: const MarkerId("pickup"),
                  position: _pickupLocation!,
                  infoWindow: const InfoWindow(title: "Pickup Location"),
                ),
              if (_dropoffLocation != null)
                Marker(
                  markerId: const MarkerId("dropoff"),
                  position: _dropoffLocation!,
                  infoWindow: const InfoWindow(title: "Drop-off Location"),
                ),
            },
          ),
          DraggableScrollableSheet(
            shouldCloseOnMinExtent: true,
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              if (_isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5FC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Booking Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pickupController,
                        decoration: InputDecoration(
                          labelText: "Pickup Address",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 30),
                      DropdownMenu(
                        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                        label: Text('Dropoff Address'),
                        initialSelection: LatLng(choices[0]['lat'], choices[0]['lon']),
                        width: double.infinity,
                        menuStyle: MenuStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            leadingIcon: Icon(Icons.school),
                            value: LatLng(choices[0]['lat'], choices[0]['lon']),
                            label: choices[0]['name'],
                          ),
                          DropdownMenuEntry(
                            leadingIcon: Icon(Icons.school),
                            value: LatLng(choices[1]['lat'], choices[1]['lon']),
                            label: choices[1]['name'],
                          ),
                        ],
                        controller: _dropoffController,
                        onSelected: (value) {
                          _onSelectedDropOff(value);
                          if (value != null) {
                            _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(value.latitude, value.longitude),
                                  14,
                                ));
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Repeat for the days:'
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8.0,
                        children: weekdays.map((day) {
                          return FilterChip(
                            label: Text(day),
                            selected: selectedDays[day] ?? false,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedDays[day] = selected;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        spacing: 8.0,
                        children: [
                          Text('Trip Type:'),
                          const SizedBox(width: 20),
                          ChoiceChip(
                            label: Text('Outgoing'),
                            selected: tripType == 'outgoing',
                            onSelected: (value){
                              setState(() {
                                tripType = 'outgoing';
                                _tripTimeController.text = '';
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          ChoiceChip(
                            label: Text('Return'),
                            selected: tripType == 'return',
                            onSelected: (value){
                              setState(() {
                                tripType = 'return';
                                _tripTimeController.text = '';
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      tripType == 'outgoing'?
                      DropdownMenu(
                        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                        label: Text('Trip time'),
                        hintText: 'Select the trip',
                        width: double.infinity,
                        menuStyle: MenuStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        dropdownMenuEntries: tripTimesOutgoing,
                        controller: _tripTimeController,
                        onSelected: (value){
                          setState(() {
                            _tripTime = value;
                          });
                        },
                      )
                      : DropdownMenu(
                        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                        label: Text('Trip time'),
                        hintText: 'Select the trip',
                        width: double.infinity,
                        menuStyle: MenuStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        dropdownMenuEntries: tripTimesReturn,
                        controller: _tripTimeController,
                        onSelected: (value){
                          setState(() {
                            _tripTime = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6DCF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                        onPressed: (_pickupLocation != null && _dropoffLocation != null && _tripTime.isNotEmpty)
                            ? () {
                          _updateSelectedDaysList();
                          print(selectedDaysList);
                        }
                            : null,
                        child: const Text("Confirm Ride"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


