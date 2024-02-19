import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc; // เพิ่มแพ็คเกจ location

import 'package:mn_641463008/mainmenu.dart';

class GPSTracking extends StatefulWidget {
  @override
  _GPSTrackingState createState() => _GPSTrackingState();
}

class _GPSTrackingState extends State<GPSTracking> {
  GoogleMapController? mapController;
  List<Marker> markers = [];
  loc.LocationData? _currentLocation; // เพิ่มตัวแปรเพื่อเก็บตำแหน่งปัจจุบัน

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // เรียกใช้ฟังก์ชันเพื่อดึงตำแหน่งปัจจุบัน
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/mn_db/getlocation.php'));
      if (response.statusCode == 200) {
        List<dynamic> places = json.decode(response.body);
        setState(() {
          markers = places.map((place) {
            return Marker(
              markerId: MarkerId(place['locations_id'].toString()),
              position: LatLng(
                double.parse(place['latitude']),
                double.parse(place['longitude']),
              ),
              infoWindow: InfoWindow(
                title: place['locations_name'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            );
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load places'),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (error) {
      print('Error fetching places: $error');
    }
  }

  // ฟังก์ชันเพื่อดึงตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    try {
      loc.Location location = loc.Location();
      bool _serviceEnabled;
      loc.PermissionStatus _permissionGranted;
      loc.LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();
      setState(() {
        _currentLocation = _locationData;
      });

      // เช็ตค่าเริ่มต้นให้ซูมไปที่ตำแหน่งปัจจุบัน
      if (mapController != null && _currentLocation != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              zoom: 15, // ปรับซูมได้ตามต้องการ
            ),
          ),
        );
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainMenu(),
            ));
          },
        ),
        title: Text(
          'จุดท่องเที่ยวทั้งหมด',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _currentLocation != null
            ? CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 10,
              )
            : CameraPosition(
                target: LatLng(13.7563, 100.5018),
                zoom: 10,
              ),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            mapController = controller;
          });
        },
        markers: Set<Marker>.of(markers)
          ..add(
            Marker(
              // เพิ่มตำแหน่งปัจจุบัน
              markerId: MarkerId('currentLocation'),
              position: LatLng(
                _currentLocation != null ? _currentLocation!.latitude! : 0,
                _currentLocation != null ? _currentLocation!.longitude! : 0,
              ),
              infoWindow: InfoWindow(
                title: 'ตำแหน่งปัจจุบัน',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
