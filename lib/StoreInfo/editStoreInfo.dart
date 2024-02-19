import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateStoreInfoScreen extends StatefulWidget {
  final Map<String, dynamic> storeData;
  final VoidCallback onStoreInfoUpdated; // Callback function

  UpdateStoreInfoScreen(
      {required this.storeData, required this.onStoreInfoUpdated});

  @override
  _UpdateStoreInfoScreenState createState() => _UpdateStoreInfoScreenState();
}

class _UpdateStoreInfoScreenState extends State<UpdateStoreInfoScreen> {
  TextEditingController storeIdController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    storeIdController.text = widget.storeData['store_id']?.toString() ?? '';
    storeNameController.text = widget.storeData['store_name']?.toString() ?? '';
  }

  Future<void> _saveUpdatedStoreInfo() async {
    final apiUrl = 'http://localhost/mn_db/storeInfo.php';

    try {
      showLoadingDialog(); // Show loading indicator

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '2',
          'store_id': storeIdController.text,
          'store_name': storeNameController.text,
        },
      );

      Navigator.pop(context); // Hide loading indicator

      if (response.statusCode == 200) {
        print('แก้ไขข้อมูลร้านค้าสำเร็จ');
        showSuccessDialog();

        // Trigger the callback function
        widget.onStoreInfoUpdated();
      } else {
        print('Error updating store information: ${response.statusCode}');
        showErrorSnackBar('Error updating store information');
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
          content: Text('แก้ไขข้อมูลร้านค้าสำเร็จ'),
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
          'แก้ไขข้อมูลร้านค้า',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: storeIdController,
              decoration: InputDecoration(labelText: 'รหัสร้านค้า'),
              enabled: false,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: storeNameController,
              decoration: InputDecoration(labelText: 'ชื่อร้านค้า'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveUpdatedStoreInfo,
              child: Text('แก้ไขข้อมูลร้านค้า'),
            ),
          ],
        ),
      ),
    );
  }
}
