import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/services/supabase_service.dart';

/// Controller لإدارة منتجات التاجر
class VendorProductsManagementController extends GetxController {
  final ProductRepository _repository = ProductRepository.instance;

  // Observables
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString currentFilter = 'all'.obs; // all, active, deleted

  // Search controller
  final searchController = TextEditingController();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تحميل منتجات التاجر
  Future<void> loadVendorProducts(String vendorId) async {
    try {
      isLoading.value = true;

      // جلب جميع المنتجات (بما في ذلك المحذوفة)
      final products = await _repository.getAllProducts(vendorId);
      allProducts.value = products;

      // تطبيق الفلاتر
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading vendor products: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_load_products'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// البحث في المنتجات
  void searchProducts(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  /// الفلترة حسب الحالة
  void filterByStatus(String status) {
    currentFilter.value = status;
    _applyFilters();
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    List<ProductModel> results = List.from(allProducts);

    // تطبيق فلتر الحالة
    switch (currentFilter.value) {
      case 'active':
        results = results.where((p) => !p.isDeleted).toList();
        break;
      case 'deleted':
        results = results.where((p) => p.isDeleted).toList();
        break;
      default:
      // all - no filter
    }

    // تطبيق فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      results =
          results.where((product) {
            final title = product.title.toLowerCase();
            final description = (product.description ?? '').toLowerCase();
            return title.contains(searchQuery.value) ||
                description.contains(searchQuery.value);
          }).toList();
    }

    filteredProducts.value = results;
  }

  /// حذف منتج (soft delete)
  Future<void> deleteProduct(ProductModel product) async {
    try {
      // تأكيد الحذف
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('delete_product'.tr),
          content: Text('delete_product_confirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('delete'.tr, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Soft delete
        await _repository.deleteProduct(product.id);

        // تحديث القائمة المحلية
        final index = allProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          allProducts[index] = product.copyWith(isDeleted: true);
        }

        _applyFilters();

        Get.snackbar(
          'success'.tr,
          'product_deleted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_product'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// استعادة منتج محذوف
  Future<void> restoreProduct(ProductModel product) async {
    try {
      // استعادة المنتج عبر تحديث is_deleted إلى false
      await SupabaseService.client
          .from('products')
          .update({'is_deleted': false})
          .eq('id', product.id);

      // تحديث القائمة المحلية
      final index = allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        allProducts[index] = product.copyWith(isDeleted: false);
      }

      _applyFilters();

      Get.snackbar(
        'success'.tr,
        'product_restored_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_restore_product'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// حذف نهائي للمنتج
  Future<void> permanentlyDeleteProduct(ProductModel product) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('permanently_delete_product'.tr),
          content: Text('permanently_delete_warning'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'delete_permanently'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // حذف نهائي من قاعدة البيانات
        await SupabaseService.client
            .from('products')
            .delete()
            .eq('id', product.id);

        allProducts.removeWhere((p) => p.id == product.id);
        _applyFilters();

        Get.snackbar(
          'success'.tr,
          'product_permanently_deleted'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_permanently'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// عرض خيارات المنتج
  void showProductOptions(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // العنوان
              Text(
                product.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // الخيارات
              if (!product.isDeleted) ...[
                _buildOptionTile(
                  icon: Icons.edit,
                  title: 'edit_product'.tr,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to edit page
                    // Get.to(() => EditProductPage(product: product));
                  },
                ),
                _buildOptionTile(
                  icon: Icons.delete,
                  title: 'delete_product'.tr,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    deleteProduct(product);
                  },
                ),
              ] else ...[
                _buildOptionTile(
                  icon: Icons.restore,
                  title: 'restore_product'.tr,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    restoreProduct(product);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.delete_forever,
                  title: 'delete_permanently'.tr,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    permanentlyDeleteProduct(product);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }
}
