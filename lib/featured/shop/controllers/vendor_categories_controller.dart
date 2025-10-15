import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/data/models/vendor_category_model.dart';
import 'package:istoreto/data/repositories/category_repository.dart';

class VendorCategoriesController extends GetxController {
  static VendorCategoriesController get instance => Get.find();

  final CategoryRepository _categoryRepository = Get.find<CategoryRepository>();

  // Observable variables
  final RxList<dynamic> categories = <dynamic>[].obs;
  final RxList<dynamic> filteredCategories = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentVendorId = ''.obs;
  final RxBool needsRefresh = false.obs;
  final RxString currentFilter = 'all'.obs;
  final TextEditingController searchController = TextEditingController();


  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تحميل فئات التاجر
  Future<void> loadVendorCategories(String vendorId) async {
    try {
      isLoading.value = true;
      currentVendorId.value = vendorId;

      debugPrint('📌 Loading categories for vendor: $vendorId');

      final loadedCategories = await _categoryRepository
          .getAllCategoriesVendorId(vendorId);

      categories.assignAll(loadedCategories);
      _applyCurrentFilter();
      needsRefresh.value = false;

      debugPrint('📌 Loaded ${categories.length} categories');

      // طباعة تفاصيل الفئات للتأكد
      for (var category in categories) {
        debugPrint(
          '📌 Category: ${category.title}, ID: ${category.id}, Sort Order: ${category.sortOrder}',
        );
      }
    } catch (e) {
      debugPrint('Error loading vendor categories: $e');
      // في حالة الخطأ، لا نغير القائمة الموجودة
    } finally {
      isLoading.value = false;
    }
  }

  /// إعادة تحميل الفئات
  Future<void> refreshCategories() async {
    if (currentVendorId.value.isNotEmpty) {
      await loadVendorCategories(currentVendorId.value);
    }
  }

  /// إعادة تحميل الفئات بعد تغيير الترتيب
  Future<void> refreshAfterPriorityChange() async {
    debugPrint('📌 Refreshing categories after priority change');
    needsRefresh.value = true;
    await refreshCategories();
  }

  /// التحقق من وجود فئات
  bool get hasCategories => categories.isNotEmpty;

  /// الحصول على عدد الفئات
  int get categoriesCount => categories.length;

  /// مسح البيانات
  void clearCategories() {
    categories.clear();
    currentVendorId.value = '';
    needsRefresh.value = false;
  }

  /// إضافة فئة جديدة
  void addCategory(dynamic category) {
    categories.add(category);
    // إعادة ترتيب الفئات حسب sort_order
    categories.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
  }

  /// تحديث فئة موجودة
  void updateCategory(dynamic updatedCategory) {
    final index = categories.indexWhere((cat) => cat.id == updatedCategory.id);
    if (index != -1) {
      categories[index] = updatedCategory;
      // إعادة ترتيب الفئات حسب sort_order
      categories.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
    }
  }

  /// حذف فئة
  void removeCategory(String categoryId) {
    categories.removeWhere((cat) => cat.id == categoryId);
  }

  /// تطبيق الفلتر الحالي
  void _applyCurrentFilter() {
    switch (currentFilter.value) {
      case 'active':
        filteredCategories.value =
            categories.where((c) => c.isActive == true).toList();
        break;
      case 'inactive':
        filteredCategories.value =
            categories.where((c) => c.isActive == false).toList();
        break;
      default:
        filteredCategories.value = categories;
    }
  }

  /// فلترة الفئات حسب الحالة
  void filterByStatus(String status) {
    currentFilter.value = status;
    _applyCurrentFilter();
  }

  /// البحث في الفئات
  void searchCategories(String query) {
    if (query.isEmpty) {
      _applyCurrentFilter();
      return;
    }

    final filtered =
        categories.where((category) {
          return category.title.toLowerCase().contains(query.toLowerCase()) ||
              (category.customDescription?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false);
        }).toList();

    filteredCategories.value = filtered;
  }

  /// عرض نافذة إضافة فئة
  void showAddCategoryDialog(String vendorId) {
    var controller = Get.put(CreateCategoryController());
    controller.deleteTempItems();
    Get.toNamed('/create-category', arguments: {'vendorId': vendorId});
  }

  /// عرض نافذة تعديل فئة
  void showEditCategoryDialog(VendorCategoryModel category, String vendorId) {
    // TODO: Implement edit category dialog
    Get.snackbar(
      'Info',
      'Edit category functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// تبديل حالة الفئة الأساسية
  void togglePrimaryStatus(VendorCategoryModel category, String vendorId) {
    try {
      // TODO: Implement toggle primary status
      Get.snackbar(
        'Info',
        'Toggle primary status functionality coming soon!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle primary status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// تبديل حالة الفئة
  void toggleStatus(VendorCategoryModel category, String vendorId) {
    try {
      // TODO: Implement toggle status
      Get.snackbar(
        'Info',
        'Toggle status functionality coming soon!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// عرض تأكيد الحذف
  void showDeleteConfirmation(VendorCategoryModel category, String vendorId) {
    Get.dialog(
      AlertDialog(
        title: Text('vendor_delete_category'.tr),
        content: Text('vendor_delete_category_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteCategory(category, vendorId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  /// حذف الفئة
  void _deleteCategory(VendorCategoryModel category, String vendorId) {
    try {
      // TODO: Implement delete category
      Get.snackbar(
        'Info',
        'Delete category functionality coming soon!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
