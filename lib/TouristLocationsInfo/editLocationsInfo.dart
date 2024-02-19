import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateLocationInfoScreen extends StatefulWidget {
  final Map<String, dynamic> locationData;
  final VoidCallback onLocationInfoUpdated; // Callback function

  UpdateLocationInfoScreen(
      {required this.locationData, required this.onLocationInfoUpdated});

  @override
  _UpdateLocationInfoScreenState createState() =>
      _UpdateLocationInfoScreenState();
}

class _UpdateLocationInfoScreenState extends State<UpdateLocationInfoScreen> {
  TextEditingController locationIdController = TextEditingController();
  TextEditingController locationNameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    locationIdController.text =
        widget.locationData['locations_id']?.toString() ?? '';
    locationNameController.text =
        widget.locationData['locations_name']?.toString() ?? '';
    latitudeController.text = widget.locationData['latitude']?.toString() ?? '';
    longitudeController.text =
        widget.locationData['longitude']?.toString() ?? '';
  }

  Future<void> _saveUpdatedLocationInfo() async {
    final apiUrl = 'http://localhost/mn_db/locationInfo.php';

    try {
      showLoadingDialog(); // Show loading indicator

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '2',
          'locations_id': locationIdController.text,
          'locations_name': locationNameController.text,
          'latitude': latitudeController.text,
          'longitude': longitudeController.text,
        },
      );

      Navigator.pop(context); // Hide loading indicator

      if (response.statusCode == 200) {
        print('แก้ไขข้อมูลสถานที่ท่องเที่ยวสำเร็จ');
        showSuccessDialog();

        // Trigger the callback function
        widget.onLocationInfoUpdated();
      } else {
        print('Error updating location information: ${response.statusCode}');
        final errorMessage =
            response.body; // Get the error message from the response
        showErrorSnackBar('Error updating location information: $errorMessage');
      }
    } catch (e) {
      print('Exception: $e');
      showErrorSnackBar('Error: $e');
    }
  }

  // Show loading indicator
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

  // Show success dialog
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('สำเร็จ'),
          content: Text('แก้ไขข้อมูลสถานที่ท่องเที่ยวสำเร็จ'),
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

  // Show error snackbar
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
          'แก้ไขข้อมูลสถานที่ท่องเที่ยว',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: locationIdController,
              decoration: InputDecoration(labelText: 'รหัสสถานที่ท่องเที่ยว'),
              enabled: false,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: locationNameController,
              decoration: InputDecoration(labelText: 'ชื่อสถานที่ท่องเที่ยว'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: 'ละติจูด'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: 'ลองติจูด'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveUpdatedLocationInfo,
              child: Text('แก้ไขข้อมูลสถานที่ท่องเที่ยวสำเร็จ'),
            ),
          ],
        ),
      ),
    );
  }
}
