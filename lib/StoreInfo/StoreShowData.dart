import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mn_641463008/StoreInfo/editStoreInfo.dart';
import 'package:mn_641463008/StoreInfo/insertStoreInfo.dart';
import 'package:mn_641463008/StoreInfo/showStoreInfo.dart';

class StoreShowData extends StatefulWidget {
  @override
  _StoreShowDataState createState() => _StoreShowDataState();
}

class _StoreShowDataState extends State<StoreShowData> {
  late Future<List<Map<String, dynamic>>> _storeData;

  Future<List<Map<String, dynamic>>> _fetchStoreData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/mn_db/selectStoreInfo.php'),
      );

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

  Future<void> _deleteStoreData(String storeId) async {
    final response = await http.post(
      Uri.parse('http://localhost/mn_db/storeInfo.php'),
      body: {
        'case': '3',
        'store_id': '$storeId',
      },
    );

    if (response.statusCode == 200) {
      print('Store data deleted successfully');
    } else {
      print('Failed to delete store data');
    }
  }

  void _refreshStoreData() {
    setState(() {
      _storeData = _fetchStoreData();
    });
  }

  @override
  void initState() {
    super.initState();
    _storeData = _fetchStoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'ข้อมูลร้านค้า',
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
          future: _storeData,
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
                        // Customize the icon or image for store info
                        Icon(
                          Icons.store,
                          size: 40,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ข้อมูลร้านค้า',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
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
                              DataColumn(label: Text('รหัสร้านค้า')),
                              DataColumn(label: Text('ชื่อร้านค้า')),
                              DataColumn(label: Text('ค้นหา')),
                              DataColumn(label: Text('แก้ไข')),
                              DataColumn(label: Text('ลบ')),
                            ],
                            rows: snapshot.data!.map((data) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                      data['store_id']?.toString() ?? 'N/A')),
                                  DataCell(Text(
                                      data['store_name']?.toString() ?? 'N/A')),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.search),
                                      color: Colors.green,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShowStoreInfoPage(
                                              storeId: data['store_id']
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
                                      onPressed: () async {
                                        bool result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateStoreInfoScreen(
                                              storeData: data,
                                              onStoreInfoUpdated:
                                                  _refreshStoreData,
                                            ),
                                          ),
                                        );

                                        // Handle the result if needed
                                        if (result == true) {
                                          print('บันทึกข้อมูลร้านค้าสำเร็จ!');
                                        }
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
                                                'ยืนยันลบข้อมูลร้านค้า',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              content: Text(
                                                'คุณต้องการที่จะลบข้อมูลร้านค้านี้ไหม?',
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('ยกเลิก'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteStoreData(
                                                      data['store_id']
                                                              ?.toString() ??
                                                          '',
                                                    );
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      _storeData =
                                                          _fetchStoreData();
                                                    });
                                                  },
                                                  child: Text(
                                                    'ลบ',
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
              builder: (context) => StoreInsertScreen(
                onInsertSuccess: _refreshStoreData,
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
    home: StoreShowData(),
  ));
}
