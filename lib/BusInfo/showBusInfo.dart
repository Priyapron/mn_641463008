import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowBusInfoPage extends StatefulWidget {
  final String busId;

  ShowBusInfoPage({required this.busId});

  @override
  _ShowBusInfoPageState createState() => _ShowBusInfoPageState();
}

class _ShowBusInfoPageState extends State<ShowBusInfoPage> {
  late Future<Map<String, dynamic>> _busInfo;

  Future<Map<String, dynamic>> _fetchBusInfo() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/mn_db/show_bus_info.php'),
        body: {'bus_id': widget.busId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed = json.decode(response.body);
        return parsed;
      } else {
        throw Exception(
            'Failed to load bus information: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load bus information: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _busInfo = _fetchBusInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลรถราง',
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
          future: _busInfo,
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
                      'ข้อมูลรถราง',
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
                                'รหัสรถราง', snapshot.data!['bus_id']),
                            buildTableRow(
                                'หมายเลขรถราง', snapshot.data!['bus_number']),
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

void main() {
  runApp(
    MaterialApp(
      home: ShowBusInfoPage(busId: 'your_bus_id'),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 56, 136, 255),
        scaffoldBackgroundColor: Colors.white,
      ),
    ),
  );
}
