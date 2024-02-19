import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationInsertScreen extends StatefulWidget {
  final VoidCallback? onInsertSuccess;

  const LocationInsertScreen({Key? key, this.onInsertSuccess})
      : super(key: key);

  @override
  _LocationInsertScreenState createState() => _LocationInsertScreenState();
}

class _LocationInsertScreenState extends State<LocationInsertScreen> {
  TextEditingController locationIdController = TextEditingController();
  TextEditingController locationNameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  final _formKey =
      GlobalKey<FormState>(); // Add this line to define the form key

  @override
  void dispose() {
    locationIdController.dispose();
    locationNameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
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
                Navigator.of(context).pop(); // Close AlertDialog
                if (title == 'สำเร็จ') {
                  Navigator.pop(context); // Close LocationInsertScreen
                }
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveLocationInfo() async {
    const apiUrl = 'http://localhost/mn_db/locationInfo.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '1', // Use case '1' for saving location information
          'locations_id': locationIdController.text,
          'locations_name': locationNameController.text,
          'latitude': latitudeController.text,
          'longitude': longitudeController.text,
        },
      );

      if (response.statusCode == 200) {
        print('บันทึกข้อมูลสถานที่ท่องเที่ยวสำเร็จ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกข้อมูลสถานที่ท่องเที่ยวสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );

        // Show the success dialog
        _showSaveResultDialog('สำเร็จ', 'บันทึกข้อมูลสถานที่ท่องเที่ยวสำเร็จ');

        // Call the callback function to notify the parent
        widget.onInsertSuccess?.call();
      } else {
        print('Error saving location information: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving location information'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'ข้อมูลสถานที่ท่องเที่ยว',
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
              //TextFormField(
              //controller: locationIdController,
              //decoration: InputDecoration(labelText: 'Location ID'),
              //validator: (value) {
              //  if (value == null || value.isEmpty) {
              //    return 'Please enter a valid Location ID';
              //  }
              //  return null;
              //},
              //),
              SizedBox(height: 20.0),
              TextFormField(
                controller: locationNameController,
                decoration: InputDecoration(labelText: 'ชื่อสถานที่ท่องเที่ยว'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อสถานที่ท่องเที่ยว';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: latitudeController,
                decoration: InputDecoration(labelText: 'ละติจูด'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเพิ่มละติจูด';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: longitudeController,
                decoration: InputDecoration(labelText: 'ลองติจูด'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเพิ่มลองติจูด';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveLocationInfo();
                  }
                },
                child: Text('บันทึกข้อมูลสถานที่ท่องเที่ยวสำเร็จ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
