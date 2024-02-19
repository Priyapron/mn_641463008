import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mn_641463008/ProductInfo/editProductInfo.dart';
import 'package:mn_641463008/ProductInfo/showProductInfo.dart';
import 'package:mn_641463008/ProductInfo/insertProductInfo.dart';

class ProductShowData extends StatefulWidget {
  @override
  _ProductShowDataState createState() => _ProductShowDataState();
}

class _ProductShowDataState extends State<ProductShowData> {
  late Future<List<Map<String, dynamic>>> _productData;

  Future<List<Map<String, dynamic>>> _fetchProductData() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/mn_db/selectProductInfo.php'));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> parsed = json.decode(response.body);
        return parsed.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Cannot connect to data. Please check.');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Cannot connect to data. Please check.');
    }
  }

  Future<void> _deleteProductData(String productId) async {
    final response = await http.post(
      Uri.parse('http://localhost/mn_db/productInfo.php'),
      body: {
        'case': '3',
        'product_id': '$productId',
      },
    );

    if (response.statusCode == 200) {
      print('ลบข้อมูลสินค้าสำเร็จ');
    } else {
      print('ไม่สามารถลบข้อมูลสินค้าได้');
    }
  }

  void _refreshProductData() {
    setState(() {
      _productData = _fetchProductData();
    });
  }

  @override
  void initState() {
    super.initState();
    _productData = _fetchProductData();
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
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _productData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data found'));
            } else {
              return Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: 40,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ข้อมูลสินค้า',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: DataTable(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[600]!),
                            ),
                            columns: <DataColumn>[
                              DataColumn(label: Text('รหัสสินค้า')),
                              DataColumn(label: Text('ชื่อสินค้า')),
                              DataColumn(label: Text('ค้นหา')),
                              DataColumn(label: Text('แก้ไข')),
                              DataColumn(label: Text('ลบ')),
                            ],
                            rows: snapshot.data!.map((data) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                      data['product_id']?.toString() ?? 'N/A')),
                                  DataCell(Text(
                                      data['product_name']?.toString() ??
                                          'N/A')),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.search),
                                      color: Colors.green,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShowProductInfoPage(
                                              productId: data['product_id']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateProductInfoScreen(
                                              productData: data,
                                              onProductInfoUpdated:
                                                  _refreshProductData,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                'ยืนยันลบข้อมูลสินค้า',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              content: Text(
                                                  'คุณแน่ใจใช่ไหมว่าต้องการลบข้อมูลสินค้า?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('ยกเลิก'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteProductData(
                                                        data['product_id']
                                                                ?.toString() ??
                                                            '');
                                                    Navigator.of(context).pop();
                                                    _refreshProductData();
                                                  },
                                                  child: Text(
                                                    'ยืนยัน',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductInsertScreen(
                onInsertSuccess: _refreshProductData,
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductShowData(),
  ));
}
