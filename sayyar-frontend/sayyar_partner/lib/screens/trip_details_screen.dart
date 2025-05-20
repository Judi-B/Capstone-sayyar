import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import '../session_manager.dart';

class TripDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  Set<Polyline> _polylines = {};
  List<dynamic> orderedCoords = [];
  List<List<double>> driverRoutes = [];
  Map<String, dynamic> driverPaths ={};
  Set<Marker> locMarkers = {};
  String accessToken = 'pk.eyJ1IjoianVkaS1iIiwiYSI6ImNtYXNreHVjNDBpaWMyanM5NXdldDN2NnUifQ.UeffUYY15R1WVsYtqTGc6A';
  LatLng defaultTarget = LatLng(
    21.488095,
    39.229807,
  );


  @override
  void initState() {
    super.initState();
    _getTrip();
  }

  void _loadPolylines(bool recluster) async {
    Set<Polyline> polylines = {};
    setState(() {
      _polylines.clear();
    });
    driverPaths = await fetchTripClusters(widget.trip['id'], recluster);
    for (var driver in driverPaths.keys) {
      orderedCoords = driverPaths[driver]['ordered_coordinates'];
      final line = await loadAndDrawRoute(orderedCoords, 'route_$driver');
      polylines.add(line);
    }

    setState(() {
      _polylines = polylines;
    });
  }

  Future<Map<String, dynamic>> fetchTripClusters(int tripId, bool recluster) async {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/system/optimize-routes/?trip_id=${widget.trip["id"]}&recluster=${recluster}'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data;
    } else {
      throw Exception("Failed to fetch clusters");
    }
  }

  Future<List<LatLng>> getMatchedRoute(List<dynamic> orderedCoords) async {

    final coordString = orderedCoords
        .map((coord) => '${coord[0]},${coord[1]}')
        .join(';');

    final url =
        'https://api.mapbox.com/matching/v5/mapbox/driving/$coordString'
        '?geometries=geojson&access_token=$accessToken';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['matchings'][0]['geometry']['coordinates'];

      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Map Matching failed: ${response.body}');
    }
  }

  Future<Polyline> loadAndDrawRoute(List<dynamic> orderedCoords, String id) async {
    try {
      final matchedPoints = await getMatchedRoute(orderedCoords);

      return drawPolyline(matchedPoints, id);
    } catch (e) {
      throw Exception("Error getting matched route: $e");
    }
  }

  Polyline drawPolyline(List<LatLng> points, String id) {
    final _random = new Random();
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.amber
    ];

    return
      Polyline(
        polylineId: PolylineId(id),
        color: colors[_random.nextInt(5)],
        width: 5,
        points: points,
      );
  }

  Map<String, dynamic> details = {'date': '', 'time': '', 'student_locations': <LatLng>[]};
  bool _isLoading = false;

  Future<void> _getTrip() async {
    final apiUrl = Uri.parse(
      'http://10.0.2.2:8000/api/system/trips/${widget.trip['id']}/',
    );
    final token = await SessionManager.getToken();
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedData = json.decode(response.body);

        setState(() {
          details = fetchedData;
          _isLoading = false;
          List<LatLng> studentLocations = details['student_locations']
            .map<LatLng>((point) => LatLng(point['latitude'], point['longitude']))
            .toList();
          locMarkers = _buildMarkers(studentLocations);
        });
      } else {
        Fluttertoast.showToast(msg: "Error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowDate = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );
    final formattedDate = DateFormat.yMMMd().format(nowDate);
    final tripTime = DateFormat.Hms().parse(
      widget.trip['time'],
    );
    final formattedTime = DateFormat.jm().format(tripTime);


    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // or any loading widget
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(widget.trip['name'], style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: defaultTarget,
              zoom: 12,
            ),
            markers: locMarkers,
            polylines: _polylines,
          ),
          DraggableScrollableSheet(
            shouldCloseOnMinExtent: true,
            initialChildSize: 0.3,
            minChildSize: 0.02,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              if (_isLoading) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Date',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(formattedDate),
                        onTap: () {},
                      ),
                      const Divider(height: 16, color: Color(0x00000000)),
                      ListTile(
                        title: Text(
                          'Time',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(formattedTime),
                        onTap: () {},
                      ),
                      const Divider(height: 16, color: Color(0x00000000)),
                      ListTile(
                        title: Text(
                          'Trip Type',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(details['trip_type']?? ''),
                        onTap: () {},
                      ),
                      const Divider(height: 16, color: Color(0xFFFAFAFA)),
                      ListTile(
                        title: Text(
                          'Students in this trip:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child:
                        Column(
                          children: [
                            ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(15),
                            itemCount: details['students_list'].isNotEmpty?details['students_list'].length: 1,
                            separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade300),
                            itemBuilder: (context, index) {

                              final student = details['students_list'][index];
                                return ListTile(
                                  title: Text(student?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  onTap: (){},
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height:20),
                      ListTile(
                        title: Text(
                          'Available drivers this trip:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child:
                        Column(
                          children: [
                            ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(15),
                            itemCount: details['drivers_list'].isNotEmpty?details['drivers_list'].length: 1,
                            separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade300),
                            itemBuilder: (context, index) {

                              final driver = details['drivers_list'][index];
                                return ListTile(
                                  title: Text(driver?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  onTap: (){},
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height:20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: (){_loadPolylines(false);}, child: Text("Optimize Routes")),
                          const SizedBox(width:40),
                          ElevatedButton(onPressed: (){_loadPolylines(true);}, child: Text("Re-route")),
                        ],
                      ),
                      const SizedBox(height:40),
                    ],
                  ),
                ),
              );
            }
          ),
        ]
      ),
    );
  }


  Set<Marker> _buildMarkers(List<dynamic> routes) {
    Set<Marker> markers = {};
    for (var route in routes) {
      if (route is LatLng){
        markers.add(
          Marker(
            markerId: MarkerId("Student_${routes.indexOf(route)}"),
            position: route,
            infoWindow: InfoWindow(title: "Student_${routes.indexOf(route)} pickup point"),
          ),
        );
      }
    }
    return markers;
  }
}

class DriverRoute {
  final String driverId;
  final List<LatLng> path;

  DriverRoute({required this.driverId, required this.path});
}



