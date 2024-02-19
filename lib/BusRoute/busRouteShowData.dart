import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mn_641463008/BusRoute/editBusRoute.dart';
import 'package:mn_641463008/BusRoute/showBusRouteInfo.dart';
import 'package:mn_641463008/BusRoute/busRouteInsert.dart';

class BusRouteShowData extends StatefulWidget {
  @override
  _BusRouteShowDataState createState() => _BusRouteShowDataState();
}

class _BusRouteShowDataState extends State<BusRouteShowData> {
  late Future<List<Map<String, dynamic>>> _busRouteData;

  Future<List<Map<String, dynamic>>> _fetchBusRouteData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/mn_db/selectBusRouteInfo.php'),
      );
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

  Future<void> _deleteBusRouteData(String routeNo) async {
    final response = await http.post(
      Uri.parse('http://localhost/mn_db/busRouteInfo.php'),
      body: {
        'case': '3',
        'route_No': '$routeNo',
      },
    );

    if (response.statusCode == 200) {
      print('ลบข้อมูลเส้นทางเดินรถสำเร็จ');
    } else {
      print('ลบข้อมูลเส้นทางเดินรถไม่สำเร็จ');
    }
  }

  void _refreshBusRouteData() {
    setState(() {
      _busRouteData = _fetchBusRouteData();
    });
  }

  @override
  void initState() {
    super.initState();
    _busRouteData = _fetchBusRouteData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'ข้อมูลเส้นทางเดินรถ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Align(
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
                  'ข้อมูลเส้นทางเดินรถ',
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
                  child: Container(
                    padding: EdgeInsets.all(16.0), // Adjust padding as needed
                    margin: EdgeInsets.symmetric(
                        vertical: 10.0), // Adjust margin as needed
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _busRouteData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.indigo),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No data found'));
                        } else {
                          return DataTable(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[600]!),
                            ),
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            columns: <DataColumn>[
                              DataColumn(label: Text('ลำดับที่')),
                              DataColumn(label: Text('รหัสสถานที่')),
                              DataColumn(label: Text('เวลา')),
                              DataColumn(label: Text('ค้นหา')),
                              DataColumn(label: Text('แก้ไข')),
                              DataColumn(label: Text('ลบ')),
                            ],
                            rows: snapshot.data!.map((data) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                      data['route_No']?.toString() ?? 'N/A')),
                                  DataCell(
                                    Text(data['locations_id']?.toString() ??
                                        'N/A'),
                                  ),
                                  DataCell(
                                      Text(data['time']?.toString() ?? 'N/A')),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.search),
                                      color: Colors.teal,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShowBusRouteInfoPage(
                                              routeNo: data['route_No']
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
                                                UpdateBusRouteScreen(
                                              busRouteData: data,
                                              onBusRouteUpdated:
                                                  _refreshBusRouteData,
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              title: Text(
                                                'ยืนยันการลบข้อมูลเส้นทางเดินรถ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              content: Text(
                                                  'คุณต้องการที่จะลบข้อมูลเส้นทางเดินรถนี้หรือไม่?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('ยกเลิก'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteBusRouteData(
                                                      data['route_No']
                                                              ?.toString() ??
                                                          '',
                                                    );
                                                    Navigator.of(context).pop();
                                                    _refreshBusRouteData();
                                                  },
                                                  child: Text(
                                                    'ยืนยัน',
                                                    style: TextStyle(
                                                        color: Colors.red),
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
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusRouteInsertScreen(
                onInsertSuccess: _refreshBusRouteData,
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
    home: BusRouteShowData(),
  ));
}
