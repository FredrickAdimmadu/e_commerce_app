import 'package:flutter/material.dart';
import 'components/body.dart';
import 'package:shopflex/components/custom_appBar.dart';

class ChangeDisplayNameScreen extends StatelessWidget {
  //TODO: setState being called before build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Change Display Name',
      ),
      body: Body(),
    );
  }
}
