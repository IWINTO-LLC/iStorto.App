import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/data/repositories/category_repository.dart';
import 'package:istoreto/featured/shop/controllers/vendor_categories_controller.dart';

class CategoryPriorityController extends GetxController {
  final CategoryRepository _categoryRepository = Get.find<CategoryRepository>();

  // Observable variables
  final categories = <dynamic>[].obs;
  final isLoading = false.obs;
  final vendorId = ''.obs;



  /// Initialize the controller with categories and vendor ID
  void initialize(List<dynamic> initialCategories, String vendorIdValue) {
    categories.assignAll(initialCategories);
    vendorId.value = vendorIdValue;
  }

  /// Reorder categories
  void reorderCategories(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
  }

  /// Save priority order to database
  Future<void> savePriorityOrder() async {
    isLoading.value = true;

    try {
      // Use batch update to minimize database operations and avoid triggering
      // multiple materialized view refreshes
      final List<Map<String, dynamic>> updates = [];

      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];

        // Only update if sort order actually changed
        if (category.sortOrder != i) {
          updates.add({
            'id': category.id,
            'sort_order': i,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }

      // If no updates needed, just return success
      if (updates.isEmpty) {
        Get.snackbar(
          'success'.tr,
          'no_changes_detected'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
        );
        Get.back();
        return;
      }

      // Perform batch update using the repository's optimized method
      await _categoryRepository.batchUpdateCategorySortOrder(updates);

      // تحديث الـ VendorCategoriesController
      try {
        final vendorCategoriesController =
            Get.find<VendorCategoriesController>();
        await vendorCategoriesController.refreshAfterPriorityChange();
      } catch (e) {
        debugPrint(
          'Warning: Could not update vendor categories controller: $e',
        );
      }

      // Show success message
      Get.snackbar(
        'success'.tr,
        'category_priority_updated'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check, color: Colors.white),
      );

      // Go back to previous page
      Get.back();
    } catch (e) {
      // Show error message with more specific error handling
      String errorMessage = 'error_updating_priority'.tr;

      // Check for specific error types
      if (e.toString().contains('PostgrestException')) {
        if (e.toString().contains('comprehensive_search_materialized')) {
          errorMessage = 'database_index_error'.tr;
        } else if (e.toString().contains('concurrent')) {
          errorMessage = 'concurrent_update_error'.tr;
        }
      }

      Get.snackbar(
        'error'.tr,
        '$errorMessage: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
