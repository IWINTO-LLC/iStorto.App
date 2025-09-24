import 'package:get/get.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class ProductControllerx extends GetxController {
  var products = <ProductModel>[].obs;
  var selectedProducts = <ProductModel>[].obs;
  var isGridView = false.obs;
  var selectionMode = false.obs;
  var selectAll = false.obs;
  CategoryModel category = CategoryModel.empty();
  SectorModel newSector = SectorModel.empty();
  final _productRepository = ProductRepository.instance;

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
      await _productRepository.updateProduct(product);
      TLoader.successSnackBar(
        title: "common.success".tr,
        message: "product.updated_successfully".tr,
      );
    } catch (e) {
      TLoader.erroreSnackBar(message: "product.update_error".tr);
    }
  }

  void toggleView() => isGridView.value = !isGridView.value;

  Future<void> saveChanges() async {
    if (selectedProducts.isNotEmpty) {
      try {
        for (var product in selectedProducts) {
          await _productRepository.updateProduct(product);
        }
        TLoader.successSnackBar(
          title: "common.success".tr,
          message: "product.bulk_update_success".tr,
        );
        selectedProducts.clear();
        selectionMode.value = false;
      } catch (e) {
        TLoader.erroreSnackBar(message: "product.bulk_update_error".tr);
      }
    } else {
      TLoader.warningSnackBar(
        title: "common.warning".tr,
        message: "product.no_products_selected".tr,
      );
    }
  }

  void searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    products.value =
        products
            .where((p) => p.title.toLowerCase().contains(lowerQuery))
            .toList();
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

  Future<void> deleteSelectedProducts(String vendorId) async {
    if (selectedProducts.isEmpty) {
      TLoader.warningSnackBar(
        title: "common.warning".tr,
        message: "product.no_products_selected".tr,
      );
      return;
    }

    try {
      TLoader.progressSnackBar(
        title: "common.processing".tr,
        message: "product.deleting_products".tr,
      );

      final productIds = selectedProducts.map((p) => p.id).toList();
      await _productRepository.bulkDeleteProducts(productIds);

      for (var product in selectedProducts) {
        products.remove(product);
      }
      selectedProducts.clear();
      selectionMode.value = false;

      TLoader.successSnackBar(
        title: "common.success".tr,
        message: "product.products_deleted_successfully".tr,
      );
    } catch (e) {
      TLoader.erroreSnackBar(message: "product.delete_error".tr);
    }
  }

  Future<void> moveSelectedProductsToCategory(CategoryModel category) async {
    if (selectedProducts.isEmpty) {
      TLoader.warningSnackBar(
        title: "common.warning".tr,
        message: "product.no_products_selected".tr,
      );
      return;
    }

    try {
      for (var product in selectedProducts) {
        product.category = category;
        var i = products.indexOf(product);
        if (i != -1) {
          products.removeAt(i);
          products.insert(i, product);
        }
      }

      await saveChanges();
      clearSelection();

      TLoader.successSnackBar(
        title: "common.success".tr,
        message: "product.products_moved_to_category".tr,
      );
    } catch (e) {
      TLoader.erroreSnackBar(message: "product.move_to_category_error".tr);
    }
  }

  Future<void> moveSelectedProductsToSector(SectorModel sector) async {
    if (selectedProducts.isEmpty) {
      TLoader.warningSnackBar(
        title: "common.warning".tr,
        message: "product.no_products_selected".tr,
      );
      return;
    }

    try {
      for (var product in selectedProducts) {
        product.productType = sector.name;
        var i = products.indexOf(product);
        if (i != -1) {
          products.removeAt(i);
          products.insert(i, product);
        }
      }

      await saveChanges();

      TLoader.successSnackBar(
        title: "common.success".tr,
        message: "product.products_moved_to_sector".tr,
      );
    } catch (e) {
      TLoader.erroreSnackBar(message: "product.move_to_sector_error".tr);
    }
  }
}
