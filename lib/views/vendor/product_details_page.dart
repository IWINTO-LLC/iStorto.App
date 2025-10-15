import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:istoreto/featured/home-page/views/widgets/cart_white.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/appbar.dart';

/// صفحة تفاصيل المنتج
///
/// الميزات:
/// - عرض صور المنتج بشكل دوار
/// - عرض تفاصيل المنتج الكاملة
/// - زر إضافة إلى السلة
/// - التحكم بالكمية
/// - عرض السعر والخصم
class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final currentImageIndex = 0.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TAppBar(
        title: Text(
          product.title,
          style: titilliumBold.copyWith(fontSize: 18, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        showBackArrow: true,
        actions: [
          // أيقونة السلة
          IconButton(
            onPressed: () {
              Get.to(() => const CartWhite(), transition: Transition.cupertino);
            },
            icon: Obx(() {
              final total = cartController.total.value;
              return Badge(
                label: Text('$total'),
                isLabelVisible: total > 0,
                child: const Icon(Icons.shopping_cart, color: Colors.black),
              );
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معرض الصور
            _buildImageGallery(product, currentImageIndex),

            // مؤشر الصور
            if (product.images.isNotEmpty)
              _buildImageIndicator(product, currentImageIndex),

            const SizedBox(height: 20),

            // تفاصيل المنتج
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    product.title,
                    style: titilliumBold.copyWith(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // السعر والخصم
                  _buildPriceSection(product),
                  const SizedBox(height: 20),

                  // الوصف
                  if (product.description?.isNotEmpty == true) ...[
                    Text(
                      'description'.tr,
                      style: titilliumBold.copyWith(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: titilliumRegular.copyWith(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // الحد الأدنى للكمية
                  if (product.minQuantity > 1) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${'product.minimum_quantity'.tr}: ${product.minQuantity}',
                            style: titilliumRegular.copyWith(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // معلومات إضافية
                  _buildAdditionalInfo(product),

                  const SizedBox(height: 100), // مساحة للزر السفلي
                ],
              ),
            ),
          ],
        ),
      ),
      // زر الإضافة إلى السلة
      bottomNavigationBar: _buildAddToCartBar(product, cartController),
    );
  }

  /// معرض الصور
  Widget _buildImageGallery(ProductModel product, RxInt currentIndex) {
    final images =
        product.images.isNotEmpty ? product.images : [product.thumbnail ?? ''];

    return Container(
      height: 350,
      color: Colors.grey[100],
      child: CarouselSlider(
        options: CarouselOptions(
          height: 350,
          viewportFraction: 1.0,
          enableInfiniteScroll: images.length > 1,
          onPageChanged: (index, reason) {
            currentIndex.value = index;
          },
        ),
        items:
            images.map((imageUrl) {
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder:
                    (context, url) => Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                errorWidget:
                    (context, url, error) => Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              );
            }).toList(),
      ),
    );
  }

  /// مؤشر الصور
  Widget _buildImageIndicator(ProductModel product, RxInt currentIndex) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              product.images.asMap().entries.map((entry) {
                return Container(
                  width: currentIndex.value == entry.key ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        currentIndex.value == entry.key
                            ? Colors.black
                            : Colors.grey[300],
                  ),
                );
              }).toList(),
        ),
      );
    });
  }

  /// قسم السعر
  Widget _buildPriceSection(ProductModel product) {
    final hasDiscount = product.salePercentage > 0 && product.oldPrice != null;

    return Row(
      children: [
        // السعر الحالي
        Text(
          '${product.price.toStringAsFixed(2)} ${product.currency ?? 'USD'}',
          style: titilliumBold.copyWith(
            fontSize: 28,
            color: hasDiscount ? Colors.red : Colors.black,
          ),
        ),
        const SizedBox(width: 12),

        // السعر القديم إذا كان هناك خصم
        if (hasDiscount) ...[
          Text(
            '${product.oldPrice!.toStringAsFixed(2)} ${product.currency ?? 'USD'}',
            style: titilliumRegular.copyWith(
              fontSize: 18,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-${product.salePercentage}%',
              style: titilliumBold.copyWith(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  /// معلومات إضافية
  Widget _buildAdditionalInfo(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.category,
            'category'.tr,
            product.category?.title ?? 'N/A',
          ),
          if (product.productType != null) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.label, 'product_type'.tr, product.productType!),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            Icons.inventory_2,
            'status'.tr,
            product.isDeleted ? 'out_of_stock'.tr : 'in_stock'.tr,
          ),
        ],
      ),
    );
  }

  /// صف معلومات
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: titilliumBold.copyWith(fontSize: 14, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: titilliumRegular.copyWith(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }

  /// شريط الإضافة إلى السلة
  Widget _buildAddToCartBar(
    ProductModel product,
    CartController cartController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // التحكم بالكمية
            Obx(() {
              final quantity =
                  cartController.productQuantities[product.id]?.value ?? 0;

              if (quantity > 0) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // زر النقصان
                      IconButton(
                        onPressed: () {
                          cartController.decreaseQuantity(product);
                        },
                        icon: const Icon(Icons.remove, color: Colors.black),
                      ),
                      // الكمية
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$quantity',
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // زر الزيادة
                      IconButton(
                        onPressed: () {
                          cartController.addToCart(product);
                        },
                        icon: const Icon(Icons.add, color: Colors.black),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(width: 12),

            // زر الإضافة إلى السلة
            Expanded(
              child: Obx(() {
                final quantity =
                    cartController.productQuantities[product.id]?.value ?? 0;

                return ElevatedButton(
                  onPressed: () {
                    cartController.addToCart(product);
                    Get.snackbar(
                      'success'.tr,
                      'item_added_to_cart'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.green.shade800,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(10),
                      borderRadius: 8,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        quantity > 0 ? 'add_more'.tr : 'add_to_cart'.tr,
                        style: titilliumBold.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
