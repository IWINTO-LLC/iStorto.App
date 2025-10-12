import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';

/// Controller for Global Product Search
///
/// Features:
/// - Search all products by name/description
/// - Filter by vendors
/// - Sort by date (newest/oldest) and price (high/low)
class GlobalProductSearchController extends GetxController {
  // Repositories
  final _productRepository = ProductRepository.instance;
  final _vendorRepository = VendorRepository.instance;

  // Observables
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxList<VendorModel> vendors = <VendorModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedVendorId = Rx<String?>(null);
  final RxString selectedVendorName = ''.obs;
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
      selectedVendorId.value != null || currentSortOption.value != 'none';

  /// Load initial data (products and vendors)
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // Load products and vendors in parallel
      await Future.wait([_loadProducts(), _loadVendors()]);
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

  /// Load all products from all vendors
  Future<void> _loadProducts() async {
    try {
      final products = await _productRepository.getAllProductsWithoutVendor();
      allProducts.value = products;
      searchResults.value = products;
    } catch (e) {
      debugPrint('Error loading products: $e');
      throw 'Failed to load products';
    }
  }

  /// Load all active vendors
  Future<void> _loadVendors() async {
    try {
      final vendorsList = await _vendorRepository.getAllActiveVendors();
      vendors.value = vendorsList;
    } catch (e) {
      debugPrint('Error loading vendors: $e');
      // Don't throw - vendors are optional for filtering
    }
  }

  /// Search products by query
  void searchProducts(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFiltersAndSort();
  }

  /// Filter by vendor
  void filterByVendor(String? vendorId, String vendorName) {
    selectedVendorId.value = vendorId;
    selectedVendorName.value = vendorName;
    _applyFiltersAndSort();
  }

  /// Clear vendor filter
  void clearVendorFilter() {
    selectedVendorId.value = null;
    selectedVendorName.value = '';
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
    selectedVendorId.value = null;
    selectedVendorName.value = '';
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

    // Apply vendor filter
    if (selectedVendorId.value != null) {
      results =
          results.where((product) {
            return product.vendorId == selectedVendorId.value;
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
