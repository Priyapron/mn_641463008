import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mn_641463008/TouristLocationsInfo/editLocationsInfo.dart';
import 'package:mn_641463008/TouristLocationsInfo/showLocationsInfo.dart';
import 'package:mn_641463008/TouristLocationsInfo/LocationsInsert.dart';

class LocationShowData extends StatefulWidget {
  @override
  _LocationShowDataState createState() => _LocationShowDataState();
}

class _LocationShowDataState extends State<LocationShowData> {
  late Future<List<Map<String, dynamic>>> _locationData;

  Future<List<Map<String, dynamic>>> _fetchLocationData() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/mn_db/selectLocationInfo.php'));
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

  Future<void> _deleteLocationData(String locationId) async {
    final response = await http.post(
      Uri.parse('http://localhost/mn_db/locationInfo.php'),
      body: {
        'case': '3',
        'locations_id': '$locationId',
      },
    );

    if (response.statusCode == 200) {
      print('ลบข้อมูลสถานที่ท่องเที่ยวสำเร็จ');
    } else {
      print('ไม่สามารถลบข้อมูลสถานที่ท่องเที่ยวได้');
    }
  }

  void _refreshLocationData() {
    setState(() {
      _locationData = _fetchLocationData();
    });
  }

  @override
  void initState() {
    super.initState();
    _locationData = _fetchLocationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo, // Change to your preferred color
        title: Text(
          'ข้อมูลสถานที่ท่องเที่ยว',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _locationData,
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
                        // Customize the icon or image for location info
                        Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ข้อมูลสถานที่ท่องเที่ยว',
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
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the border radius as needed
                              border: Border.all(color: Colors.grey[600]!),
                            ),
                            columns: <DataColumn>[
                              DataColumn(label: Text('รหัสสถานที่ท่องเที่ยว')),
                              DataColumn(label: Text('ชื่อสถานที่ท่องเที่ยว')),
                              DataColumn(label: Text('ค้นหา')),
                              DataColumn(label: Text('แก้ไข')),
                              DataColumn(label: Text('ลบ')),
                            ],
                            rows: snapshot.data!.map((data) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                      data['locations_id']?.toString() ??
                                          'N/A')),
                                  DataCell(Text(
                                      data['locations_name']?.toString() ??
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
                                                ShowLocationInfoPage(
                                              locationId: data['locations_id']
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
                                                UpdateLocationInfoScreen(
                                              locationData: data,
                                              onLocationInfoUpdated:
                                                  _refreshLocationData,
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
                                                'ยืนยันลบข้อมูลสถานที่ท่องเที่ยว',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              content: Text(
                                                  'คุณแน่ใจใช่ไหมว่าต้องการลบข้อมูลสถานที่ท่องเที่ยว?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('ยกเลิก'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteLocationData(
                                                        data['locations_id']
                                                                ?.toString() ??
                                                            '');
                                                    Navigator.of(context).pop();
                                                    _refreshLocationData();
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
              builder: (context) => LocationInsertScreen(
                onInsertSuccess: _refreshLocationData,
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo, // Change to your preferred color
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LocationShowData(),
  ));
}
