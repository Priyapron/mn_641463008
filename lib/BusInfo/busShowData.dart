import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mn_641463008/BusInfo/bus_insertScreen.dart';
import 'package:mn_641463008/BusInfo/showBusInfo.dart';
import 'package:mn_641463008/BusInfo/editBusInfo.dart';

class BusShowData extends StatefulWidget {
  @override
  _BusShowDataState createState() => _BusShowDataState();
}

class _BusShowDataState extends State<BusShowData> {
  late Future<List<Map<String, dynamic>>> _busData;

  Future<List<Map<String, dynamic>>> _fetchBusData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/mn_db/selectBusInfo.php'));
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

  Future<void> _deleteBusData(String busId) async {
    final response = await http.post(
      Uri.parse('http://localhost/mn_db/busInfo.php'),
      body: {
        'case': '3',
        'bus_id': '$busId',
      },
    );

    if (response.statusCode == 200) {
      print('ลบข้อมูลรถรางสำเร็จ');
    } else {
      print('ไม่สามารถลบข้อมูลรถรางได้');
    }
  }

  void _refreshBusData() {
    setState(() {
      _busData = _fetchBusData();
    });
  }

  @override
  void initState() {
    super.initState();
    _busData = _fetchBusData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo, // Change color to your preference
        title: Text(
          'ข้อมูลรถราง',
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
          future: _busData,
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
                          Icons.directions_bus,
                          size: 40,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ตารางแสดงข้อมูลรถราง',
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
                              DataColumn(label: Text('รหัสรถราง')),
                              DataColumn(label: Text('หมายเลขรถราง')),
                              DataColumn(label: Text('ค้นหา')),
                              DataColumn(label: Text('แก้ไข')),
                              DataColumn(label: Text('ลบ')),
                            ],
                            rows: snapshot.data!.map((data) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                      data['bus_id']?.toString() ?? 'N/A')),
                                  DataCell(Text(
                                      data['bus_number']?.toString() ?? 'N/A')),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.search),
                                      color: Colors.green,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShowBusInfoPage(
                                              busId:
                                                  data['bus_id']?.toString() ??
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
                                                UpdateBusInfoScreen(
                                              busData: data,
                                              onBusInfoUpdated: _refreshBusData,
                                            ),
                                          ),
                                        );

                                        // Handle the result if needed
                                        if (result == true) {
                                          print('แก้ไขข้อมูลสำเร็จ!');
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
                                                'ยืนยันลบข้อมูลรถราง',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              content: Text(
                                                'คุณแน่ใจใช่ไหมว่าต้องการลบข้อมูลรถราง?',
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
                                                    await _deleteBusData(
                                                      data['bus_id']
                                                              ?.toString() ??
                                                          '',
                                                    );
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      _busData =
                                                          _fetchBusData();
                                                    });
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
              builder: (context) => BusInsertScreen(
                onInsertSuccess: _refreshBusData,
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
    home: BusShowData(),
  ));
}
