import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopflex/apis/foodAPIs.dart';
import 'package:shopflex/constants.dart';
import 'package:shopflex/notifiers/authNotifier.dart';
import 'package:shopflex/screens/change_display_picture/change_display_picture_screen.dart';
import 'package:shopflex/screens/change_email/change_email_screen.dart';
import 'package:shopflex/screens/change_password/change_password_screen.dart';
import 'package:shopflex/screens/change_phone/change_phone_screen.dart';
import 'package:shopflex/screens/edit_product/edit_product_screen.dart';
import 'package:shopflex/screens/manage_addresses/manage_addresses_screen.dart';
import 'package:shopflex/screens/my_orders/my_orders_screen.dart';
import 'package:shopflex/screens/my_products/my_products_screen.dart';
import 'package:shopflex/services/authentification/authentification_service.dart';
import 'package:shopflex/services/database/user_database_helper.dart';
import 'package:shopflex/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:provider/provider.dart';
import '../../change_display_name/change_display_name_screen.dart';
import '../../orderDetails.dart';

class HomeScreenDrawer extends StatefulWidget {
  const HomeScreenDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenDrawerState createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
  signOutUser() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    if (authNotifier.user != null) {
      signOut(authNotifier, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        StreamBuilder<User?>(
            stream: AuthentificationService().userChanges,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data;
                return buildUserAccountsHeader(user!);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Center(
                  child: Icon(Icons.error),
                );
              }
            }),
        buildEditAccountExpansionTile(context),
        ListTile(
          leading: Icon(
            Icons.edit_location,
            color: Color(0xFF800f2f),
          ),
          title: Text(
            "Manage Addresses",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          onTap: () async {
            bool allowed = AuthentificationService().currentUserVerified;
            if (!allowed) {
              final reverify = await showConfirmationDialog(context,
                  "You haven't verified your email address. This action is only allowed for verified users.",
                  positiveResponse: "Resend verification email",
                  negativeResponse: "Go back");
              if (reverify) {
                final future = AuthentificationService()
                    .sendVerificationEmailToCurrentUser();
                await showDialog(
                  context: context,
                  builder: (context) {
                    return FutureProgressDialog(
                      future,
                      message: Text("Resending verification email"),
                    );
                  },
                );
              }
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageAddressesScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.delivery_dining,
            color: Color(0xFF800f2f),
          ),
          title: Text(
            "My Orders",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          onTap: () async {
            bool allowed = AuthentificationService().currentUserVerified;
            if (!allowed) {
              final reverify = await showConfirmationDialog(context,
                  "You haven't verified your email address. This action is only allowed for verified users.",
                  positiveResponse: "Resend verification email",
                  negativeResponse: "Go back");
              if (reverify) {
                final future = AuthentificationService()
                    .sendVerificationEmailToCurrentUser();
                await showDialog(
                  context: context,
                  builder: (context) {
                    return FutureProgressDialog(
                      future,
                      message: Text("Resending verification email"),
                    );
                  },
                );
              }
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyOrdersScreen(),
              ),
            );
          },
        ),
        //buildSellerExpansionTile(context),
        ListTile(
          leading: Icon(
            Icons.logout,
            color: Color(0xFF800f2f),
          ),
          title: Text(
            "Sign out",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          onTap: () {
            signOutUser();
          },
        ),
      ],
    );
  }

  Widget buildUserAccountsHeader(User user) {
    return Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Color(0xffa4133c),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              FutureBuilder(
                future: UserDatabaseHelper().displayPictureForCurrentUser,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CircleAvatar(
                      maxRadius: 40,
                      backgroundImage: NetworkImage(snapshot.data.toString()),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    final error = snapshot.error;
                    // Logger().w(error.toString());
                  }
                  return CircleAvatar(
                    maxRadius: 40,
                    backgroundColor: Color(0xff00afb9),
                  );
                },
              ),
              SizedBox(height: 10),
              Text(
                user.displayName ?? "No Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                user.email ?? "No Email",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ));
  }

  ExpansionTile buildEditAccountExpansionTile(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        Icons.person,
        color: Color(0xFF800f2f),
      ),
      title: Text(
        "Edit Account",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      children: [
        ListTile(
          title: Text(
            "Change Display Picture",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeDisplayPictureScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Display Name",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeDisplayNameScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Phone Number",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePhoneScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Email",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeEmailScreen(),
                ));
          },
        ),
        ListTile(
          title: Text(
            "Change Password",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(),
                ));
          },
        ),
      ],
    );
  }
}
