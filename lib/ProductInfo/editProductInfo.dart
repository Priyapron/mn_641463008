import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateProductInfoScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final VoidCallback onProductInfoUpdated;

  UpdateProductInfoScreen({
    required this.productData,
    required this.onProductInfoUpdated,
  });

  @override
  _UpdateProductInfoScreenState createState() =>
      _UpdateProductInfoScreenState();
}

class _UpdateProductInfoScreenState extends State<UpdateProductInfoScreen> {
  TextEditingController productIdController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController countingUnitController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String? selectedStoreId;
  List<Map<String, dynamic>> stores = [];

  @override
  void initState() {
    super.initState();
    fetchStoreData();

    productIdController.text =
        widget.productData['product_id']?.toString() ?? '';
    productNameController.text =
        widget.productData['product_name']?.toString() ?? '';
    countingUnitController.text =
        widget.productData['counting_unit']?.toString() ?? '';
    priceController.text = widget.productData['price']?.toString() ?? '';
    selectedStoreId = widget.productData['store_id']?.toString() ?? null;
  }

  Future<void> fetchStoreData() async {
    const apiUrl = 'http://localhost/mn_db/get_StoreData.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
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

  Future<void> _saveUpdatedProductInfo() async {
    final apiUrl = 'http://localhost/mn_db/productInfo.php';

    try {
      showLoadingDialog();

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'case': '2',
          'store_id': selectedStoreId ?? '',
          'product_id': productIdController.text,
          'product_name': productNameController.text,
          'counting_unit': countingUnitController.text,
          'price': priceController.text,
        },
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        print('แก้ไขข้อมูลสินค้าสำเร็จ');
        showSuccessDialog();
        widget.onProductInfoUpdated();
      } else {
        print('Error updating product information: ${response.statusCode}');
        final errorMessage = response.body;
        showErrorSnackBar('Error updating product information: $errorMessage');
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
          content: Text('แก้ไขข้อมูลสินค้าสำเร็จ'),
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
          'แก้ไขข้อมูลสินค้า',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              decoration: InputDecoration(labelText: 'เลือกข้อมูลร้านค้า'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเลือกข้อมูลร้านค้า';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: productIdController,
              decoration: InputDecoration(labelText: 'รหัสสินค้า'),
              enabled: false,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: countingUnitController,
              decoration: InputDecoration(labelText: 'หน่วยนับ'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'ราคา'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveUpdatedProductInfo,
              child: Text('แก้ไขข้อมูลสินค้าสำเร็จ'),
            ),
          ],
        ),
      ),
    );
  }
}
