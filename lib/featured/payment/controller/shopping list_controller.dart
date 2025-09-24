import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/payment/data/favorite_products_repository.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/logging/logger.dart';

class ShoppingListController extends GetxController {
  static ShoppingListController get instance => Get.find();

  RxList<ProductModel> shoppedProducts = <ProductModel>[].obs;
  final _repository = FavoriteProductsRepository.instance;
  final _client = SupabaseService.client;
  var favoriteProductIds = <String>[];

  String? get userId => _client.auth.currentUser?.id;

  Future<void> saveProduct(ProductModel product) async {
    if (userId == null) return;

    try {
      await _repository.saveProduct(userId!, product.id);
      shoppedProducts.add(product);
      favoriteProductIds.add(product.id);
    } catch (e) {
      TLoggerHelper.error('Error saving product: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      fetchfavoriteProducts();
    }
  }

  Future<void> removeProduct(ProductModel product) async {
    if (userId == null) return;

    try {
      await _repository.removeProduct(userId!, product.id);
      shoppedProducts.remove(product);
      favoriteProductIds.remove(product.id);
    } catch (e) {
      TLoggerHelper.error('Error removing product: $e');
    }
  }

  Future<void> clearList() async {
    if (userId == null) return;

    try {
      await _repository.clearAllFavorites(userId!);
      shoppedProducts.clear();
      favoriteProductIds.clear();
    } catch (e) {
      TLoggerHelper.error('Error clearing favorite products: $e');
    }
  }

  bool isSaved(String productId) {
    return shoppedProducts.any((product) => product.id == productId);
  }

  var isLoad = false.obs;

  Future<List<ProductModel>> fetchfavoriteProducts() async {
    if (userId == null) return [];

    isLoad(true);
    try {
      final productIds = await _repository.getFavoriteProductIds(userId!);

      if (productIds.isEmpty) {
        TLoggerHelper.info("=======favorite product length = No favorite");
        shoppedProducts.clear();
        favoriteProductIds.clear();
        return [];
      }

      TLoggerHelper.info(
        "=======favorite product length = ${productIds.length}",
      );

      final products = await ProductRepository.instance.getProductsByIds(
        productIds,
      );
      shoppedProducts.value = products;
      favoriteProductIds = productIds;

      TLoggerHelper.info(
        "=======favorite product length = ${shoppedProducts.length}",
      );

      return shoppedProducts;
    } catch (e) {
      TLoggerHelper.error('Error fetching favorite products: $e');
      return [];
    } finally {
      isLoad(false);
    }
  }
}
