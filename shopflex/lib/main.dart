import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'notifiers/authNotifier.dart';
import 'screens/landingPage.dart';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() async {






  WidgetsFlutterBinding.ensureInitialized();




  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAXSR-AoNncN5aobl34sJmWM53Z4O9DDGk',
        appId: '1:892771060976:web:52c3cac1984850923b0635',
        messagingSenderId: '892771060976',
        projectId: 'shop-d9e74',
        storageBucket: 'shop-d9e74.appspot.com',

      ),
    );
  } else {

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }




  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthNotifier(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cassia',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: Color(0xffff4d6d),
        //Color(0xFF800f2f),
      ),
      home: Scaffold(
        body: LandingPage(),
        //body: NavigationBarPage(selectedIndex: 1),
      ),
    );
  }
}
