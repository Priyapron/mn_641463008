import 'package:mn_641463008/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterUserForm extends StatefulWidget {
  @override
  _RegisterUserFormState createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<RegisterUserForm> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phonController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void registerUser() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String address = addressController.text;
    String phon = phonController.text;
    String email = emailController.text;
    String username = usernameController.text;
    String password = passwordController.text;

    String apiUrl = 'http://localhost/mn_db/saveregister.php';

    Map<String, dynamic> requestBody = {
      'firstname': firstName,
      'lastname': lastName,
      'address': address,
      'phon': phon,
      'email': email,
      'username': username,
      'password': password,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        showSuccessDialog(context);
      } else {
        print('Failed to register user');
      }
    } catch (error) {
      print('Error connecting to the server: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แบบฟอร์มสมัครสมาชิก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'ชื่อ'),
            ),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'นามสกุล'),
            ),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'ที่อยู่'),
            ),
            TextFormField(
              controller: phonController,
              decoration: InputDecoration(labelText: 'เบอร์โทรศัพท์'),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'อีเมล'),
            ),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('สมัครสมาชิก'),
            ),
          ],
        ),
      ),
    );
  }
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('สำเร็จ'),
        content: Text('บันทึกข้อมูลสำเร็จ'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
            },
            child: Text('ไปยังหน้าลงชื่อเข้าใช้'),
          ),
        ],
      );
    },
  );
}
