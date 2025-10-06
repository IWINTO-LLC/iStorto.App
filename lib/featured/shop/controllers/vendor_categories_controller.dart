import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/data/repositories/category_repository.dart';

class VendorCategoriesController extends GetxController {
  static VendorCategoriesController get instance => Get.find();

  final CategoryRepository _categoryRepository = Get.find<CategoryRepository>();

  // Observable variables
  final RxList<dynamic> categories = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentVendorId = ''.obs;
  final RxBool needsRefresh = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
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
}
