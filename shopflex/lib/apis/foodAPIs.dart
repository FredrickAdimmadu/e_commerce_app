import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopflex/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopflex/notifiers/authNotifier.dart';
import 'package:shopflex/screens/adminHome.dart';
import 'package:shopflex/screens/navigationBar.dart';
import 'package:shopflex/screens/login.dart';

void toast(String data) {
  Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white);
}

login(Users user, AuthNotifier authNotifier, BuildContext context) async {
  UserCredential authResult;
  try {
    authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user.email, password: user.password);
  } catch (error) {
    toast(error.toString());
    print(error);
    return;
  }

  try {
    if (authResult != null) {
      User user = FirebaseAuth.instance.currentUser!;
      //User firebaseUser = authResult.user;
      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        toast("Email ID not verified");
        return;
      }

//       if (!user.emailVerified) {
//   await user.sendEmailVerification();
// }
      else if (user != null) {
        print("Log In: $user");
        authNotifier.setUser(user);
        await getUserDetails(authNotifier);
        print("done");
        if (authNotifier.userDetails?.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return AdminHomePage();
            }),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return NavigationBarPage(selectedIndex: 0);
            }),
          );
        }
      }
    }
  } catch (error) {
    toast(error.toString());
    print(error);
    return;
  }
}

signUp(Users user, AuthNotifier authNotifier, BuildContext context) async {
  bool userDataUploaded = false;
  UserCredential authResult;
  try {
    authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email.trim(), password: user.password);
  } catch (error) {
    toast(error.toString());
    print(error);
    return;
  }

  try {
    if (authResult != null) {
      await FirebaseAuth.instance.currentUser!
          .updateDisplayName(user.displayName);
      //UserUpdateInfo updateInfo = UserUpdateInfo();
      //updateInfo.displayName = user.displayName;

      User firebaseUser = authResult.user!;
      await firebaseUser.sendEmailVerification();

      if (firebaseUser != null) {
        //await firebaseUser.updateProfile(updateInfo);
        await firebaseUser.reload();
        print("Sign Up: $firebaseUser");
        uploadUserData(user, userDataUploaded);
        await FirebaseAuth.instance.signOut();
        authNotifier.setUser;

        toast("Verification link is sent to ${user.email}");
        Navigator.pop(context);
      }
    }
  } catch (error) {
    toast(error.toString());
    print(error);
    return;
  }
}

getUserDetails(AuthNotifier authNotifier) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(authNotifier.user?.uid)
      .get()
      .catchError((e) => print(e))
      .then((value) => {
            (value != null)
                ? authNotifier.setUserDetails(Users.fromMap(value.data()!))
                : print(value)
          });
}

uploadUserData(Users user, bool userdataUpload) async {
  bool userDataUploadVar = userdataUpload;
  User currentUser = await FirebaseAuth.instance.currentUser!;

  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  //CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');

  user.uuid = currentUser.uid;
  if (userDataUploadVar != true) {
    await userRef
        .doc(currentUser.uid)
        .set(user.toMap())
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
  } else {
    print('already uploaded user data');
  }
  print('user data uploaded successfully');
}

initializeCurrentUser(AuthNotifier authNotifier, BuildContext context) async {
  User firebaseUser = await FirebaseAuth.instance.currentUser!;
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
    await getUserDetails(authNotifier);
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  authNotifier.setUser;
  print('log out');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return LoginPage();
    }),
  );
}

addMoney(int amount, BuildContext context, String id) async {
  try {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    await userRef
        .doc(id)
        .update({'balance': FieldValue.increment(amount)})
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    toast("Failed to add money!");
    print(error);
    return;
  }

  Navigator.pop(context);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return NavigationBarPage(selectedIndex: 1);
    }),
  );
  toast("Money added successfully!");
}

placeOrder(BuildContext context, double total) async {
  try {
    // Initiaization
    User currentUser = await FirebaseAuth.instance.currentUser!;
    CollectionReference cartRef =
        FirebaseFirestore.instance.collection('carts');
    CollectionReference orderRef =
        FirebaseFirestore.instance.collection('orders');
    CollectionReference itemRef =
        FirebaseFirestore.instance.collection('items');
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    List<String> foodIds = [];
    Map<String, int> count = {};
    List<dynamic> _cartItems = [];

    // Checking user balance
    // DocumentSnapshot userData = await userRef.doc(currentUser.uid).get();
    // if (userData.data()!['balance'] < total) {
    //   toast("You dont have succifient balance to place this order!");
    //   return;
    // }

    // Getting all cart items of the user
    QuerySnapshot data =
        await cartRef.doc(currentUser.uid).collection('items').get();
    data.docs.forEach((item) {
      foodIds.add(item.id);
      count[item.id] = item.get('count');
    });

    // Checking for item availability
    QuerySnapshot snap =
        await itemRef.where(FieldPath.documentId, whereIn: foodIds).get();
    for (var i = 0; i < snap.docs.length; i++) {
      if (snap.docs[i].get('total_qty') < count[snap.docs[i].id]) {
        print("not");
        toast(
            "Item: ${snap.docs[i].get('item_name')} has QTY: ${snap.docs[i].get('total_qty')} only. Reduce/Remove the item.");
        return;
      }
    }

    // Creating cart items array
    snap.docs.forEach((item) {
      _cartItems.add({
        "item_id": item.id,
        "count": count[item.id],
        "item_name": item.get('item_name'),
        "price": item.get('price')
      });
    });

    // Creating a transaction
    await FirebaseFirestore.instance
        .runTransaction((Transaction transaction) async {
      // Update the item count in items table
      for (var i = 0; i < snap.docs.length; i++) {
        await transaction.update(snap.docs[i].reference, {
          "total_qty": snap.docs[i].get("total_qty") - count[snap.docs[i].id]
        });
      }

      // Deduct amount from user
      await userRef
          .doc(currentUser.uid)
          .update({'balance': FieldValue.increment(-1 * total)});

      // Place a new order
      await orderRef.doc().set({
        "items": _cartItems,
        "is_delivered": false,
        "total": total,
        "placed_at": DateTime.now(),
        "placed_by": currentUser.uid
      });

      // Empty cart
      for (var i = 0; i < data.docs.length; i++) {
        await transaction.delete(data.docs[i].reference);
      }
      print("in in");
      // return;
    });

    // Successfull transaction

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return NavigationBarPage(selectedIndex: 1);
      }),
    );
    toast("Order Placed Successfully!");
  } catch (error) {
    Navigator.pop(context);
    toast("Failed to place order!");
    print(error);
    return;
  }
}

orderReceived(String id, BuildContext context) async {
  try {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection('orders');
    await ordersRef
        .doc(id)
        .update({'is_delivered': true})
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    toast("Failed to mark as received!");
    print(error);
    return;
  }

  Navigator.pop(context);
  toast("Order received successfully!");
}
