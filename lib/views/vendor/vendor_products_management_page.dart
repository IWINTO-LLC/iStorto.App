import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/controllers/vendor_products_management_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/vendor/add_product_page.dart';
import 'package:istoreto/views/vendor/product_details_page.dart';

/// صفحة إدارة منتجات التاجر
class VendorProductsManagementPage extends StatelessWidget {
  final String vendorId;

  const VendorProductsManagementPage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorProductsManagementController());

    // تحميل المنتجات عند البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVendorProducts(vendorId);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'products_management'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadVendorProducts(vendorId),
            tooltip: 'reload'.tr,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.allProducts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Search and Filter Bar
            _buildSearchAndFilterBar(controller),

            // Products Count
            _buildProductsCount(controller),

            // Products List
            Expanded(child: _buildProductsList(controller)),
          ],
        );
      }),
      // Floating Action Button لإضافة منتج جديد
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => AddProductPage(vendorId: vendorId));
          if (result == true) {
            controller.loadVendorProducts(vendorId);
          }
        },
        backgroundColor: TColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'add_new_product'.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// حالة التحميل
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const TShimmerEffect(width: 80, height: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerEffect(
                      width: double.infinity,
                      height: 16,
                      raduis: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    TShimmerEffect(
                      width: 150,
                      height: 14,
                      raduis: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    TShimmerEffect(
                      width: 100,
                      height: 20,
                      raduis: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// حالة عدم وجود منتجات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'no_products_found'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_first_product'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => AddProductPage(vendorId: vendorId)),
            icon: const Icon(Icons.add),
            label: Text('add_new_product'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// شريط البحث والفلترة
  Widget _buildSearchAndFilterBar(
    VendorProductsManagementController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'search_products_placeholder'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => controller.searchProducts(value),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) => controller.filterByStatus(value),
            itemBuilder:
                (context) => [
                  _buildFilterMenuItem(
                    controller,
                    'all',
                    'all_products'.tr,
                    Icons.filter_list,
                  ),
                  _buildFilterMenuItem(
                    controller,
                    'active',
                    'active_products'.tr,
                    Icons.check_circle,
                  ),
                  _buildFilterMenuItem(
                    controller,
                    'deleted',
                    'deleted_products'.tr,
                    Icons.delete,
                  ),
                ],
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
    );
  }

  /// عنصر قائمة الفلتر
  PopupMenuItem<String> _buildFilterMenuItem(
    VendorProductsManagementController controller,
    String value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Obx(() {
        final isSelected = controller.currentFilter.value == value;
        return Row(
          children: [
            Icon(
              isSelected ? Icons.check : icon,
              size: 20,
              color: isSelected ? Colors.green : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        );
      }),
    );
  }

  /// عداد المنتجات
  Widget _buildProductsCount(VendorProductsManagementController controller) {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            Icon(Icons.inventory, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              '${'found'.tr} ${controller.filteredProducts.length} ${'products'.tr}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// قائمة المنتجات
  Widget _buildProductsList(VendorProductsManagementController controller) {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'no_results_found'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadVendorProducts(vendorId),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = controller.filteredProducts[index];
            return _buildProductCard(controller, product);
          },
        ),
      );
    });
  }

  /// بطاقة المنتج
  Widget _buildProductCard(
    VendorProductsManagementController controller,
    ProductModel product,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => ProductDetailsPage(product: product));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // صورة المنتج
              _buildProductImage(product),
              const SizedBox(width: 16),

              // معلومات المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان والحالة
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(product.isDeleted),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // الوصف
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),

                    // السعر والإجراءات
                    Row(
                      children: [
                        // السعر
                        Text(
                          '${product.price} ${product.currency ?? 'USD'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
                        ),
                        if (product.oldPrice != null &&
                            product.oldPrice! > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${product.oldPrice}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const Spacer(),

                        // زر الخيارات
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed:
                              () => controller.showProductOptions(
                                Get.context!,
                                product,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// صورة المنتج
  Widget _buildProductImage(ProductModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.grey.shade200,
        child:
            product.images.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: product.images.first,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const TShimmerEffect(width: 80, height: 80),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.grey.shade400,
                      ),
                )
                : Icon(
                  Icons.inventory_2,
                  size: 30,
                  color: Colors.grey.shade400,
                ),
      ),
    );
  }

  /// Chip الحالة
  Widget _buildStatusChip(bool isDeleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isDeleted
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDeleted ? Icons.delete : Icons.check_circle,
            size: 14,
            color: isDeleted ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isDeleted ? 'deleted'.tr : 'active'.tr,
            style: TextStyle(
              fontSize: 12,
              color: isDeleted ? Colors.red : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
