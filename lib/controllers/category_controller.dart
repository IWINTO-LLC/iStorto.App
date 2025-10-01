import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/data/repositories/category_repository.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final isLoading = false.obs;
  final categoryRepository = Get.put(CategoryRepository());
  RxList<CategoryModel> allItems = <CategoryModel>[].obs;

  RxList<CategoryModel> featureCategories = <CategoryModel>[].obs;
  final searchTextController = TextEditingController();
  RxList<CategoryModel> felteredItems = <CategoryModel>[].obs;
  RxBool refreshData = true.obs;
  List<CategoryModel> categoryList = [];
  RxInt productCount = 0.obs;
  final categoryName = TextEditingController();
  final categoryArabicName = TextEditingController();
  final categoryImage = TextEditingController();
  RxString storeId = ''.obs;
  @override
  void onInit() {
    //ever(storeId, (id) =>   fetchCategoryData());
    super.onInit();
  }

  String? lastFetchedUserId;
  var load = false.obs;
  getCategoryOfVendor(String vendorId) async {
    load(true);
    var count = await ProductRepository.instance.getUserProductCount(vendorId);
    productCount.value = count;
    print("📌 product count is $count");
    await SectorController.instance.initialSectors(vendorId);

    if (lastFetchedUserId == vendorId && allItems.isNotEmpty) {
      print("📌 البيانات مخزنة بالفعل، لا حاجة لإعادة الجلب!");
      load(false);
      return;
    }
    ProductController.instance.resetDynamicLists(vendorId);
    var s = await categoryRepository.getAllCategoriesVendorId(vendorId);
    allItems.value = s;
    load(false);
    lastFetchedUserId = vendorId;
    // return allItems;
    // .where((cat) => cat.parentId.isEmpty)
    // .take(8)
    // .toList();
  }

  Future<void> fetchCategoryData() async {
    try {
      isLoading.value = true;
      List<CategoryModel> fetchedItem = [];
      if (allItems.isEmpty) {
        fetchedItem = await categoryRepository.getAllActiveCategories();
      }
      allItems.value = fetchedItem;
      featureCategories.assignAll(
        allItems
            .where((cat) => cat.isActive && cat.vendorId != null)
            .take(8)
            .toList(),
      );
      felteredItems.value = allItems;
      isLoading.value = false;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching category data: $e");
      }
      isLoading.value = false;
      TLoader.warningSnackBar(
        title: "خطأ",
        message:
            Get.locale?.languageCode == 'ar'
                ? "فشل في جلب البيانات"
                : "Failed to fetch data",
      );
    }
  }

  void addItemToLists(CategoryModel item) {
    allItems.add(item);
    felteredItems.add(item);
  }

  void updateItemFromLists(CategoryModel item) {
    final index = allItems.indexWhere((i) => i == item);
    if (index != -1) allItems[index] = item;

    final indexFilt = felteredItems.indexWhere((i) => i == item);
    if (indexFilt != -1) felteredItems[indexFilt] = item;
    felteredItems.refresh();
  }

  void removeItemFromLists(CategoryModel item) {
    allItems.remove(item);
    if (item.isActive) featureCategories.remove(item);
    felteredItems.remove(item);
  }

  Future<List<CategoryModel>> getSubCategories(
    String categoryId,
    String userId,
  ) async {
    try {
      // For now, return empty list as subcategories are not implemented in the current schema
      // This can be extended when parent-child category relationships are added
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Error getting subcategories: $e");
      }
      return [];
    }
  }

  bool selectedItem = true;

  RxString selectedValue = ''.obs;

  void resetFormField() {
    categoryName.clear();
    categoryImage.clear();
    categoryArabicName.clear();
  }

  void uploadCategoryPhoto() async {}

  Future<void> deleteCategory(String categoryId) async {
    try {
      if (categoryId.isEmpty) {
        TLoader.warningSnackBar(
          title: "خطأ",
          message:
              Get.locale?.languageCode == 'ar'
                  ? "معرف الفئة مطلوب"
                  : "Category ID is required",
        );
        return;
      }

      if (await showExitDialog()) {
        await categoryRepository.deleteCategory(categoryId);

        // Remove from local lists
        final categoryToRemove = allItems.firstWhereOrNull(
          (cat) => cat.id == categoryId,
        );
        if (categoryToRemove != null) {
          removeItemFromLists(categoryToRemove);
        }

        TLoader.successSnackBar(
          title: "نجح",
          message:
              Get.locale?.languageCode == 'ar'
                  ? "تم الحذف بنجاح"
                  : "Deleted successfully",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting category: $e");
      }
      TLoader.warningSnackBar(
        title: "خطأ",
        message:
            Get.locale?.languageCode == 'ar'
                ? "فشل في حذف الفئة"
                : "Failed to delete category",
      );
    }
  }

  Future<bool> showExitDialog() async {
    return await showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: Text(
              "حذف",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            content: Text(
              "هل أنت متأكد من حذف الفئة",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "لا",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall!.apply(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  "نعم",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall!.apply(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  RxList<ProductModel> all = <ProductModel>[].obs;
  RxList<ProductModel> filteredItem = <ProductModel>[].obs;
  Future<List<ProductModel>> getCategoryProduct({
    required String categoryId,
    required String userId,
  }) async {
    try {
      final products = await ProductRepository.instance.getProductsByCategory(
        categoryId: categoryId,
        vendorId: userId,
      );
      all.assignAll(products);
      filteredItem.assignAll(all);
      return products;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting category products: $e");
      }
      return [];
    }
  }

  searchQuery(String query) {
    final lowerQuery = query.trim().toLowerCase();
    filteredItem.assignAll(
      all.where((item) => item.title.toLowerCase().contains(lowerQuery)),
    );
  }

  // Add new category
  Future<void> addCategory(CategoryModel category) async {
    try {
      isLoading.value = true;

      final newCategory = await categoryRepository.addCategory(category);
      addItemToLists(newCategory);

      TLoader.successSnackBar(
        title: "نجح",
        message:
            Get.locale?.languageCode == 'ar'
                ? "تم إضافة الفئة بنجاح"
                : "Category added successfully",
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error adding category: $e");
      }
      TLoader.warningSnackBar(
        title: "خطأ",
        message:
            Get.locale?.languageCode == 'ar'
                ? "فشل في إضافة الفئة"
                : "Failed to add category",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      isLoading.value = true;

      final updatedCategory = await categoryRepository.updateCategory(category);
      updateItemFromLists(updatedCategory);

      TLoader.successSnackBar(
        title: "نجح",
        message:
            Get.locale?.languageCode == 'ar'
                ? "تم تحديث الفئة بنجاح"
                : "Category updated successfully",
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error updating category: $e");
      }
      TLoader.warningSnackBar(
        title: "خطأ",
        message:
            Get.locale?.languageCode == 'ar'
                ? "فشل في تحديث الفئة"
                : "Failed to update category",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search categories
  Future<List<CategoryModel>> searchCategories(
    String query, {
    String? vendorId,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final results = await categoryRepository.searchCategories(
        query,
        vendorId: vendorId,
      );
      return results;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching categories: $e");
      }
      return [];
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      return await categoryRepository.getCategoryById(categoryId);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting category by ID: $e");
      }
      return null;
    }
  }

  // Update category sort order
  Future<void> updateCategorySortOrder(
    String categoryId,
    int newSortOrder,
  ) async {
    try {
      await categoryRepository.updateCategorySortOrder(
        categoryId,
        newSortOrder,
      );

      // Update local list
      final categoryIndex = allItems.indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex != -1) {
        allItems[categoryIndex] = allItems[categoryIndex].copyWith(
          sortOrder: newSortOrder,
        );
        allItems.refresh();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating sort order: $e");
      }
      TLoader.warningSnackBar(
        title: "خطأ",
        message:
            Get.locale?.languageCode == 'ar'
                ? "فشل في تحديث ترتيب الفئة"
                : "Failed to update category sort order",
      );
    }
  }

  // Get categories count for vendor
  Future<int> getCategoriesCount(String vendorId) async {
    try {
      return await categoryRepository.getCategoriesCount(vendorId);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting categories count: $e");
      }
      return 0;
    }
  }

  // Refresh categories for user
  Future<void> refreshVendorCategories(String vendorId) async {
    try {
      isLoading.value = true;
      await getCategoryOfVendor(vendorId);
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing user categories: $e");
      }
      TLoader.warningSnackBar(
        title: "خطأ",
        message:
            Get.locale?.languageCode == 'ar'
                ? "فشل في تحديث الفئات"
                : "Failed to refresh categories",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all data
  void clearAllData() {
    allItems.clear();
    featureCategories.clear();
    felteredItems.clear();
    all.clear();
    filteredItem.clear();
    productCount.value = 0;
    lastFetchedUserId = null;
    resetFormField();
  }
}
