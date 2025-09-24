import 'package:get/get.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/custom_Excel_menu/data/temp_product_repository.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/loader/loaders.dart';
import 'package:istoreto/utils/logging/logger.dart';

class ProductControllerExcel extends GetxController {
  static ProductControllerExcel get instance => Get.find();

  var products = <ProductModel>[].obs;
  var selectedProducts = <ProductModel>[].obs;
  var isGridView = false.obs;
  var selectionMode = false.obs;
  var selectAll = false.obs;
  var isLoading = false.obs;

  CategoryModel category = CategoryModel.empty();
  SectorModel newSector = SectorModel.empty();

  final _tempProductRepository = TempProductRepository.instance;

  void clearSelection() {
    selectedProducts.clear();
    selectionMode.value = false;
  }

  void deleteSelected() {
    selectAll.value = false;
    selectedProducts.clear();
    //  selectionMode.value = false;
  }

  void enableSelectionMode() {
    selectionMode.value = true;
  }

  void toggleSelection(ProductModel product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product);
    } else {
      selectedProducts.add(product);
    }

    // تأكيد تحديث وضع التحديد عند اختيار منتج واحد على الأقل
    selectionMode.value = selectedProducts.isNotEmpty;
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      isLoading.value = true;
      final success = await _tempProductRepository.updateTempProduct(product);
      if (success) {
        TLoader.successSnackBar(
          title: 'excel.product_updated'.tr,
          message: 'excel.product_updated_successfully'.tr,
        );
      } else {
        TLoader.erroreSnackBar(message: 'excel.failed_to_update_product'.tr);
      }
    } catch (e) {
      TLoggerHelper.error('Error updating product: $e');
      TLoader.erroreSnackBar(message: 'excel.failed_to_update_product'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() => isGridView.value = !isGridView.value;

  Future<void> saveChanges() async {
    if (selectedProducts.isNotEmpty) {
      try {
        isLoading.value = true;
        final success = await _tempProductRepository.bulkActivateTempProducts(
          selectedProducts,
        );
        if (success) {
          TLoader.successSnackBar(
            title: 'excel.products_saved'.tr,
            message: 'excel.products_saved_successfully'.tr,
          );
          selectedProducts.clear();
          selectionMode.value = false;
          await fetchTempProducts(selectedProducts.first.vendorId ?? '');
        } else {
          TLoader.erroreSnackBar(message: 'excel.failed_to_save_products'.tr);
        }
      } catch (e) {
        TLoggerHelper.error('Error saving products: $e');
        TLoader.erroreSnackBar(message: 'excel.failed_to_save_products'.tr);
      } finally {
        isLoading.value = false;
      }
    } else {
      TLoader.warningSnackBar(
        title: 'common.warning'.tr,
        message: 'excel.no_products_selected'.tr,
      );
    }
  }

  Future<void> searchProducts(String query, String vendorId) async {
    try {
      isLoading.value = true;
      if (query.isEmpty) {
        await fetchTempProducts(vendorId);
      } else {
        final searchResults = await _tempProductRepository.searchTempProducts(
          vendorId,
          query,
        );
        products.value = searchResults;
      }
    } catch (e) {
      TLoggerHelper.error('Error searching products: $e');
      TLoader.erroreSnackBar(message: 'excel.failed_to_search_products'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelectAll() {
    if (selectAll.value) {
      deleteSelected();
    } else {
      selectAllProducts();
    }
  }

  void selectAllProducts() {
    selectAll.value = true;
    selectedProducts.clear();
    selectedProducts.assignAll(products);
    selectionMode.value = true;
  }

  //deleteTempProduct
  Future<void> deleteSelectedProducts(String vendorId) async {
    if (selectedProducts.isNotEmpty) {
      try {
        isLoading.value = true;
        final productIds = selectedProducts.map((p) => p.id).toList();
        final success = await _tempProductRepository.bulkDeleteTempProducts(
          productIds,
        );

        if (success) {
          for (var product in selectedProducts) {
            products.remove(product);
          }
          selectedProducts.clear();
          selectionMode.value = false;

          TLoader.successSnackBar(
            title: 'excel.products_deleted'.tr,
            message: 'excel.products_deleted_successfully'.tr,
          );
        } else {
          TLoader.erroreSnackBar(message: 'excel.failed_to_delete_products'.tr);
        }
      } catch (e) {
        TLoggerHelper.error('Error deleting products: $e');
        TLoader.erroreSnackBar(message: 'excel.failed_to_delete_products'.tr);
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteOneProduct(ProductModel product, String vendorId) async {
    try {
      isLoading.value = true;
      final success = await _tempProductRepository.deleteTempProduct(
        product.id,
      );

      if (success) {
        products.remove(product);
        selectedProducts.remove(product);

        TLoader.successSnackBar(
          title: 'excel.product_deleted'.tr,
          message: 'excel.product_deleted_successfully'.tr,
        );
      } else {
        TLoader.erroreSnackBar(message: 'excel.failed_to_delete_product'.tr);
      }
    } catch (e) {
      TLoggerHelper.error('Error deleting product: $e');
      TLoader.erroreSnackBar(message: 'excel.failed_to_delete_product'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> moveSelectedProductsToCategory(CategoryModel category) async {
    if (selectedProducts.isNotEmpty) {
      try {
        isLoading.value = true;
        for (var product in selectedProducts) {
          await _tempProductRepository.updateProductCategory(
            product.id,
            category,
          );
          // product.category = category; // Category will be updated via repository
          var i = products.indexOf(product);
          products[i] = product;
        }

        TLoader.successSnackBar(
          title: 'excel.products_moved'.tr,
          message: 'excel.products_moved_to_category_successfully'.tr,
        );
      } catch (e) {
        TLoggerHelper.error('Error moving products to category: $e');
        TLoader.erroreSnackBar(
          message: 'excel.failed_to_move_products_to_category'.tr,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> moveSelectedProductsToSector(SectorModel sector) async {
    if (selectedProducts.isNotEmpty) {
      try {
        isLoading.value = true;
        for (var product in selectedProducts) {
          await _tempProductRepository.updateProductSector(product.id, sector);
          product.productType = sector.name;
          var i = products.indexOf(product);
          products[i] = product;
        }

        TLoader.successSnackBar(
          title: 'excel.products_moved'.tr,
          message: 'excel.products_moved_to_sector_successfully'.tr,
        );
      } catch (e) {
        TLoggerHelper.error('Error moving products to sector: $e');
        TLoader.erroreSnackBar(
          message: 'excel.failed_to_move_products_to_sector'.tr,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> activeSelected() async {
    if (selectedProducts.isNotEmpty) {
      try {
        isLoading.value = true;
        final success = await _tempProductRepository.bulkActivateTempProducts(
          selectedProducts,
        );

        if (success) {
          selectedProducts.clear();
          selectionMode.value = false;

          TLoader.successSnackBar(
            title: 'excel.products_activated'.tr,
            message: 'excel.products_activated_successfully'.tr,
          );
        } else {
          TLoader.erroreSnackBar(
            message: 'excel.failed_to_activate_products'.tr,
          );
        }
      } catch (e) {
        TLoggerHelper.error('Error activating products: $e');
        TLoader.erroreSnackBar(message: 'excel.failed_to_activate_products'.tr);
      } finally {
        isLoading.value = false;
      }
    } else {
      TLoader.warningSnackBar(
        title: 'common.warning'.tr,
        message: 'excel.please_select_products_to_activate'.tr,
      );
    }
  }

  // Fetch temporary products for a vendor
  Future<void> fetchTempProducts(String vendorId) async {
    try {
      isLoading.value = true;
      final tempProducts = await _tempProductRepository.getTempProductsByVendor(
        vendorId,
      );
      products.value = tempProducts;
    } catch (e) {
      TLoggerHelper.error('Error fetching temp products: $e');
      TLoader.erroreSnackBar(message: 'excel.failed_to_load_products'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Get temp products count
  Future<int> getTempProductsCount(String vendorId) async {
    try {
      return await _tempProductRepository.getTempProductsCount(vendorId);
    } catch (e) {
      TLoggerHelper.error('Error getting temp products count: $e');
      return 0;
    }
  }
}
