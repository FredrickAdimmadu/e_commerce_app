import 'package:flutter/material.dart';
import 'package:shopflex/components/custom_appBar.dart';
import 'components/body.dart';

class EditAddressScreen extends StatelessWidget {
  final String? addressIdToEdit;

  const EditAddressScreen({Key? key, this.addressIdToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Address',
      ),
      body: Body(addressIdToEdit: addressIdToEdit),
    );
  }
}
