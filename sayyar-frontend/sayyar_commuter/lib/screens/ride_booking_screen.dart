import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
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

  bool _isSelectingPickup = true;
  DateTime selectedDate = DateTime.now();
  String rideType = 'Regular';
  bool _isLoading = false;

  List<dynamic> choices = [];

  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Map<String, bool> selectedDays = {
    for (var day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']) day: false
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


  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    if (time == null) return;
    setState(() {
      selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
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
      if (_isSelectingPickup) {
        _pickupLocation = position;
        _pickupAddress = address;
        _pickupController.text = address;
      } else {
        _dropoffLocation = position;
        _dropoffAddress = address;
        _dropoffController.text = address;
      }
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

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  TextEditingController _pickupController = TextEditingController();
  TextEditingController _dropoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _getCurrentPosition().then((position) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14,
      ));
    });
    _getDropOffLocations();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, MMM d • h:mm a').format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Regular Ride')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              onTap: _onMapTap,
              initialCameraPosition: const CameraPosition(
                target: LatLng(21.3891, 39.8579), // Jeddah default
                zoom: 12,
              ),
              markers: {
                if (_pickupLocation != null)
                  Marker(
                    markerId: const MarkerId("pickup"),
                    position: _pickupLocation!,
                    infoWindow: const InfoWindow(title: "Pickup Location"),
                      draggable: true
                  ),
                if (_dropoffLocation != null)
                  Marker(
                    markerId: const MarkerId("dropoff"),
                    position: _dropoffLocation!,
                    infoWindow: const InfoWindow(title: "Drop-off Location"),
                      draggable: true
                  ),
              },
            ),
          ),
          Flexible(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text("Select:"),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: const Text("Pickup"),
                                  selected: _isSelectingPickup,
                                  onSelected: (selected) =>
                                      setState(() => _isSelectingPickup = true),
                                ),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: const Text("Drop-off"),
                                  selected: !_isSelectingPickup,
                                  onSelected: (selected) =>
                                      setState(() =>
                                      _isSelectingPickup = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _pickupController,
                              decoration: const InputDecoration(
                                  labelText: "Pickup Address"),
                              readOnly: true,
                            ),
                            const SizedBox(height: 10),
                            DropdownMenu(
                              width: double.infinity,
                              menuStyle: MenuStyle(
                                
                              ),
                              dropdownMenuEntries: [
                                DropdownMenuEntry(value: LatLng(choices[0]['lat'], choices[0]['lon'])?? '', label: choices[0]['name']),
                                DropdownMenuEntry(value: LatLng(choices[1]['lat'], choices[1]['lon'])?? '', label: choices[1]['name']),
                              ],
                              controller: _dropoffController,
                              onSelected: (value) {
                                  _onSelectedDropOff(value);
                              }
                            ),
                            TextField(
                              controller: _dropoffController,
                              decoration: const InputDecoration(
                                  labelText: "Drop-off Address"),
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),
                            // Row(
                            //   children: [
                            //     const Text("Select Trip Type:"),
                            //     const SizedBox(width: 10),
                            //     ChoiceChip(
                            //       label: const Text('Regular'),
                            //       selected: rideType == 'regular',
                            //       onSelected: (_) => setState(() => rideType = "regular"),
                            //       labelStyle: TextStyle(
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //     const SizedBox(width: 10),
                            //     ChoiceChip(
                            //       label: const Text('One-time'),
                            //       selected: rideType == 'one_time',
                            //       onSelected: (_) => setState(() => rideType = "one_time"),
                            //       labelStyle: TextStyle(
                            //         color: Colors.black,
                            //       ),
                            //     )
                            //   ]
                            // ),
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

                            const SizedBox(height: 16),
                            _buildDatePicker(formattedDate),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: (_pickupLocation != null &&
                                  _dropoffLocation != null)
                                  ? () {
                                // Submit logic
                              }
                                  : null,
                              child: const Text("Confirm Ride"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String date) {
    return GestureDetector(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 10),
            Text(date, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressField(String hint, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: TextStyle(fontSize: 16, color: value.isEmpty ? Colors.grey : Colors.black),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}


