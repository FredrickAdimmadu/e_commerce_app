import 'package:flutter/material.dart';
import 'components/body.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const String routeName = "/forgot_password";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF800f2f),
        centerTitle: true,
        title: Text('Change password'),
      ),
      backgroundColor: Color(0xffffccd5),
      body: Body(),
    );
  }
}
