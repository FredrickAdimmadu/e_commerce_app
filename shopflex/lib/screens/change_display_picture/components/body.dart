import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shopflex/components/default_button.dart';
import 'package:shopflex/constants.dart';
import 'package:shopflex/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:shopflex/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:shopflex/services/database/user_database_helper.dart';
import 'package:shopflex/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:shopflex/services/local_files_access/local_files_access_service.dart';
import 'package:shopflex/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../provider_models/body_model.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';



class Body extends StatelessWidget {

  late Image imageFromUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChosenImage(),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<ChosenImage>(
                builder: (context, bodyState, child) {
                  return Column(
                    children: [
                      Text(
                        "Change Avatar",
                        style: headingStyle,
                      ),
                      SizedBox(height: 40),
                      GestureDetector(
                        child: buildDisplayPictureAvatar(context, bodyState),
                        onTap: () {
                          getImageFromUser(context, bodyState);
                        },
                      ),
                      SizedBox(height: 80),
                      buildChosePictureButton(context, bodyState),
                      SizedBox(height: 20),
                      buildUploadPictureButton(context, bodyState),
                      SizedBox(height: 20),
                      buildRemovePictureButton(context, bodyState),
                      SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDisplayPictureAvatar(BuildContext context, ChosenImage bodyState) {
    return StreamBuilder<DocumentSnapshot>(
      stream: UserDatabaseHelper().currentUserDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          // Handle the error appropriately
          return Text('Error: $error');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Handle the case when the snapshot has no data
          return CircleAvatar(
            maxRadius: 50,
            backgroundColor: Color(0xff00afb9),
          );
        }

        final documentSnapshot = snapshot.data as DocumentSnapshot;
        final data = documentSnapshot.data() as Map<String, dynamic>?;

        String? imageUrl;
        if (data != null) {
          imageUrl = data[UserDatabaseHelper.DP_KEY];
        }

        return CircleAvatar(
          maxRadius: 50,
          backgroundColor: Color(0xff00afb9),
         // backgroundImage: NetworkImage(imageUrl),
        );
      },
    );
  }






  void getImageFromUser(BuildContext context, ChosenImage bodyState) async {
    late String path;
    late String toast;
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      // Logger().i("LocalFileHandlingException: $e");
      toast = e.toString();
    } catch (e) {
      // Logger().i("LocalFileHandlingException: $e");
      toast = e.toString();
    }
    if (path == null) {
      return;
    }
    bodyState.chosenImage = File(path);
  }










  Widget buildChosePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Choose Picture",
      press: () {
        getImageFromUser(context, bodyState);
      },
    );
  }

  Widget buildUploadPictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Upload Picture",
      press: () {
        final Future uploadFuture =
        uploadImageToFirestorage(context, bodyState);
        showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              uploadFuture,
              message: Text("Updating Display Picture"),
            );
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Display Picture updated")),
        );
      },
    );
  }

  Future<void> uploadImageToFirestorage(
      BuildContext context, ChosenImage bodyState) async {
    bool uploadDisplayPictureStatus = false;
    late String toast;
    try {
      final downloadUrl = await FirestoreFilesAccess().uploadFileToPath(
        bodyState.chosenImage!,
        UserDatabaseHelper().getPathForCurrentUserDisplayPicture(),
      );

      uploadDisplayPictureStatus = await UserDatabaseHelper()
          .uploadDisplayPictureForCurrentUser(downloadUrl);
      if (uploadDisplayPictureStatus == true) {
        toast = "Display Picture updated successfully";
      } else {
        throw "Couldn't update display picture due to unknown reason";
      }
    } on FirebaseException catch (e) {
      //Logger().w("Firebase Exception: $e");
      toast = "Something went wrong";
    } catch (e) {
      // Logger().w("Unknown Exception: $e");
      toast = "Something went wrong";
    } finally {
      //Logger().i(toast);
      Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    }
  }

  Widget buildRemovePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Remove Picture",
      press: () async {
        final Future uploadFuture =
        removeImageFromFirestore(context, bodyState);
        await showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              uploadFuture,
              message: Text("Deleting Display Picture"),
            );
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Display Picture removed")),
        );
        Navigator.pop(context);
      },
    );
  }
  Future<void> removeImageFromFirestore(
      BuildContext context, ChosenImage bodyState) async {
    bool status = false;
    late String toast;
    try {
      bool fileDeletedFromFirestore = false;
      fileDeletedFromFirestore = await FirestoreFilesAccess()
          .deleteFileFromPath(
              UserDatabaseHelper().getPathForCurrentUserDisplayPicture());
      if (fileDeletedFromFirestore == false) {
        throw "Couldn't delete file from Storage, please retry";
      }
      status = await UserDatabaseHelper().removeDisplayPictureForCurrentUser();
      if (status == true) {
        toast = "Picture removed successfully";
      } else {
        throw "Coulnd't removed due to unknown reason";
      }
    } on FirebaseException catch (e) {
      // Logger().w("Firebase Exception: $e");
      toast = "Something went wrong";
    } catch (e) {
      // Logger().w("Unknown Exception: $e");
      toast = "Something went wrong";
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
