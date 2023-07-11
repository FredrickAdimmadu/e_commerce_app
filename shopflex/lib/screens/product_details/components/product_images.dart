import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:swipedetector_nullsafety/swipedetector_nullsafety.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import 'package:shopflex/models/Product.dart';
import 'package:shopflex/screens/product_details/provider_models/ProductImageSwiper.dart';

class ProductImages extends StatelessWidget {
  const ProductImages({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductImageSwiper(),
      child: Consumer<ProductImageSwiper>(
        builder: (context, productImagesSwiper, child) {
          return Column(
            children: [
              SwipeDetector(
                onSwipeLeft: () {
                  productImagesSwiper.currentImageIndex =
                      (productImagesSwiper.currentImageIndex + 1) %
                          product.images!.length;
                },
                onSwipeRight: () {
                  productImagesSwiper.currentImageIndex =
                      (productImagesSwiper.currentImageIndex - 1 +
                          product.images!.length) %
                          product.images!.length;
                },
                child: GestureDetector(
                  onDoubleTap: () {
                    productImagesSwiper.currentImageIndex =
                        (productImagesSwiper.currentImageIndex + 1) %
                            product.images!.length;
                  },
                  child: PhotoView(
                    imageProvider: NetworkImage(product
                        .images![productImagesSwiper.currentImageIndex]),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    product.images!.length,
                        (index) =>
                        buildSmallPreview(productImagesSwiper, index: index),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSmallPreview(ProductImageSwiper productImagesSwiper,
      {required int index}) {
    return GestureDetector(
      onTap: () {
        productImagesSwiper.currentImageIndex = index;
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(8),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: productImagesSwiper.currentImageIndex == index
                ? kPrimaryColor
                : Colors.transparent,
          ),
        ),
        child: Image.network(product.images![index]),
      ),
    );
  }
}
