import 'package:flutter/material.dart';
import 'components/body.dart';

class MyProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFd8e2dc),
      appBar: AppBar(
        backgroundColor: Color(0xFF800f2f),
        centerTitle: true,
        title: Text('Edit Product'),
      ),
      body: Body(),
      //body: Body(),
    );
  }
}
