import 'package:flutter/material.dart';
import 'components/body.dart';
import 'package:shopflex/components/custom_appBar.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Cart',
      ),
      body: Body(),
    );
  }
}
