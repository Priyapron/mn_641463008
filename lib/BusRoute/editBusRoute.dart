import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateBusRouteScreen extends StatefulWidget {
  final Map<String, dynamic> busRouteData;
  final VoidCallback onBusRouteUpdated;

  UpdateBusRouteScreen({
    required this.busRouteData,
    required this.onBusRouteUpdated,
  });

  @override
  _UpdateBusRouteScreenState createState() => _UpdateBusRouteScreenState();
}

class _UpdateBusRouteScreenState extends State<UpdateBusRouteScreen> {
  TextEditingController routeNoController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  String? selectedLocationId;

  List<Map<String, dynamic>> locationData = [];

  @override
  void initState() {
    super.initState();
    routeNoController.text = widget.busRouteData['route_No']?.toString() ?? '';

    // Parse and set the existing time data
    final existingTime = widget.busRouteData['time']?.toString() ?? '';
    final parsedTime =
        TimeOfDay.fromDateTime(DateTime.parse("2022-01-01 $existingTime"));
    timeController.text = '${parsedTime.hour}:${parsedTime.minute}'.toString();

    selectedLocationId = widget.busRouteData['locations_id']?.toString() ?? '';

    // Fetch location data
    fetchLocationData();
  }

  Future<void> fetchLocationData() async {
    final apiUrl = 'http://localhost/mn_db/get_LocationData.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> parsed = json.decode(response.body);
        setState(() {
          locationData = parsed.cast<Map<String, dynamic>>();
        });
      } else {
        print('Error fetching location data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        timeController.text = '${picked.hour}:${picked.minute}'.toString();
      });
    }
  }

  Future<void> _saveUpdatedBusRoute() async {
    final apiUrl = 'http://localhost/mn_db/busRouteInfo.php';

    try {
      showLoadingDialog();

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '2',
          'route_No': routeNoController.text,
          'locations_id': selectedLocationId!,
          'time': timeController.text,
        },
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        print('บันทึกการแก้ไขข้อมูลเส้นทางเดินรถสำเร็จ');
        showSuccessDialog();
        widget.onBusRouteUpdated();
      } else {
        print('Error updating bus route information: ${response.statusCode}');
        final errorMessage = response.body;
        showErrorSnackBar(
            'Error updating bus route information: $errorMessage');
      }
    } catch (e) {
      print('Exception: $e');
      showErrorSnackBar('Error: $e');
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.0),
              Text('บันทึก...'),
            ],
          ),
        );
      },
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('สำเร็จ'),
          content: Text('แก้ไขข้อมูลเส้นทางเดินรถสำเร็จ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'แก้ไขข้อมูลเส้นทางเดินรถ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: routeNoController,
              decoration: InputDecoration(labelText: 'ลำดับที่'),
              enabled: false,
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: selectedLocationId,
              items: locationData.map((location) {
                return DropdownMenuItem(
                  value: location['locations_id'].toString(),
                  child: Row(
                    children: [
                      Text('${location['locations_id']} - '),
                      Text(
                        location['locations_name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocationId = value.toString();
                });
              },
              decoration: InputDecoration(labelText: 'รหัสสถานที่'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเลือกรหัสสถานที่';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text('เลือกเวลา'),
                ),
                SizedBox(width: 10),
                Text(
                  'เวลาที่เลือก: ${timeController.text}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveUpdatedBusRoute,
              child: Text('แก้ไขข้อมูลเส้นทางเดินรถสำเร็จ'),
            ),
          ],
        ),
      ),
    );
  }
}
