import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/empty_cart.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

/// صفحة السلة البسيطة
class SimpleCartScreen extends StatelessWidget {
  const SimpleCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());

    return Obx(() {
      print('🛒 Cart Items: ${cartController.cartItems.length}');

      // حالة التحميل
      if (cartController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // حالة فارغة
      if (cartController.cartItems.isEmpty) {
        return const EmptyCartView();
      }

      // عرض المنتجات مع الشريط السفلي
      return Stack(
        children: [
          // قائمة المنتجات
          ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 150, // مساحة للشريط السفلي
            ),
            itemCount: cartController.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartController.cartItems[index];
              return _buildCartItem(item, cartController);
            },
          ),

          // الشريط السفلي
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(cartController),
          ),
        ],
      );
    });
  }

  /// بطاقة منتج
  Widget _buildCartItem(dynamic item, CartController controller) {
    final product = item.product as ProductModel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Checkbox
            Obx(() {
              final isSelected = controller.selectedItems[product.id] ?? false;
              return Checkbox(
                value: isSelected,
                onChanged: (value) {
                  controller.selectedItems[product.id] = value ?? false;
                  controller.selectedItems.refresh();
                  controller.updateSelectedTotalPrice();
                },
                activeColor: TColors.primary,
              );
            }),

            // صورة
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image),
                    ),
              ),
            ),
            const SizedBox(width: 12),

            // معلومات المنتج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TCustomWidgets.formattedPrice(
                    product.price,
                    14,
                    TColors.primary,
                  ),
                  const SizedBox(height: 8),

                  // أزرار الكمية
                  Obx(() {
                    final quantity =
                        controller.productQuantities[product.id]?.value ??
                        item.quantity;

                    return Row(
                      children: [
                        // زر -
                        InkWell(
                          onTap: () => controller.decreaseQuantity(product),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),

                        // الكمية
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // زر +
                        InkWell(
                          onTap: () => controller.addToCart(product),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: TColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: TColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: TColors.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // زر حذف
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => controller.removeFromCart(product),
            ),
          ],
        ),
      ),
    );
  }

  /// الشريط السفلي
  Widget _buildBottomBar(CartController controller) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // تحديد الكل
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.isAllSelected,
                      onChanged:
                          (value) => controller.toggleSelectAll(value ?? false),
                      activeColor: TColors.primary,
                    ),
                  ),
                  const Text('تحديد الكل'),
                  const Spacer(),
                  Obx(() {
                    final count = controller.selectedItemsCount;
                    if (count > 0) {
                      return Text('($count محدد)');
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),

              const Divider(),

              // المجموع والدفع
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'المجموع',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Obx(
                          () => TCustomWidgets.formattedPrice(
                            controller.selectedTotalPrice,
                            18,
                            TColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final count = controller.selectedItemsCount;
                    return ElevatedButton(
                      onPressed:
                          count > 0
                              ? () {
                                Get.snackbar(
                                  'info'.tr,
                                  'جاري التحضير للدفع...',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'الدفع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
