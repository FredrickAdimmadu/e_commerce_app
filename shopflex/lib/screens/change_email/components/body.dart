import 'package:shopflex/constants.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';
import '../components/change_email_form.dart';

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
                SizedBox(height: 40),
                Text(
                  "Change Email",
                  style: headingStyle,
                ),
                SizedBox(height: 10),
                ChangeEmailForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
