import 'package:shopflex/models/Product.dart';
import 'package:shopflex/services/data_streams/data_stream.dart';
import 'package:shopflex/services/database/product_database_helper.dart';

class CategoryProductsStream extends DataStream<List<String>> {
  final ProductType category;

  CategoryProductsStream(this.category);
  @override
  void reload() {
    final allProductsFuture =
        ProductDatabaseHelper().getCategoryProductsList(category);
    allProductsFuture.then((favProducts) {
      addData(['favProducts']);
    }).catchError((e) {
      addError(e);
    });
  }
}
