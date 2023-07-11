import 'package:shopflex/components/nothingtoshow_container.dart';
import 'package:shopflex/components/product_card.dart';
import 'package:shopflex/constants.dart';
import 'package:shopflex/screens/product_details/product_details_screen.dart';
import 'package:shopflex/size_config.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  final String searchQuery;
  final List<String> searchResultProductsId;
  final String searchIn;

  const Body({
    Key? key,
    required this.searchQuery,
    required this.searchResultProductsId,
    required this.searchIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Search Result",
                  style: headingStyle,
                ),
                Text.rich(
                  TextSpan(
                    text: "$searchQuery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    children: [
                      TextSpan(
                        text: " in ",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      TextSpan(
                        text: "$searchIn",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  height: 300,
                  child: buildProductsGrid(),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProductsGrid() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Builder(
        builder: (context) {
          if (searchResultProductsId.length > 0) {
            return GridView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: searchResultProductsId.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  productId: searchResultProductsId[index],
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          productId: searchResultProductsId[index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(
              child: SizedBox(
            width: double.infinity,
            height: 410,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/not found.png',
                  //color: kTextColor,
                  //width: 75,
                ),
                SizedBox(height: 16),
                Text(
                  "Try another search keyword",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Found 0 Products",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
              // NothingToShowContainer(
              //   iconPath: "assets/icons/search_no_found.svg",
              //   secondaryMessage: "Found 0 Products",
              //   primaryMessage: "Try another search keyword",
              // ),
              );
        },
      ),
    );
  }
}
