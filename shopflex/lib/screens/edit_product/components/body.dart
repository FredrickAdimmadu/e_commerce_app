import 'package:shopflex/constants.dart';
import 'package:shopflex/models/Product.dart';
import 'package:shopflex/size_config.dart';
import 'package:flutter/material.dart';

import 'edit_product_form.dart';

class Body extends StatelessWidget {
  final Product? productToEdit;

  const Body({Key? key, this.productToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Fill Product Details",
                  style: headingStyle,
                ),
                SizedBox(height: 30),
                EditProductForm(product: productToEdit),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// SafeArea(
//       child: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: SizedBox(
//             width: double.infinity,
//             child: Column(
//               children: [
//                 SizedBox(height: 10),
//                 Text(
//                   "Fill Product Details",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     )