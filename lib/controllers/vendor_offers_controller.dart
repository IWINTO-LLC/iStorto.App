import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';

/// Controller لإدارة صفحة عروض التاجر
class VendorOffersController extends GetxController {
  final String vendorId;

  VendorOffersController({required this.vendorId});

  final ProductRepository _productRepository = Get.put(ProductRepository());

  // Search
  final TextEditingController searchController = TextEditingController();

  // Lists
  final RxList<ProductModel> allOffers = <ProductModel>[].obs;
  final RxList<ProductModel> filteredOffers = <ProductModel>[].obs;

  // State
  final RxBool isLoading = false.obs;
  final RxString currentSort = 'discount_high'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOffers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تحميل جميع عروض التاجر
  Future<void> loadOffers() async {
    try {
      isLoading.value = true;

      // جلب جميع المنتجات التي لها خصم (old_price > 0)
      final products = await _productRepository.getVendorOffers(vendorId);

      allOffers.value = products;
      filteredOffers.value = products;

      // فرز افتراضي (أعلى خصم)
      sortOffers('discount_high');

      debugPrint('Loaded ${allOffers.length} offers for vendor $vendorId');
    } catch (e) {
      debugPrint('Error loading offers: $e');
      allOffers.clear();
      filteredOffers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// البحث في العروض
  void searchOffers(String query) {
    if (query.isEmpty) {
      filteredOffers.value = allOffers;
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredOffers.value =
        allOffers.where((product) {
          final titleMatch = product.title.toLowerCase().contains(lowerQuery);
          final descriptionMatch =
              product.description?.toLowerCase().contains(lowerQuery) ?? false;
          return titleMatch || descriptionMatch;
        }).toList();
  }

  /// فرز العروض
  void sortOffers(String sortType) {
    currentSort.value = sortType;

    switch (sortType) {
      case 'discount_high':
        // أعلى خصم
        filteredOffers.sort((a, b) {
          final discountA = _calculateDiscountPercentage(a);
          final discountB = _calculateDiscountPercentage(b);
          return discountB.compareTo(discountA);
        });
        break;

      case 'discount_low':
        // أقل خصم
        filteredOffers.sort((a, b) {
          final discountA = _calculateDiscountPercentage(a);
          final discountB = _calculateDiscountPercentage(b);
          return discountA.compareTo(discountB);
        });
        break;

      case 'price_high':
        // السعر من الأعلى للأقل
        filteredOffers.sort((a, b) => b.price.compareTo(a.price));
        break;

      case 'price_low':
        // السعر من الأقل للأعلى
        filteredOffers.sort((a, b) => a.price.compareTo(b.price));
        break;

      case 'newest':
        // الأحدث أولاً
        filteredOffers.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }

    // تحديث القائمة
    filteredOffers.refresh();
  }

  /// حساب نسبة الخصم
  double _calculateDiscountPercentage(ProductModel product) {
    if (product.oldPrice == null || product.oldPrice! <= 0) {
      return 0;
    }

    final discount =
        ((product.oldPrice! - product.price) / product.oldPrice!) * 100;
    return discount;
  }
}
