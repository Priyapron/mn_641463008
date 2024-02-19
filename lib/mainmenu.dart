import 'package:flutter/material.dart';
import 'package:mn_641463008/BusInfo/busShowData.dart';
import 'package:mn_641463008/TouristLocationsInfo/LocationsShowData.dart';
import 'package:mn_641463008/BusRoute/busRouteShowData.dart';
import 'package:mn_641463008/StoreInfo/StoreShowData.dart';
import 'package:mn_641463008/gpstracking.dart';
import 'package:mn_641463008/ProductInfo/productShowData.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'เมนูหลัก',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // First Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: buildStyledImageButton(
                      'images/BusIcon.png',
                      'ข้อมูลรถราง',
                      BusShowData(),
                      context,
                    ),
                  ),
                  Expanded(
                    child: buildStyledImageButton(
                      'images/Locations.png',
                      'ข้อมูลสถานที่ท่องเที่ยว',
                      LocationShowData(),
                      context,
                    ),
                  ),
                ],
              ),
              // Second Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: buildStyledImageButton(
                      'images/BusRouteInfo-Photoroom.png-Photoroom.png',
                      'ข้อมูลเส้นทางเดินรถ',
                      BusRouteShowData(),
                      context,
                    ),
                  ),
                  Expanded(
                    child: buildStyledImageButton(
                      'images/StoreInfo-Photoroom.png-Photoroom.png',
                      'ข้อมูลร้านค้า',
                      StoreShowData(),
                      context,
                    ),
                  ),
                ],
              ),
              // tird Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: buildStyledImageButton(
                      'images/productIcon.png',
                      'ข้อมูลสินค้า',
                      ProductShowData(),
                      context,
                    ),
                  ),
                  Expanded(
                    child: buildStyledImageButton(
                      'images/LocationsIcon.png',
                      'จุดท่องเที่ยวทั้งหมด',
                      GPSTracking(),
                      context,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStyledImageButton(String imagePath, String buttonText,
      Widget destination, BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.blue, width: 2.0),
          ),
          elevation: 5.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 200,
              height: 200,
            ),
            SizedBox(height: 15),
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
