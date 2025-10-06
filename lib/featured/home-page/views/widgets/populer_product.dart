import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

/// مكون عرض المنتجات الشائعة
/// Popular products display component
class PopularProduct extends StatelessWidget {
  const PopularProduct({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.put(ProductController());

    // تحميل البيانات عند بناء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPopularProducts(productController);
    });

    return Column(
      children: [
        // رأس القسم مع زر عرض الكل
        _PopularProductsHeader(controller: productController),
        const SizedBox(height: 16),

        // قائمة المنتجات في شبكة 2 أعمدة
        _ProductsGrid(controller: productController),
      ],
    );
  }

  /// تحميل المنتجات الشائعة من قاعدة البيانات
  /// Load popular products from database
  Future<void> _loadPopularProducts(ProductController controller) async {
    try {
      // جلب جميع المنتجات بدون تحديد تاجر معين
      await controller.fetchAllProductsWithoutVendor();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في جلب المنتجات الشائعة: $e');
        print('Error details: ${e.toString()}');
      }

      // محاولة بديلة - إعادة المحاولة
      try {
        await Future.delayed(const Duration(seconds: 1));
        await controller.fetchAllProductsWithoutVendor();
      } catch (e2) {
        if (kDebugMode) {
          print('خطأ في المحاولة البديلة: $e2');
        }
      }
    }
  }
}

/// رأس قسم المنتجات الشائعة مع زر عرض الكل
/// Popular products section header with view all button
class _PopularProductsHeader extends StatelessWidget {
  final ProductController controller;

  const _PopularProductsHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'popular_products'.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _ViewAllButton(controller: controller),
        ],
      ),
    );
  }
}

/// زر عرض الكل
/// View all button
class _ViewAllButton extends StatelessWidget {
  final ProductController controller;

  const _ViewAllButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAllProducts(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'view_all'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
          ],
        ),
      ),
    );
  }

  /// عرض جميع المنتجات (يمكن تطويرها للتنقل إلى صفحة منفصلة)
  /// Show all products (can be developed to navigate to separate page)
  void _showAllProducts(BuildContext context) {
    // TODO: إضافة navigation إلى صفحة عرض جميع المنتجات
    Get.snackbar(
      'view_all_products'.tr,
      'all_products_will_be_shown'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
    );
  }
}

/// مكون عرض المنتجات في شبكة 2 أعمدة
/// Products grid component with 2 columns
class _ProductsGrid extends StatelessWidget {
  final ProductController controller;

  const _ProductsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _ProductsLoadingGrid();
      }

      // محاولة جلب المنتجات من مصادر مختلفة
      final products =
          controller.allDynamic.isNotEmpty
              ? controller.allDynamic
              : controller.products.isNotEmpty
              ? controller.products
              : <dynamic>[];

      if (products.isEmpty) {
        return _ProductsEmptyState(controller: controller);
      }

      return _ProductsListGrid(products: products);
    });
  }
}

/// مكون عرض حالة التحميل مع shimmer للشبكة
/// Products loading state with shimmer component for grid
class _ProductsLoadingGrid extends StatelessWidget {
  const _ProductsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 2 columns with padding

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6, // Show 6 shimmer cards (3 rows x 2 columns)
      itemBuilder: (context, index) {
        return TShimmerEffect(height: 200, width: cardWidth);
      },
    );
  }
}

/// مكون عرض حالة عدم وجود منتجات
/// Products empty state component
class _ProductsEmptyState extends StatelessWidget {
  final ProductController? controller;

  const _ProductsEmptyState({this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'no_products_available'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            if (controller != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _retryLoadProducts(controller!),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text('retry'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// إعادة محاولة تحميل المنتجات
  /// Retry loading products
  void _retryLoadProducts(ProductController controller) async {
    try {
      await controller.fetchAllProductsWithoutVendor();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في إعادة تحميل المنتجات: $e');
      }
    }
  }
}

/// مكون عرض قائمة المنتجات في شبكة 2 أعمدة
/// Products list grid component with 2 columns
class _ProductsListGrid extends StatelessWidget {
  final List products;

  const _ProductsListGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 2 columns with padding

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductWidgetMedium(
          product: product,
          vendorId: product.vendorId ?? '',
          editMode: false,
          prefferHeight: 250,
          prefferWidth: cardWidth,
        );
      },
    );
  }
}

/// بطاقة المنتج الفردية
/// Individual product card
class _ProductCard extends StatelessWidget {
  final dynamic product;
  final double cardWidth;

  const _ProductCard({required this.product, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      child: ProductWidgetMedium(
        product: product,
        vendorId: product.vendorId ?? '',
        editMode: false,
        prefferHeight: 250,
        prefferWidth: cardWidth,
      ),
    );
  }
}
