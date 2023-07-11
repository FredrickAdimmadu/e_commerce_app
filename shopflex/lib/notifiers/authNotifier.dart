import 'package:shopflex/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends ChangeNotifier {
  User? _user; // Use nullable type

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Test
  Users? _userDetails; // Use nullable type

  Users? get userDetails => _userDetails;

  setUserDetails(Users? user) {
    _userDetails = user;
    notifyListeners();
  }
}

