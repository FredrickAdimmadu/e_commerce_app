import 'package:shopflex/components/rounded_icon_button.dart';
import 'package:shopflex/components/search_field.dart';
import 'package:flutter/material.dart';

import '../../../components/icon_button_with_counter.dart';

class HomeHeader extends StatelessWidget {
  final void Function(String)? onSearchSubmitted;
  final Function onCartButtonPressed;

  const HomeHeader({
    Key? key,
    required this.onSearchSubmitted,
    required this.onCartButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // RoundedIconButton(
        //     iconData: Icons.menu,
        //     press: () {
        //       Scaffold.of(context).openDrawer();
        //     }),
        Expanded(
          child: SearchField(
            onSubmit: onSearchSubmitted,
          ),
        ),
        SizedBox(width: 5),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Color(0xFF800f2f), width: 3),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              size: 33,
              color: Color(0xFF800f2f),
            ),
            onPressed: () {},
          ),
        )
        // IconButtonWithCounter(
        //   svgSrc: "assets/icons/Cart Icon.svg",
        //   numOfItems: 0,
        //   press: onCartButtonPressed,
        // ),
      ],
    );
  }
}
