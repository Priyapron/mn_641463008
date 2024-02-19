import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductInsertScreen extends StatefulWidget {
  final VoidCallback? onInsertSuccess;

  const ProductInsertScreen({Key? key, this.onInsertSuccess}) : super(key: key);

  @override
  _ProductInsertScreenState createState() => _ProductInsertScreenState();
}

class _ProductInsertScreenState extends State<ProductInsertScreen> {
  TextEditingController productIdController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController countingUnitController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String? selectedStoreId; // Allow null for initialization
  List<Map<String, dynamic>> stores = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    const apiUrl = 'http://localhost/mn_db/get_StoreData.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the response and store the store_info data
        final dynamic responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          stores = responseData.cast<Map<String, dynamic>>();
          setState(() {});
        } else {
          print('Error: Invalid response format');
        }
      } else {
        print('Error fetching store information: ${response.statusCode}');
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

  Future<void> _saveProductInfo() async {
    const apiUrl = 'http://localhost/mn_db/productInfo.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '1',
          'store_id': selectedStoreId ?? '', // Ensure it's not null
          'product_id': productIdController.text,
          'product_name': productNameController.text,
          'counting_unit': countingUnitController.text,
          'price': priceController.text,
        },
      );

      if (response.statusCode == 200) {
        print('บันทึกข้อมูลสินค้าสำเร็จ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกข้อมูลสินค้าสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );

        _showSaveResultDialog('สำเร็จ', 'บันทึกข้อมูลสินค้าสำเร็จ');

        widget.onInsertSuccess?.call();
      } else {
        print('Error saving product information: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product information'),
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
          'ข้อมูลสินค้า',
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
              DropdownButtonFormField<String>(
                value: selectedStoreId,
                onChanged: (newValue) {
                  setState(() {
                    selectedStoreId = newValue;
                  });
                },
                items: stores.map<DropdownMenuItem<String>>((store) {
                  return DropdownMenuItem<String>(
                    value: store['store_id'].toString(),
                    child: Row(
                      children: [
                        Text('${store['store_id']} - '),
                        Text(
                          store['store_name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'เลือกร้านค้า'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a valid Store';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: productNameController,
                decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาป้อนชื่อสินค้า';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: countingUnitController,
                decoration: InputDecoration(labelText: 'หน่วยนับ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเพิ่มหน่วยนับ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'ราคา'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเพิ่มราคา';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveProductInfo();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all required fields'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('บันทึกข้อมูลสินค้าสำเร็จ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
