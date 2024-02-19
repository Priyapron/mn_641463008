import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowStoreInfoPage extends StatefulWidget {
  final String storeId;

  ShowStoreInfoPage({required this.storeId});

  @override
  _ShowStoreInfoPageState createState() => _ShowStoreInfoPageState();
}

class _ShowStoreInfoPageState extends State<ShowStoreInfoPage> {
  late Future<Map<String, dynamic>> _storeInfo;

  Future<Map<String, dynamic>> _fetchStoreInfo() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/mn_db/show_store_info.php'),
        body: {'store_id': widget.storeId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed = json.decode(response.body);
        return parsed;
      } else {
        throw Exception('Failed to load store information');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load store information');
    }
  }

  @override
  void initState() {
    super.initState();
    _storeInfo = _fetchStoreInfo();
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
            colors: [Color.fromARGB(255, 255, 255, 255), Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _storeInfo,
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
                      'ข้อมูลร้านค้า',
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
                                'รหัสร้านค้า', snapshot.data!['store_id']),
                            buildTableRow(
                                'ชื่อร้านค้า', snapshot.data!['store_name']),
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
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            padding: EdgeInsets.all(8.0),
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
