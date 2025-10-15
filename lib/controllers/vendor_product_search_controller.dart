import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/data/models/vendor_category_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/data/repositories/vendor_category_repository.dart';

/// Controller for Vendor Product Search
///
/// Features:
/// - Search products by name/description
/// - Filter by vendor categories
/// - Sort by date (newest/oldest) and price (high/low)
class VendorProductSearchController extends GetxController {
  final String vendorId;

  VendorProductSearchController({required this.vendorId});

  // Repositories
  final _productRepository = ProductRepository.instance;
  final _categoryRepository = VendorCategoryRepository.instance;

  // Observables
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxList<VendorCategoryModel> vendorCategories =
      <VendorCategoryModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedCategoryId = Rx<String?>(null);
  final RxString selectedCategoryName = ''.obs;
  final RxString currentSortOption = 'none'.obs;

  // Text Controllers
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Check if there are active filters
  bool get hasActiveFilters =>
      selectedCategoryId.value != null || currentSortOption.value != 'none';

  /// Load initial data (products and categories)
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // Load products and categories in parallel
      await Future.wait([_loadProducts(), _loadCategories()]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_load_products'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all vendor products
  Future<void> _loadProducts() async {
    try {
      final products = await _productRepository.getProducts(vendorId);
      allProducts.value = products;
      searchResults.value = products;
    } catch (e) {
      debugPrint('Error loading products: $e');
      throw 'Failed to load products';
    }
  }

  /// Load vendor categories
  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getVendorCategories(
        vendorId,
      );
      vendorCategories.value = categories;
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Don't throw - categories are optional
    }
  }

  /// Search products by query
  void searchProducts(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFiltersAndSort();
  }

  /// Filter by category
  void filterByCategory(String? categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    _applyFiltersAndSort();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    selectedCategoryId.value = null;
    selectedCategoryName.value = '';
    _applyFiltersAndSort();
  }

  /// Sort products
  void sortProducts(String sortOption) {
    currentSortOption.value = sortOption;
    _applyFiltersAndSort();
  }

  /// Clear sort
  void clearSort() {
    currentSortOption.value = 'none';
    _applyFiltersAndSort();
  }

  /// Clear all filters
  void clearAllFilters() {
    selectedCategoryId.value = null;
    selectedCategoryName.value = '';
    currentSortOption.value = 'none';
    searchController.clear();
    searchQuery.value = '';
    _applyFiltersAndSort();
  }

  /// Apply all filters and sorting
  void _applyFiltersAndSort() {
    List<ProductModel> results = List.from(allProducts);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      results =
          results.where((product) {
            final title = product.title.toLowerCase();
            final description = product.description?.toLowerCase() ?? '';
            return title.contains(searchQuery.value) ||
                description.contains(searchQuery.value);
          }).toList();
    }

    // Apply category filter
    if (selectedCategoryId.value != null) {
      results =
          results.where((product) {
            return product.vendorCategoryId == selectedCategoryId.value;
          }).toList();
    }

    // Apply sorting
    switch (currentSortOption.value) {
      case 'date_newest':
        results.sort((a, b) {
          final dateA = a.createdAt ?? DateTime.now();
          final dateB = b.createdAt ?? DateTime.now();
          return dateB.compareTo(dateA); // Newest first
        });
        break;

      case 'date_oldest':
        results.sort((a, b) {
          final dateA = a.createdAt ?? DateTime.now();
          final dateB = b.createdAt ?? DateTime.now();
          return dateA.compareTo(dateB); // Oldest first
        });
        break;

      case 'price_high':
        results.sort((a, b) {
          final priceA = a.price;
          final priceB = b.price;
          return priceB.compareTo(priceA); // High to low
        });
        break;

      case 'price_low':
        results.sort((a, b) {
          final priceA = a.price;
          final priceB = b.price;
          return priceA.compareTo(priceB); // Low to high
        });
        break;
    }

    searchResults.value = results;
  }

  /// Refresh products
  Future<void> refreshProducts() async {
    await loadInitialData();
  }
}
