import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopflex/components/product_short_detail_card.dart';
import 'package:shopflex/constants.dart';
import 'package:shopflex/models/CartItem.dart';
import 'package:shopflex/models/OrderedProduct.dart';
import 'package:shopflex/models/Product.dart';
import 'package:shopflex/screens/product_details/product_details_screen.dart';
import 'package:shopflex/services/data_streams/cart_items_stream.dart';
import 'package:shopflex/services/database/product_database_helper.dart';
import 'package:shopflex/services/database/user_database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../utils.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final CartItemsStream cartItemsStream = CartItemsStream();
  late PersistentBottomSheetController bottomSheetHandler;
  @override
  void initState() {
    super.initState();
    cartItemsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    cartItemsStream.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Your Cart",
                    style: headingStyle,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 555,
                    child: Center(
                      child: buildCartItemsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    cartItemsStream.reload();
    return Future<void>.value();
  }

  Widget buildCartItemsList() {
    return Container();
    //   return StreamBuilder<List<String>>(
    //     stream: cartItemsStream.stream,
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         List<String> cartItemsId = snapshot.data!;
    //         if (cartItemsId.length == 0) {
    //           return Center(
    //             child: NothingToShowContainer(
    //               iconPath: "assets/icons/empty_cart.svg",
    //               secondaryMessage: "Your cart is empty",
    //             ),
    //           );
    //         }

    //         return Column(
    //           children: [
    //             DefaultButton(
    //               text: "Proceed to Payment",
    //               press: () {
    //                 bottomSheetHandler = Scaffold.of(context).showBottomSheet(
    //                   (context) {
    //                     return CheckoutCard(
    //                       onCheckoutPressed: checkoutButtonCallback,
    //                     );
    //                   },
    //                 );
    //               },
    //             ),
    //             SizedBox(height: 20),
    //             Expanded(
    //               child: ListView.builder(
    //                 padding: EdgeInsets.symmetric(vertical: 16),
    //                 physics: BouncingScrollPhysics(),
    //                 itemCount: cartItemsId.length,
    //                 itemBuilder: (context, index) {
    //                   if (index >= cartItemsId.length) {
    //                     return SizedBox(height: 80);
    //                   }
    //                   return buildCartItemDismissible(
    //                       context, cartItemsId[index], index);
    //                 },
    //               ),
    //             ),
    //           ],
    //         );
    //       } else if (snapshot.connectionState == ConnectionState.waiting) {
    //         return Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       } else if (snapshot.hasError) {
    //         final error = snapshot.error;
    //         //Logger().w(error.toString());
    //       }
    //       return Center(
    //         child: NothingToShowContainer(
    //           iconPath: "assets/icons/network_error.svg",
    //           primaryMessage: "Something went wrong",
    //           secondaryMessage: "Unable to connect to Database",
    //         ),
    //       );
    //     },
    //   );
  }

  Widget buildCartItemDismissible(
      BuildContext context, String cartItemId, int index) {
    return Dismissible(
      key: Key(cartItemId),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.65,
      },
      background: buildDismissibleBackground(),
      child: buildCartItem(cartItemId, index),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
            context,
            "Remove Product from Cart?",
          );
          if (confirmation) {
            if (direction == DismissDirection.startToEnd) {
              bool result = false;
              late String toast;
              try {
                result = await UserDatabaseHelper()
                    .removeProductFromCart(cartItemId);
                if (result == true) {
                  toast = "Product removed from cart successfully";
                  await refreshPage();
                } else {
                  throw "Coulnd't remove product from cart due to unknown reason";
                }
              } on FirebaseException {
                //Logger().w("Firebase Exception: $e");
                toast = "Something went wrong";
              } catch (e) {
                //Logger().w("Unknown Exception: $e");
                toast = "Something went wrong";
              } finally {
                //Logger().i(snackbarMessage);
                Fluttertoast.showToast(
                    msg: toast,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white);
              }

              return result;
            }
          }
        }
        return false;
      },
      onDismissed: (direction) {},
    );
  }

  Widget buildCartItem(String cartItemId, int index) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 4,
        top: 4,
        right: 4,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<Product?>(
        future: ProductDatabaseHelper().getProductWithID(cartItemId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Product product = snapshot.data!;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
                  child: ProductShortDetailCard(
                    productId: product.id,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kTextColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: const Icon(
                            Icons.arrow_drop_up,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowUpCallback(cartItemId);
                          },
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<CartItem>(
                          future: UserDatabaseHelper()
                              .getCartItemFromId(cartItemId),
                          builder: (context, snapshot) {
                            int itemCount = 0;
                            if (snapshot.hasData) {
                              final cartItem = snapshot.data;
                              itemCount = cartItem!.itemCount;
                            } else if (snapshot.hasError) {
                              final error = snapshot.error.toString();
                              //Logger().e(error);
                            }
                            return Text(
                              "$itemCount",
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowDownCallback(cartItemId);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            //Logger().w(error.toString());
            return Center(
              child: Text(
                error.toString(),
              ),
            );
          } else {
            return const Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildDismissibleBackground() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkoutButtonCallback() async {
    shutBottomSheet();
    final confirmation = await showConfirmationDialog(
      context,
      "This is just a Project Testing App so, no actual Payment Interface is available.\nDo you want to proceed for Mock Ordering of Products?",
    );
    if (confirmation == false) {
      return;
    }
    final orderFuture = UserDatabaseHelper().emptyCart();
    orderFuture.then((orderedProductsUid) async {
      if (orderedProductsUid != null) {
        print(orderedProductsUid);
        final dateTime = DateTime.now();
        final formatedDateTime =
            "${dateTime.day}-${dateTime.month}-${dateTime.year}";
        List<OrderedProduct> orderedProducts = orderedProductsUid
            .map((e) =>
                OrderedProduct('', productUid: e, orderDate: formatedDateTime))
            .toList();
        bool addedProductsToMyProducts = false;
        late String toast;
        try {
          addedProductsToMyProducts =
              await UserDatabaseHelper().addToMyOrders(orderedProducts);
          if (addedProductsToMyProducts) {
            toast = "Products ordered Successfully";
          } else {
            throw "Could not order products due to unknown issue";
          }
        } on FirebaseException catch (e) {
          //Logger().e(e.toString());
          toast = e.toString();
        } catch (e) {
          // Logger().e(e.toString());
          toast = e.toString();
        } finally {
          Fluttertoast.showToast(
              msg: toast,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey,
              textColor: Colors.white);
        }
      } else {
        throw "Something went wrong while clearing cart";
      }
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            orderFuture,
            message: const Text("Placing the Order"),
          );
        },
      );
    }).catchError((e) {
      //Logger().e(e.toString());
      Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    });
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          orderFuture,
          message: Text("Placing the Order"),
        );
      },
    );
    await refreshPage();
  }

  void shutBottomSheet() {
    bottomSheetHandler.close();
  }

  Future<void> arrowUpCallback(String cartItemId) async {
    shutBottomSheet();
    final future = UserDatabaseHelper().increaseCartItemCount(cartItemId);
    future.then((status) async {
      if (status) {
        await refreshPage();
      } else {
        throw "Couldn't perform the operation due to some unknown issue";
      }
    }).catchError((e) {
      //Logger().e(e.toString());
      Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    });
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          future,
          message: Text("Please wait"),
        );
      },
    );
  }

  Future<void> arrowDownCallback(String cartItemId) async {
    shutBottomSheet();
    final future = UserDatabaseHelper().decreaseCartItemCount(cartItemId);
    future.then((status) async {
      if (status) {
        await refreshPage();
      } else {
        throw "Couldn't perform the operation due to some unknown issue";
      }
    }).catchError((e) {
      // Logger().e(e.toString());
      Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    });
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          future,
          message: Text("Please wait"),
        );
      },
    );
  }
}
