import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StoreInsertScreen extends StatefulWidget {
  final VoidCallback? onInsertSuccess;

  const StoreInsertScreen({Key? key, this.onInsertSuccess}) : super(key: key);

  @override
  _StoreInsertScreenState createState() => _StoreInsertScreenState();
}

class _StoreInsertScreenState extends State<StoreInsertScreen> {
  TextEditingController storeIdController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('สำเร็จ'),
          content: Text('บันทึกข้อมูลร้านค้าสำเร็จ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close AlertDialog
                Navigator.pop(context); // Close StoreInsertScreen
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveStoreInfo() async {
    final apiUrl = 'http://localhost/mn_db/storeInfo.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '1', // Use case '1' for saving store information
          'store_id': storeIdController.text,
          'store_name': storeNameController.text,
        },
      );

      if (response.statusCode == 200) {
        print('บันทึกข้อมูลร้านค้าสำเร็จ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกข้อมูลร้านค้าสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );

        // Show the success dialog
        _showSaveSuccessDialog();

        // Call the callback function to notify the parent
        widget.onInsertSuccess?.call();
      } else {
        print('Error saving store information: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving store information'),
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
          'เพิ่มข้อมูลร้านค้า',
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //TextFormField(
            //  controller: storeIdController,
            //  decoration: InputDecoration(labelText: 'Store ID'),
            //),
            SizedBox(height: 20.0),
            TextFormField(
              controller: storeNameController,
              decoration: InputDecoration(labelText: 'ชื่อร้านค้า'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveStoreInfo,
              child: Text('บันทึกข้อมูลร้านค้า'),
            ),
          ],
        ),
      ),
    );
  }
}
