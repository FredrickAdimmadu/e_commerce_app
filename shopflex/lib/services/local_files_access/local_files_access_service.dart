import 'dart:io';

import 'package:shopflex/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:shopflex/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


Future<String> choseImageFromLocalFiles(
  BuildContext context, {
  int maxSizeInKB = 1024,
  int minSizeInKB = 5,
}) async {


  final imgPicker = ImagePicker();
  final imgSource = await showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text("Chose image source"),
        actions: [
          ElevatedButton(
            child: Text("Camera"),
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          ElevatedButton(
            child: Text("Gallery"),
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      );
    },
    context: context,
  );
  if (imgSource == null)
    throw LocalImagePickingInvalidImageException(
        message: "No image source selected");
  final XFile? imagePicked = await imgPicker.pickImage(source: imgSource);
  if (imagePicked == null) {
    throw LocalImagePickingInvalidImageException();
  } else {
    final fileLength = await File(imagePicked.path).length();
    if (fileLength > (maxSizeInKB * 1024) ||
        fileLength < (minSizeInKB * 1024)) {
      throw LocalImagePickingFileSizeOutOfBoundsException(
          message: "Image size should not exceed 1MB");
    } else {
      return imagePicked.path;
    }
  }
}
