import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusInsertScreen extends StatefulWidget {
  final VoidCallback? onInsertSuccess;

  const BusInsertScreen({Key? key, this.onInsertSuccess}) : super(key: key);

  @override
  _BusInsertScreenState createState() => _BusInsertScreenState();
}

class _BusInsertScreenState extends State<BusInsertScreen> {
  TextEditingController busIdController = TextEditingController();
  TextEditingController busNumberController = TextEditingController();

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Successfully'),
          content: Text('บันทึกข้อมูลรถรางสำเร็จ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close AlertDialog
                Navigator.pop(context); // Close BusInsertScreen
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBusInfo() async {
    final apiUrl = 'http://localhost/mn_db/busInfo.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '1', // Use case '1' for saving bus information
          'bus_id': busIdController.text,
          'bus_number': busNumberController.text,
        },
      );

      if (response.statusCode == 200) {
        print('Bus information saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bus information saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Show the success dialog
        _showSaveSuccessDialog();

        // Call the callback function to notify the parent (BusShowData)
        widget.onInsertSuccess?.call();
      } else {
        print('Error saving bus information: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bus information'),
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
          'ข้อมูลรถราง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //TextFormField(
            //  controller: busIdController,
            //  decoration: InputDecoration(labelText: 'Bus ID'),
            //),
            SizedBox(height: 20.0),
            TextFormField(
              controller: busNumberController,
              decoration: InputDecoration(labelText: 'หมายเลขรถราง'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveBusInfo,
              child: Text('บันทึกข้อมูลรถราง'),
            ),
          ],
        ),
      ),
    );
  }
}
