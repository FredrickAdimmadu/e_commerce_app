import 'dart:io';

import 'package:flutter/cupertino.dart';

class ChosenImage extends ChangeNotifier {
  File? _chosenImage;

  File? get chosenImage => _chosenImage;
  set chosenImage(File? img) {
    _chosenImage = img;
    notifyListeners();
  }
}
