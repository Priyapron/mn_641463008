import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateBusInfoScreen extends StatefulWidget {
  final Map<String, dynamic> busData;
  final VoidCallback onBusInfoUpdated; // Callback function

  UpdateBusInfoScreen({required this.busData, required this.onBusInfoUpdated});

  @override
  _UpdateBusInfoScreenState createState() => _UpdateBusInfoScreenState();
}

class _UpdateBusInfoScreenState extends State<UpdateBusInfoScreen> {
  TextEditingController busIdController = TextEditingController();
  TextEditingController busNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    busIdController.text = widget.busData['bus_id']?.toString() ?? '';
    busNumberController.text = widget.busData['bus_number']?.toString() ?? '';
  }

  Future<void> _saveUpdatedBusInfo() async {
    final apiUrl = 'http://localhost/mn_db/busInfo.php';

    try {
      showLoadingDialog(); // Show loading indicator

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '2',
          'bus_id': busIdController.text,
          'bus_number': busNumberController.text,
        },
      );

      Navigator.pop(context); // Hide loading indicator

      if (response.statusCode == 200) {
        print('อัปเดทข้อมูลรถรางสำเร็จ');
        showSuccessDialog();

        // Trigger the callback function
        widget.onBusInfoUpdated();
      } else {
        print('Error updating bus information: ${response.statusCode}');
        showErrorSnackBar('Error updating bus information');
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
          content: Text('แก้ไขข้อมูลรถรางสำเร็จ'),
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
          'แก้ไขข้อมูลรถราง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: busIdController,
              decoration: InputDecoration(labelText: 'รหัสรถราง'),
              enabled: false,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: busNumberController,
              decoration: InputDecoration(labelText: 'หมายเลขรถราง'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveUpdatedBusInfo,
              child: Text('บันทึกการแก้ไข ข้อมูลรถราง'),
            ),
          ],
        ),
      ),
    );
  }
}
