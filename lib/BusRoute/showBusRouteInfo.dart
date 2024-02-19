import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowBusRouteInfoPage extends StatefulWidget {
  final String routeNo;

  ShowBusRouteInfoPage({required this.routeNo});

  @override
  _ShowBusRouteInfoPageState createState() => _ShowBusRouteInfoPageState();
}

class _ShowBusRouteInfoPageState extends State<ShowBusRouteInfoPage> {
  late Future<Map<String, dynamic>> _busRouteInfo;

  Future<Map<String, dynamic>> _fetchBusRouteInfo() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/mn_db/show_bus_route_info.php'),
        body: {'route_No': widget.routeNo},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed = json.decode(response.body);
        return parsed;
      } else {
        throw Exception(
            'Failed to load bus route information. Please try again.');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception(
          'Failed to load bus route information. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    _busRouteInfo = _fetchBusRouteInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลเส้นทางเดินรถ',
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
          future: _busRouteInfo,
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
                      'ข้อมูลเส้นทางเดินรถ',
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
                            buildTableRow(
                                'ลำดับที่', snapshot.data!['route_No']),
                            buildTableRow(
                                'รหัสสถานที่', snapshot.data!['locations_id']),
                            buildTableRow('เวลา', snapshot.data!['time']),
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
