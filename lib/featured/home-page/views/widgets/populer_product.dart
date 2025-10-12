import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/home-page/views/widgets/discover_product.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium.dart';
import 'package:istoreto/featured/shop/view/widgets/dynamic_product_grid_widget.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:sizer/sizer.dart';

import 'small-widgets/view_all.dart';

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
          ViewAll(onTap: () => _showAllProducts(context)),
        ],
      ),
    );
  }
}

/// زر عرض الكل
/// View all button
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
    final List<ProductModel> list = products as List<ProductModel>;
    return Column(
      children: [
        // PageView.builder(
        //   itemCount: products.length,
        //   itemBuilder: (context, index) {
        //     final product = products[index];
        //     return Padding(
        //       padding: const EdgeInsets.all(16.0),
        //       child: Column(
        //         children: [
        //           Expanded(
        //             child: CustomCaChedNetworkImage(
        //               width: 80.w,
        //               height: 300,
        //               url: product.images.first,
        //               raduis: BorderRadius.circular(15),
        //             ),
        //           ),
        //           const SizedBox(height: 12),
        //           Text(
        //             product.title,
        //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        //           ),
        //           Text(
        //             '\$${product.price.toStringAsFixed(2)}',
        //             style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        //           ),
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: List.generate(5, (i) {
        //               return Icon(Icons.star, color: Colors.orange);
        //             }),
        //           ),
        //           const SizedBox(height: 12),
        //           ElevatedButton(
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: Colors.purple,
        //               padding: EdgeInsets.symmetric(
        //                 horizontal: 24,
        //                 vertical: 12,
        //               ),
        //             ),
        //             onPressed: () {
        //               // تنفيذ الطلب
        //             },
        //             child: Text('ORDER NOW →'),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        GridView.builder(
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
        ),

        SizedBox(height: TSizes.spaceBtWsections),
        SizedBox(height: TSizes.spaceBtWsections),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trendy Now'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ViewAll(onTap: () => _showAllProducts(context)),
            ],
          ),
        ),
        DynamicProductGridWidget(
          cardHeight: 94.w * (8 / 6),
          cardWidth: 94.w,
          products: list,
          withTitle: true,
        ),

        SizedBox(height: TSizes.spaceBtWsections),
        SizedBox(height: TSizes.spaceBtWsections),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Rating'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ViewAll(onTap: () => _showAllProducts(context)),
            ],
          ),
        ),
        DynamicProductGridWidget(
          cardWidth: 33.333.w,
          cardHeight: 34.w * (4 / 3),
          products: list,
          withTitle: true,
        ),
        SizedBox(height: TSizes.spaceBtWsections),
        SizedBox(height: TSizes.spaceBtWsections),

        DiscoverProductWidget(),
        SizedBox(height: TSizes.spaceBtWsections),
        SizedBox(height: TSizes.spaceBtWsections),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Now'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ViewAll(onTap: () => _showAllProducts(context)),
            ],
          ),
        ),
        DynamicProductGridWidget(
          cardWidth: 70.w,
          cardHeight: 70.w * 4 / 3,
          products: list,
          withTitle: true,
        ),

        SizedBox(height: TSizes.spaceBtWsections),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Summer Sales'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ViewAll(onTap: () => _showAllProducts(context)),
            ],
          ),
        ),
        DynamicProductGridWidget(
          cardWidth: 55.w,
          cardHeight: 55.w * (8 / 6),
          products: list,
          withTitle: true,
        ),

        SizedBox(height: TSizes.spaceBtWsections),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trendy Now'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ViewAll(onTap: () => _showAllProducts(context)),
            ],
          ),
        ),
        DynamicProductGridWidget(
          cardHeight: 94.w * (8 / 6),
          cardWidth: 94.w,
          products: list,
          withTitle: true,
        ),
      ],
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
