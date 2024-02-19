import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusRouteInsertScreen extends StatefulWidget {
  final VoidCallback? onInsertSuccess;

  const BusRouteInsertScreen({Key? key, this.onInsertSuccess})
      : super(key: key);

  @override
  _BusRouteInsertScreenState createState() => _BusRouteInsertScreenState();
}

class _BusRouteInsertScreenState extends State<BusRouteInsertScreen> {
  TextEditingController routeNoController = TextEditingController();
  TextEditingController locationIdController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  List<Map<String, dynamic>> locationData = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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

  void _showSaveResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'สำเร็จ') {
                  Navigator.pop(context);
                }
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBusRouteInfo() async {
    const apiUrl = 'http://localhost/mn_db/busRouteInfo.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '1',
          'route_No': routeNoController.text,
          'locations_id': locationIdController.text,
          'time': '${timeController.text}:00',
        },
      );

      if (response.statusCode == 200) {
        print('บันทึกข้อมูลเส้นทางเดินรถสำเร็จ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกข้อมูลเส้นทางเดินรถสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );

        _showSaveResultDialog('สำเร็จ', 'บันทึกข้อมูลเส้นทางเดินรถสำเร็จ');

        widget.onInsertSuccess?.call();
      } else {
        print('Error saving bus route information: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bus route information'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != TimeOfDay.now()) {
      final formattedHour = picked.hourOfPeriod.toString().padLeft(2, '0');
      final formattedMinute = picked.minute.toString().padLeft(2, '0');
      final formattedTime = '$formattedHour:$formattedMinute';

      setState(() {
        timeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'ข้อมูลเส้นทางเดินรถ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // TextFormField(
              //   controller: routeNoController,
              //   decoration: InputDecoration(labelText: 'Route Number'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a valid Route Number';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 20.0),
              DropdownButtonFormField(
                value: null,
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
                    locationIdController.text = value.toString();
                  });
                },
                decoration: InputDecoration(labelText: 'รหัสสถานที่ท่องเที่ยว'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเลือกรหัสสถานที่ท่องเที่ยว';
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
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveBusRouteInfo();
                  }
                },
                child: Text('บันทึกข้อมูลเส้นทางเดินรถ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
