import 'package:shopflex/constants.dart';
import 'package:shopflex/screens/forgot_password/components/forgot_password_form.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Forgot Password",
                  style: headingStyle,
                ),
                Text(
                  "Please enter your email and we will send \nyou a link to return to your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                //SizedBox(height: 30),
                Image.asset('assets/images/change password.png'),
                //SizedBox(height: 30),
                ForgotPasswordForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
