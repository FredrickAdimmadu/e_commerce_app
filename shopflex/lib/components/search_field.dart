import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class SearchField extends StatelessWidget {
  final void Function(String)? onSubmit;

  const SearchField({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFe5989b).withOpacity(0.33),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: "Search Product",
          hintStyle: TextStyle(color: Color(0xFF800f2f), fontSize: 20),
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onSubmitted: onSubmit,
      ),
    );
  }
}
