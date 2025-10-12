import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/data/repositories/product_image_repository.dart';
import 'package:istoreto/models/product_image_model.dart';

/// كونترولر معرض صور المنتجات
/// Product Images Gallery Controller
class ProductImagesGalleryController extends GetxController {
  static ProductImagesGalleryController get instance => Get.find();

  final productImageRepository = Get.put(ProductImageRepository());

  // Observable lists
  final RxList<ProductImageModel> allImages = <ProductImageModel>[].obs;
  final RxList<ProductImageModel> filteredImages = <ProductImageModel>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final int itemsPerPage = 50;
  final RxBool hasMore = true.obs;

  // Search
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadImages();
  }

  /// تحميل الصور
  Future<void> loadImages({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      allImages.clear();
      filteredImages.clear();
      hasMore.value = true;
    }

    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;

      final offset = currentPage.value * itemsPerPage;
      final images = await productImageRepository.getAllProductImages(
        limit: itemsPerPage,
        offset: offset,
      );

      if (images.isEmpty) {
        hasMore.value = false;
      } else {
        allImages.addAll(images);
        filteredImages.addAll(images);
        currentPage.value++;
      }

      if (kDebugMode) {
        print('✅ Loaded ${images.length} images. Total: ${allImages.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading images: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزيد من الصور
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;

      final offset = currentPage.value * itemsPerPage;
      final images = await productImageRepository.getAllProductImages(
        limit: itemsPerPage,
        offset: offset,
      );

      if (images.isEmpty) {
        hasMore.value = false;
      } else {
        allImages.addAll(images);
        if (searchQuery.value.isEmpty) {
          filteredImages.addAll(images);
        }
        currentPage.value++;
      }

      if (kDebugMode) {
        print('✅ Loaded ${images.length} more images. Total: ${allImages.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading more images: $e');
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// البحث في الصور
  Future<void> searchImages(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredImages.value = allImages;
      return;
    }

    try {
      isLoading.value = true;

      final results = await productImageRepository.searchProductImages(query);
      filteredImages.value = results;

      if (kDebugMode) {
        print('✅ Search results: ${results.length} images');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching images: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// مسح البحث
  void clearSearch() {
    searchQuery.value = '';
    filteredImages.value = allImages;
  }

  /// تحديث القائمة
  Future<void> refresh() async {
    await loadImages(refresh: true);
  }

  /// الحصول على صور تاجر معين
  Future<void> loadVendorImages(String vendorId) async {
    try {
      isLoading.value = true;

      final images = await productImageRepository.getVendorProductImages(vendorId);
      allImages.value = images;
      filteredImages.value = images;

      if (kDebugMode) {
        print('✅ Loaded ${images.length} images for vendor: $vendorId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading vendor images: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
}


