import 'package:shopflex/services/authentification/authentification_service.dart';
import 'package:shopflex/services/database/user_database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../utils.dart';

class AddToCartFAB extends StatelessWidget {
  const AddToCartFAB({
    Key? key,
    required this.productId,
  }) : super(key: key);

  final String productId;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Color(0xFF800f2f),
      onPressed: () async {
        bool allowed = AuthentificationService().currentUserVerified;
        if (!allowed) {
          final reverify = await showConfirmationDialog(context,
              "You haven't verified your email address. This action is only allowed for verified users.",
              positiveResponse: "Resend verification email",
              negativeResponse: "Go back");
          if (reverify) {
            final future =
                AuthentificationService().sendVerificationEmailToCurrentUser();
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
        bool addedSuccessfully = false;
        late String toast;
        try {
          addedSuccessfully =
              await UserDatabaseHelper().addProductToCart(productId);
          if (addedSuccessfully == true) {
            toast = "Product added successfully";
          } else {
            throw "Coulnd't add product due to unknown reason";
          }
        } on FirebaseException catch (e) {
          //Logger().w("Firebase Exception: $e");
          toast = "Something went wrong";
        } catch (e) {
          //Logger().w("Unknown Exception: $e");
          toast = "Something went wrong";
        } finally {
          //Logger().i(toast);
          Fluttertoast.showToast(
              msg: toast,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey,
              textColor: Colors.white);
        }
      },
      label: Text(
        "Add to Cart",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      icon: Icon(
        Icons.shopping_cart,
      ),
    );
  }
}
