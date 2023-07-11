import 'package:flutter/material.dart';

import '../constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    Key? key,
    this.title,
  }) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title!,
      ),
      leading: IconButton(
          icon: Icon(Icons.west_outlined),
          onPressed: () {
            Navigator.pop(context);
          }),
      centerTitle: true,

      elevation: 0,
      //backgroundColor: kPrimaryColor,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(50.0);
}
