import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopflex/components/default_button.dart';
import 'package:shopflex/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:shopflex/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:shopflex/models/Product.dart';
import 'package:shopflex/screens/edit_product/provider_models/ProductDetails.dart';
import 'package:shopflex/services/database/product_database_helper.dart';
import 'package:shopflex/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:shopflex/services/local_files_access/local_files_access_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';


class EditProductForm extends StatefulWidget {
  final Product? product;


  EditProductForm({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}
class _EditProductFormState extends State<EditProductForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describeProductFormKey = GlobalKey<FormState>();
  final _tagStateKey = GlobalKey<TagsState>();


  final TextEditingController titleFieldController = TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController discountPriceFieldController =
  TextEditingController();
  final TextEditingController originalPriceFieldController =
  TextEditingController();
  final TextEditingController highlightsFieldController =
  TextEditingController();
  final TextEditingController desciptionFieldController =
  TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();

  bool newProduct = true;
  late Product product;

  @override
  void initState() {
    super.initState();
    if (widget.product == null) {
      product = Product('');
      newProduct = true;
    } else {
      product = widget.product!;
      newProduct = false;
      final productDetails =
      Provider.of<ProductDetails>(context, listen: false);
      productDetails.initialSelectedImages = widget.product!.images!
          .map((e) => CustomImage(imgType: ImageType.network, path: e))
          .toList();
      productDetails.initialProductType = product.productType!;
      productDetails.initSearchTags = product.searchTags ?? [];

    }
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: 10),
        buildDescribeProductTile(context),
        SizedBox(height: 10),
        buildUploadImagesTile(context),
        SizedBox(height: 20),
        buildProductTypeDropdown(),
        SizedBox(height: 20),
        buildProductSearchTagsTile(),
        SizedBox(height: 80),
        DefaultButton(
            text: "Save Product",
            press: () {
              saveProductButtonCallback(context);
            }),
        SizedBox(height: 10),
      ],
    );
    if (newProduct == false) {
      titleFieldController.text = product.title!;
      // variantFieldController.text = product.variant;
      discountPriceFieldController.text = product.discountPrice.toString();
      originalPriceFieldController.text = product.originalPrice.toString();
      highlightsFieldController.text = product.highlights!;
      desciptionFieldController.text = product.description!;
      sellerFieldController.text = product.seller!;
    }
    return column;
  }

  Widget buildProductSearchTags() {
    return ChangeNotifierProvider(
      create: (_) => ProductDetails(),
      child: Consumer<ProductDetails>(
        builder: (context, productDetails, child) {
          final searchTags = productDetails.searchTags ?? [];

          return Tags(
            key: _tagStateKey,
            horizontalScroll: true,
            heightHorizontalScroll: 80,
            textField: TagsTextField(
              lowerCase: true,
              width: 120,
              constraintSuggestion: true,
              hintText: "Add search tag",
              keyboardType: TextInputType.name,
              onSubmitted: (String str) {
                productDetails.addSearchTag(str.toLowerCase());
              },
            ),
            itemCount: searchTags.length,
            itemBuilder: (int index) {
              final item = searchTags[index];
              return Container(
                child: ItemTags(
                  index: index,
                  title: item,
                  active: true,
                  activeColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  alignment: MainAxisAlignment.spaceBetween,
                  removeButton: ItemTagsRemoveButton(
                    onRemoved: () {
                      productDetails.removeSearchTag(index: index);
                      return true;
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }




  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Basic Details",
          style: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
        ),
        leading: Icon(
          Icons.shop,
          color: Color(0xFF800f2f),
        ),
        childrenPadding: EdgeInsets.symmetric(vertical: 20),
        children: [
          buildTitleField(),
          SizedBox(height: 20),
          // buildVariantField(),
          // SizedBox(height: 20),
          buildOriginalPriceField(),
          SizedBox(height: 20),
          buildDiscountPriceField(),
          SizedBox(height: 20),
          buildSellerField(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  bool validateBasicDetailsForm() {
    if (_basicDetailsFormKey.currentState!.validate()) {
      _basicDetailsFormKey.currentState!.save();
      product.title = titleFieldController.text;
      // product.variant = variantFieldController.text;
      product.originalPrice = double.parse(originalPriceFieldController.text);
      product.discountPrice = double.parse(discountPriceFieldController.text);
      product.seller = sellerFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildDescribeProductTile(BuildContext context) {
    return Form(
      key: _describeProductFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Describe Product",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.description,
          color: Color(0xFF800f2f),
        ),
        childrenPadding: EdgeInsets.symmetric(vertical: 20),
        children: [
          buildHighlightsField(),
          SizedBox(height: 20),
          buildDescriptionField(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  bool validateDescribeProductForm() {
    if (_describeProductFormKey.currentState!.validate()) {
      _describeProductFormKey.currentState!.save();
      product.highlights = highlightsFieldController.text;
      product.description = desciptionFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildProductTypeDropdown() {

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF757575), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<ProductDetails>(
        builder: (context, productDetails, child) {
          return DropdownButton(
            //iconDisabledColor: Colors.red,
            value: productDetails.productType,
            items: ProductType.values
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  EnumToString.convertToString(e),
                ),
              ),
            )
                .toList(),
            hint: Container(
              alignment: Alignment.center,
              //height: 20,
              //width: 90,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: kPrimaryColor),
              ),
              child: Text(
                "Chose Product Type",
              ),
            ),
            //     Container(
            //   alignment: Alignment.center,
            //   height: 20,
            //   width: 90,
            //   decoration: BoxDecoration(
            //     color: kPrimaryColor.withOpacity(0.3),
            //     borderRadius: BorderRadius.circular(15),
            //     border: Border.all(color: kPrimaryColor),
            //   ),
            //   child: Text('Delivered', style: TextStyle(color: kPrimaryColor)),
            // ),
            // Spacer(),
            // Icon(
            //   Icons.replay,
            //   color: kPrimaryColor,
            // ),
            // Text(
            //   'Repeat Order',
            //   style: TextStyle(color: kPrimaryColor),
            // ),
            style: TextStyle(
              color: Color(0xFF757575),
              fontSize: 16,
            ),
            onChanged: (value) {
              productDetails.productType = value as ProductType;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildProductSearchTagsTile() {
    return ExpansionTile(
      title: Text(
        "Search Tags",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(
        Icons.check_circle_sharp,
        color: Color(0xFF800f2f),
      ),
      childrenPadding: EdgeInsets.symmetric(vertical: 20),
      children: [
        Text("Your product will be searched for this Tags"),
        SizedBox(height: 15),
        buildProductSearchTags(),
      ],
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Images",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(
        Icons.image,
        color: Color(0xFF800f2f),
      ),
      childrenPadding: EdgeInsets.symmetric(vertical: 20),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              icon: Icon(
                Icons.add_a_photo,
                color: Color(0xFF800f2f),
              ),
              color: Color(0xFF757575),
              onPressed: () {
                addImageButtonCallback();
              }),
        ),
        Consumer<ProductDetails>(
          builder: (context, productDetails, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  productDetails.selectedImages.length,
                      (index) => SizedBox(
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(index: index);
                        },
                        child: productDetails.selectedImages[index].imgType ==
                            ImageType.local
                            ? Image.memory(
                            File(productDetails.selectedImages[index].path)
                                .readAsBytesSync())
                            : Image.network(
                            productDetails.selectedImages[index].path),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: titleFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., Samsung Galaxy F41 Mobile",
        labelText: "Product Title",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (titleFieldController.text.isEmpty) {
          return Text("This field is required").toString();
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      controller: variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., Fusion Green",
        labelText: "Variant",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (variantFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildHighlightsField() {
    return TextFormField(
      controller: highlightsFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
        "e.g., RAM: 4GB | Front Camera: 30MP | Rear Camera: Quad Camera Setup",
        labelText: "Highlights",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (highlightsFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: desciptionFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
        "e.g., This a flagship phone under made in India, by Samsung. With this device, Samsung introduces its new F Series.",
        labelText: "Description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (desciptionFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildSellerField() {
    return TextFormField(
      controller: sellerFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., HighTech Traders",
        labelText: "Seller",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (sellerFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildOriginalPriceField() {
    return TextFormField(
      controller: originalPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g., 5999.0",
        labelText: "Original Price",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (originalPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDiscountPriceField() {
    return TextFormField(
      controller: discountPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g., 2499.0",
        labelText: "Discount Price",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (discountPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> saveProductButtonCallback(BuildContext context) async {
    if (validateBasicDetailsForm() == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erros in Basic Details Form"),
        ),
      );
      return;
    }
    if (validateDescribeProductForm() == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errors in Describe Product Form"),
        ),
      );
      return;
    }
    final productDetails = Provider.of<ProductDetails>(context, listen: false);
    if (productDetails.selectedImages.length < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload atleast One Image of Product"),
        ),
      );
      return;
    }
    if (productDetails.productType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select Product Type"),
        ),
      );
      return;
    }
    // if (productDetails.searchTags.length < 3) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Add atleast 3 search tags"),
    //     ),
    //   );
    //   return;
    // }
    late String productId;
    late String toast;
    try {
      product.productType = productDetails.productType;
      product.searchTags = productDetails.searchTags;
      final productUploadFuture = newProduct
          ? ProductDatabaseHelper().addUsersProduct(product)
          : ProductDatabaseHelper().updateUsersProduct(product);
      productUploadFuture.then((value) {
        productId = value;
      });
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            productUploadFuture,
            message:
            Text(newProduct ? "Uploading Product" : "Updating Product"),
          );
        },
      );
      if (productId != null) {
        toast = "Product Info updated successfully";
      } else {
        throw "Couldn't update product info due to some unknown issue";
      }
    } on FirebaseException catch (e) {
      //Logger().w("Firebase Exception: $e");
      toast = "Something went wrong";
    } catch (e) {
      //Logger().w("Unknown Exception: $e");
      toast = e.toString();
    } finally {
      //Logger().i(snackbarMessage);
      Fluttertoast.showToast(
          msg: toast,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }
    if (productId == null) return;
    bool allImagesUploaded = false;
    try {
      allImagesUploaded = await uploadProductImages(productId);
      if (allImagesUploaded == true) {
        toast = "All images uploaded successfully";
      } else {
        throw "Some images couldn't be uploaded, please try again";
      }
    } on FirebaseException catch (e) {
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
    late List<String>? downloadUrls = productDetails.selectedImages
        .map((e) => e.imgType == ImageType.network ? e.path : null)
        .cast<String>()
        .toList();
    bool productFinalizeUpdate = false;
    try {
      final updateProductFuture =
      ProductDatabaseHelper().updateProductsImages(productId, downloadUrls);
      productFinalizeUpdate = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updateProductFuture,
            message: Text("Saving Product"),
          );
        },
      );
      if (productFinalizeUpdate == true) {
        toast = "Product uploaded successfully";
      } else {
        throw "Couldn't upload product properly, please retry";
      }
    } on FirebaseException catch (e) {
      //Logger().w("Firebase Exception: $e");
      toast = "Something went wrong";
    } catch (e) {
      // Logger().w("Unknown Exception: $e");
      toast = e.toString();
    } finally {
      // Logger().i(toast);
      Fluttertoast.showToast(
          msg: toast,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }
    Navigator.pop(context);
  }

  Future<bool> uploadProductImages(String? productId) async {
    bool allImagesUpdated = true;
    final productDetails = Provider.of<ProductDetails>(context, listen: false);
    for (int i = 0; i < productDetails.selectedImages.length; i++) {
      if (productDetails.selectedImages[i].imgType == ImageType.local) {
        print("Image being uploaded: " + productDetails.selectedImages[i].path);
        late String downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
              File(productDetails.selectedImages[i].path),
              ProductDatabaseHelper().getPathForProductImage(productId!, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return FutureProgressDialog(
                imgUploadFuture,
                message: Text(
                    "Uploading Images ${i + 1}/${productDetails.selectedImages.length}"),
              );
            },
          );
        } on FirebaseException catch (e) {
          // Logger().w("Firebase Exception: $e");
        } catch (e) {
          //Logger().w("Firebase Exception: $e");
        } finally {
          if (downloadUrl == null) {
            productDetails.selectedImages[i] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text("Couldn't upload image ${i + 1} due to some issue"),
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  Future<void> addImageButtonCallback({int? index}) async {
    final productDetails = Provider.of<ProductDetails>(context, listen: false);
    if (index == null && productDetails.selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max 3 images can be uploaded")));
      return;
    }
    late String path;
    late String toast;
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      // Logger().i("LocalFileHandlingException: $e");
      toast = e.toString();
    } catch (e) {
      // Logger().i("LocalFileHandlingException: $e");
      toast = e.toString();
    }
    if (path == null) {
      return;
    }
    if (index == null) {
      productDetails.addNewSelectedImage(
          CustomImage(imgType: ImageType.local, path: path));
    } else {
      productDetails.setSelectedImageAtIndex(
          CustomImage(imgType: ImageType.local, path: path), index);
    }
  }
}