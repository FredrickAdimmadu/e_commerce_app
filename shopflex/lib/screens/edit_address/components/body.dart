import 'package:shopflex/constants.dart';
import 'package:shopflex/models/Address.dart';
import 'package:shopflex/services/database/user_database_helper.dart';
import 'package:shopflex/size_config.dart';
import 'package:flutter/material.dart';

import 'address_details_form.dart';

class Body extends StatelessWidget {
  final String? addressIdToEdit;

  const Body({Key? key, this.addressIdToEdit}) : super(key: key);
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
                  "Fill Address Details",
                  style: headingStyle,
                ),
                SizedBox(height: 30),
                addressIdToEdit == null
                    ? AddressDetailsForm(
                        addressToEdit: null,
                      )
                    : FutureBuilder<Address>(
                        future: UserDatabaseHelper()
                            .getAddressFromId(addressIdToEdit!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final address = snapshot.data;
                            return AddressDetailsForm(addressToEdit: address);
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return AddressDetailsForm(
                            addressToEdit: null,
                          );
                        },
                      ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
