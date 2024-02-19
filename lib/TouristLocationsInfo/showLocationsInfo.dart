import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowLocationInfoPage extends StatefulWidget {
  final String locationId;

  ShowLocationInfoPage({required this.locationId});

  @override
  _ShowLocationInfoPageState createState() => _ShowLocationInfoPageState();
}

class _ShowLocationInfoPageState extends State<ShowLocationInfoPage> {
  late Future<Map<String, dynamic>> _locationInfo;

  Future<Map<String, dynamic>> _fetchLocationInfo() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/mn_db/show_location_info.php'),
        body: {'locations_id': widget.locationId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed = json.decode(response.body);
        return parsed;
      } else {
        throw Exception(
            'Failed to load location information. Please try again.');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load location information. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    _locationInfo = _fetchLocationInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลสถานที่ท่องเที่ยว',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _locationInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No store information found'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: <Widget>[
                    Text(
                      'ข้อมูลสถานที่ท่องเที่ยว',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 20.0),
                    Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(3),
                          },
                          children: [
                            buildTableRow('รหัสสถานที่ท่องเที่ยว',
                                snapshot.data!['locations_id']),
                            buildTableRow('ชื่อสถานที่ท่องเที่ยว',
                                snapshot.data!['locations_name']),
                            buildTableRow(
                                'ละติจูด', snapshot.data!['latitude']),
                            buildTableRow(
                                'ลองติจูด', snapshot.data!['longitude']),
                          ],
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
    );
  }

  TableRow buildTableRow(String label, dynamic value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value.toString(),
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
