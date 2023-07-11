import 'package:flutter/material.dart';
import 'components/body.dart';
import 'package:shopflex/components/custom_appBar.dart';

class ChangeDisplayPictureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Change Avatar',
      ),
      body: Body(),
    );
  }
}
