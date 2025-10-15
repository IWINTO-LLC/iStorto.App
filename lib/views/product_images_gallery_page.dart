import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/product_images_gallery_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/models/product_image_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/vendor/product_details_page.dart';

/// صفحة معرض صور المنتجات
/// Product Images Gallery Page
class ProductImagesGalleryPage extends StatelessWidget {
  final String? vendorId;

  const ProductImagesGalleryPage({super.key, this.vendorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductImagesGalleryController());

    // إذا كان هناك vendorId، حمّل صور هذا التاجر فقط
    if (vendorId != null) {
      controller.loadVendorImages(vendorId!);
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'تصفح المنتجات', isBackButtonExist: true),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(controller),

          // شبكة الصور
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allImages.isEmpty) {
                return _buildShimmerGrid();
              }

              if (controller.filteredImages.isEmpty) {
                return _buildEmptyState();
              }

              return _buildMasonryGrid(controller);
            }),
          ),
        ],
      ),
    );
  }

  /// شريط البحث
  Widget _buildSearchBar(ProductImagesGalleryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          controller.searchImages(value);
        },
        decoration: InputDecoration(
          hintText: 'البحث في الصور...'.tr,
          prefixIcon: const Icon(Icons.search, color: TColors.primary),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => controller.clearSearch(),
              );
            }
            return const SizedBox.shrink();
          }),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// شبكة Masonry للصور
  Widget _buildMasonryGrid(ProductImagesGalleryController controller) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.loadMore();
          }
          return false;
        },
        child: MasonryGridView.count(
          padding: const EdgeInsets.all(8),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount:
              controller.filteredImages.length +
              (controller.hasMore.value ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.filteredImages.length) {
              return _buildLoadingCard();
            }

            final image = controller.filteredImages[index];
            return _buildImageCard(image, context);
          },
        ),
      ),
    );
  }

  /// بطاقة صورة واحدة
  Widget _buildImageCard(ProductImageModel image, BuildContext context) {
    return GestureDetector(
      onTap: () => _openProductDetails(image, context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            Hero(
              tag: 'product_image_${image.id}',
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => const TShimmerEffect(
                      width: double.infinity,
                      height: 200,
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
              ),
            ),

            // معلومات المنتج
            if (image.productTitle != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    Text(
                      image.productTitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // السعر
                    if (image.productPrice != null)
                      Row(
                        children: [
                          Text(
                            '${image.productPrice!.toStringAsFixed(2)} SAR',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                          if (image.productOldPrice != null &&
                              image.productOldPrice! > image.productPrice!)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                image.productOldPrice!.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),

                    // اسم التاجر
                    if (image.vendorName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                image.vendorName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// بطاقة تحميل
  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const TShimmerEffect(width: double.infinity, height: 200),
    );
  }

  /// Shimmer Grid أثناء التحميل الأولي
  Widget _buildShimmerGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: 10,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  /// حالة فارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد صور',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على صور منتجات',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// فتح صفحة تفاصيل المنتج
  Future<void> _openProductDetails(
    ProductImageModel image,
    BuildContext context,
  ) async {
    try {
      // الحصول على بيانات المنتج الكاملة
      final productController = Get.find<ProductController>();
      final product = await productController.getProductById(image.productId);

      if (product == null) {
        Get.snackbar(
          'خطأ',
          'المنتج غير موجود',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
        return;
      }

      // الانتقال لصفحة التفاصيل
      await Get.to(
        () => ProductDetailsPage(product: product),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error opening product details: $e');
      }
      Get.snackbar(
        'خطأ',
        'فشل فتح تفاصيل المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
