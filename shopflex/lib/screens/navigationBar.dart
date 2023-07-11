import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shopflex/screens/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:shopflex/screens/home/home_screen.dart';

import 'home/components/home_screen_drawer.dart';

// ignore: must_be_immutable
class NavigationBarPage extends StatefulWidget {
  int selectedIndex;
  NavigationBarPage({required this.selectedIndex});
  @override
  _NavigationBarPageState createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  final List<Widget> _children = [
    //ProfilePage(),

    HomeScreen(),
    CartScreen(),
    HomeScreenDrawer(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _children[widget.selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Color(0xffdc2f02),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color(0xff6a4c93),
        height: 50,
        index: widget.selectedIndex,
        onTap: (index) {
          setState(() {
            widget.selectedIndex = index;
          });
        },
        items: <Widget>[
          Icon(
            Icons.home,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.add_shopping_cart,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.account_circle,
            size: 26,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
