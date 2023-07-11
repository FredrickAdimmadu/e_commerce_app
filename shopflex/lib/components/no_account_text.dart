import 'package:shopflex/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:shopflex/size_config.dart';
import 'package:shopflex/constants.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignupPage()));
          },
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF800f2f),
            ),
          ),
        ),
      ],
    );
  }
}
