import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackDriverScreen extends StatefulWidget {
  const TrackDriverScreen({super.key});

  @override
  State<TrackDriverScreen> createState() => _TrackDriverScreenState();
}

class _TrackDriverScreenState extends State<TrackDriverScreen> {
  late GoogleMapController _mapController;
  final LatLng _driverLocation = const LatLng(
    21.3891,
    39.8579,
  ); // Default to Jeddah

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Driver",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _driverLocation,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("driver"),
                  position: _driverLocation,
                  infoWindow: const InfoWindow(title: "Driver Location"),
                ),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 8),
              ],
            ),
            child: Column(
              children: const [
                Text(
                  "Your driver is 5 minutes away",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Estimated arrival: 4:45 PM",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
