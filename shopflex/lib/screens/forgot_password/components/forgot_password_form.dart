import 'package:shopflex/components/custom_suffix_icon.dart';
import 'package:shopflex/components/default_button.dart';

import 'package:shopflex/components/no_account_text.dart';
import 'package:shopflex/exceptions/firebaseauth/messeged_firebaseauth_exception.dart';
import 'package:shopflex/exceptions/firebaseauth/credential_actions_exceptions.dart';
import 'package:shopflex/services/authentification/authentification_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../constants.dart';

class ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailFieldController = TextEditingController();
  @override
  void dispose() {
    emailFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: emailFieldController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  hintText: "Enter your email",
                  labelText: "Email",
                  hintStyle: TextStyle(color: Colors.green, fontSize: 18),
                  labelStyle: TextStyle(color: Color(0xFF800f2f), fontSize: 18),
                  //floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    size: 30,
                    color: Color(0xFF800f2f),
                  )),
              validator: (value) {
                if (value!.isEmpty) {
                  return kEmailNullError;
                } else if (!emailValidatorRegExp.hasMatch(value)) {
                  return kInvalidEmailError;
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          SizedBox(height: 30),
          //SizedBox(height: 20),
          DefaultButton(
            text: "Send verification email",
            press: sendVerificationEmailButtonCallback,
          ),
          SizedBox(height: 20),
          NoAccountText(),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> sendVerificationEmailButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String emailInput = emailFieldController.text.trim();
      bool resultStatus;
      late String toast;
      try {
        final resultFuture =
            AuthentificationService().resetPasswordForEmail(emailInput);
        resultFuture.then((value) => resultStatus = value);
        resultStatus = await showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              resultFuture,
              message: Text("Sending verification email"),
            );
          },
        );
        if (resultStatus == true) {
          toast = "Password Reset Link sent to your email";
        } else {
          throw FirebaseCredentialActionAuthUnknownReasonFailureException(
              message:
                  "Sorry, could not process your request now, try again later");
        }
      } on MessagedFirebaseAuthException catch (e) {
        toast = e.message;
      } catch (e) {
        toast = e.toString();
      } finally {
        //Logger().i(snackbarMessage);
        Fluttertoast.showToast(
            msg: toast,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.white);
      }
    }
  }
}
