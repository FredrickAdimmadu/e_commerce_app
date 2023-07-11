import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopflex/apis/foodAPIs.dart';
import 'package:shopflex/notifiers/authNotifier.dart';

import 'edit_product/edit_product_screen.dart';
import 'my_products/my_products_screen.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();
  String name = '';

  signOutUser() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    if (authNotifier.user != null) {
      signOut(authNotifier, context);
    }
  }

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    getUserDetails(authNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF800f2f),
        title: Text('Pocket MarketZone'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              signOutUser();
            },
          )
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Add New Product",
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            onTap: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProductScreen()));
            },
          ), //
          ListTile(
            title: Text(
              "Manage My Products",
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProductsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
