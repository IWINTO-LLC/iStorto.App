import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/data/save_for_later_repository.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class SavedController extends GetxController {
  static SavedController get instance => Get.find();

  final _repository = SaveForLaterRepository.instance;

  // Observable lists
  final RxList<CartItem> savedItems = <CartItem>[].obs;
  final RxList<ProductModel> savedProducts = <ProductModel>[].obs;
  final RxSet<String> savedProductIds = <String>{}.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isInitializing = true.obs;
  final RxBool isUserAuthenticated = false.obs;

  // Deleting states
  final RxSet<String> deletingProductIds = <String>{}.obs;
  final RxSet<String> deletedProductIds = <String>{}.obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'date'.obs;

  String? get userId => SupabaseService.client.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    _checkAuthenticationStatus();
  }

  /// Check if user is authenticated
  void _checkAuthenticationStatus() {
    final user = SupabaseService.client.auth.currentUser;
    isUserAuthenticated.value = user != null;

    if (isUserAuthenticated.value) {
      _initializeAsync();
    } else {
      isInitializing.value = false;
    }
  }

  /// Initialize saved items
  Future<void> _initializeAsync() async {
    try {
      isInitializing.value = true;
      await _loadSavedItems();
      await _loadSavedProductIds();
    } catch (e) {
      debugPrint('Error initializing saved items: $e');
    } finally {
      isInitializing.value = false;
    }
  }

  /// Load saved items from Supabase
  Future<void> _loadSavedItems() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      final items = await _repository.getSavedItems();
      savedItems.assignAll(items);

      // Extract products from items
      final products = items.map((item) => item.product).toList();
      savedProducts.assignAll(products);
    } catch (e) {
      debugPrint('Error loading saved items: $e');
      TLoader.erroreSnackBar(
        message: 'Failed to load saved items: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load saved product IDs
  Future<void> _loadSavedProductIds() async {
    if (userId == null) return;

    try {
      final items = await _repository.getSavedItems();
      final ids = items.map((item) => item.product.id).toSet();
      savedProductIds.assignAll(ids);
    } catch (e) {
      debugPrint('Error loading saved product IDs: $e');
    }
  }

  /// Save product for later
  Future<void> saveProduct(ProductModel product) async {
    if (userId == null) {
      TLoader.warningSnackBar(
        title: 'Authentication Required',
        message: 'Please login to save products',
      );
      return;
    }

    if (isSaved(product.id)) {
      TLoader.warningSnackBar(
        title: 'Already Saved',
        message: 'This product is already saved for later',
      );
      return;
    }

    try {
      final cartItem = CartItem(product: product, quantity: 1);
      await _repository.saveItem(cartItem);

      // Update local state
      savedItems.add(cartItem);
      savedProducts.add(product);
      savedProductIds.add(product.id);

      TLoader.successSnackBar(
        title: 'Success',
        message: 'Product saved for later',
      );
    } catch (e) {
      debugPrint('Error saving product: $e');
      TLoader.erroreSnackBar(
        message: 'Failed to save product: ${e.toString()}',
      );
    }
  }

  /// Remove product from saved items
  Future<void> removeProduct(ProductModel product) async {
    if (userId == null) return;

    try {
      deletingProductIds.add(product.id);

      await _repository.removeItem(product.id);

      // Update local state
      savedItems.removeWhere((item) => item.product.id == product.id);
      savedProducts.removeWhere((p) => p.id == product.id);
      savedProductIds.remove(product.id);
      deletedProductIds.add(product.id);

      TLoader.successSnackBar(
        title: 'Success',
        message: 'Product removed from saved items',
      );
    } catch (e) {
      debugPrint('Error removing product: $e');
      TLoader.erroreSnackBar(
        message: 'Failed to remove product: ${e.toString()}',
      );
    } finally {
      deletingProductIds.remove(product.id);
    }
  }

  /// Clear all saved items
  Future<void> clearAllSavedItems() async {
    if (userId == null) return;

    try {
      isLoading.value = true;

      await _repository.clearAllSavedItems();

      // Clear local state
      savedItems.clear();
      savedProducts.clear();
      savedProductIds.clear();
      deletedProductIds.clear();

      TLoader.successSnackBar(
        title: 'Success',
        message: 'All saved items cleared',
      );
    } catch (e) {
      debugPrint('Error clearing saved items: $e');
      TLoader.erroreSnackBar(
        message: 'Failed to clear saved items: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Move item to cart
  Future<void> moveToCart(CartItem item) async {
    if (userId == null) return;

    try {
      await _repository.moveToCart(item);

      // Remove from saved items
      savedItems.removeWhere(
        (savedItem) => savedItem.product.id == item.product.id,
      );
      savedProducts.removeWhere((product) => product.id == item.product.id);
      savedProductIds.remove(item.product.id);

      TLoader.successSnackBar(
        title: 'Success',
        message: 'Product moved to cart',
      );
    } catch (e) {
      debugPrint('Error moving to cart: $e');
      TLoader.erroreSnackBar(
        message: 'Failed to move to cart: ${e.toString()}',
      );
    }
  }

  /// Move all items to cart
  Future<void> moveAllToCart() async {
    if (userId == null) return;

    try {
      isLoading.value = true;

      await _repository.moveAllToCart();

      // Clear saved items
      savedItems.clear();
      savedProducts.clear();
      savedProductIds.clear();

      TLoader.successSnackBar(
        title: 'Success',
        message: 'All items moved to cart',
      );
    } catch (e) {
      debugPrint('Error moving all to cart: $e');
      TLoader.erroreSnackBar(
        message: 'Failed to move items to cart: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if product is saved
  bool isSaved(String productId) {
    return savedProductIds.contains(productId);
  }

  /// Check if product is being deleted
  bool isDeleting(String productId) {
    return deletingProductIds.contains(productId);
  }

  /// Check if product is deleted
  bool isDeleted(String productId) {
    return deletedProductIds.contains(productId);
  }

  /// Get saved items count
  int get savedItemsCount => savedItems.length;

  /// Get filtered products based on search and sort
  List<ProductModel> get filteredProducts {
    var products = savedProducts.toList();  

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      products =
          products.where((product) {
            return product.title.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (product.description?.toLowerCase() ?? '').contains(
                  searchQuery.value.toLowerCase(),
                );
          }).toList();
    }

    // Apply sort
    switch (sortBy.value) {
      case 'name':
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'price':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'date':
      default:
        products.sort(
          (a, b) =>
              b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0,
        );
        break;
    }

    return products;
  }

  /// Refresh saved items
  @override
  Future<void> refresh() async {
    await _loadSavedItems();
    await _loadSavedProductIds();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update sort option
  void updateSortBy(String sort) {
    sortBy.value = sort;
  }

  /// Reset filters
  void resetFilters() {
    searchQuery.value = '';
    sortBy.value = 'date';
  }
}
