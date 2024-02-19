import 'package:mn_641463008/login_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/641463008_travel.png'),
            SizedBox(height: 20.0),
            Text(
              'Welcome!! To Digital Twin สำหรับเส้นทางของรถรางนำเที่ยว',
              style: TextStyle(
                fontSize: 30, // ขนาดตัวอักษร
                color: Colors.indigo, // สีตัวอักษร
                fontWeight:
                    FontWeight.bold, // การกำหนดความหนาของตัวอักษร (ถ้าต้องการ)
              ),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              child: OutlinedButton(
                onPressed: () {
                  // เมื่อปุ่มถูกคลิก
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
                },
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(300, 50),
                  side: BorderSide(
                    color: Colors.indigo, // Set the outline color
                    width: 2.0, // Set the outline width
                  ),
                  backgroundColor: Colors.indigo, // Set the background color
                ),
                child: Text(
                  'เริ่มใช้งาน',
                  style: TextStyle(
                    color: Colors.white, // Set the text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
