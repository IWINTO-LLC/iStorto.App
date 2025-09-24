import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';

class AllProductController extends GetxController {
  static AllProductController get instance => Get.find();

  //Variables

  final repository = ProductRepository.instance;
  final RxString selectedSortOption = 'Name'.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // Future<List<ProductModel>> fetchProductsByQuery(Query? query) async {
  //   try {
  //     if (query == null) return [];
  //     final products = await repository.fetchProductsByQuery(query);
  //     if (kDebugMode) {
  //       print('============ product filter length==========');
  //       print(products.length);
  //     }

  //     return products;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e.toString());
  //     }
  //     return [];
  //   }
  // }

  void sortProducts(String sortOption) {
    selectedSortOption.value = sortOption;
    switch (sortOption) {
      case 'Name':
        products.sort((a, b) {
          final aTitle = a.title;
          final bTitle = b.title;
          return aTitle.compareTo(bTitle);
        });
        break;
      case 'Higher price':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Lower price':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      // case 'Newest':
      // products.sort((a, b) => a.price.compareTo(b.price));
      // break;
      case 'Sale':
        products.sort((a, b) {
          if (b.price > 0) {
            return b.price.compareTo(a.price);
          } else if (a.price > 0) {
            return -1;
          } else {
            return 1;
          }
        });
        break;
      default:
        products.sort((a, b) {
          final aTitle = a.title;
          final bTitle = b.title;
          return aTitle.compareTo(bTitle);
        });
    }
  }

  void assignProducts(List<ProductModel> p) {
    products.assignAll(p);
    sortProducts('Name');
  }
}
