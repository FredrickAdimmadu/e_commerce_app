import 'package:flutter/material.dart';

import 'components/body.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final String searchIn;
  final List<String> searchResultProductsId;

  const SearchResultScreen({
    Key? key,
    required this.searchQuery,
    required this.searchResultProductsId,
    required this.searchIn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF800f2f),
        centerTitle: true,
        title: Text('Search result'),
      ),
      backgroundColor: Color(0xffffccd5),
      body: Body(
        searchQuery: searchQuery,
        searchResultProductsId: searchResultProductsId,
        searchIn: searchIn,
      ),
    );
  }
}
