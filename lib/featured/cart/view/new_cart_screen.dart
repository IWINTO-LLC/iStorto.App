import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/cart/view/empty_cart.dart';
import 'package:istoreto/featured/cart/view/widgets/cart_shimmer.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

/// صفحة السلة الجديدة
/// New Cart Screen
class NewCartScreen extends StatelessWidget {
  const NewCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());

    return Column(
      children: [
        // AppBar كـ Row
        _buildAppBar(cartController, context),

        // Body
        Expanded(
          child: Obx(() {
            // Loading state
            if (cartController.isLoading.value) {
              return const CartShimmer();
            }

            // Empty state
            if (cartController.cartItems.isEmpty) {
              return const EmptyCartView();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 150, // مساحة للشريط السفلي
              ),
              itemCount: cartController.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return _buildCartItem(item, cartController, context);
              },
            );
          }),
        ),

        // Bottom Bar
        Obx(() {
          if (cartController.cartItems.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildCheckoutBar(cartController, context);
        }),
      ],
    );
  }

  /// AppBar كـ Row
  Widget _buildAppBar(CartController controller, BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // أيقونة السلة
            Icon(Icons.shopping_cart, size: 24, color: TColors.primary),
            const SizedBox(width: 12),

            // العنوان والعداد
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'myCart'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${controller.cartItems.length} ${'منتج'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // زر حذف الكل
            Obx(() {
              if (controller.cartItems.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showClearCartDialog(context, controller),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// بطاقة منتج في السلة
  Widget _buildCartItem(
    CartItem item,
    CartController controller,
    BuildContext context,
  ) {
    final product = item.product;

    return Obx(() {
      final quantity =
          controller.productQuantities[product.id]?.value ?? item.quantity;
      final isSelected = controller.selectedItems[product.id] ?? false;

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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // فتح تفاصيل المنتج (اختياري)
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      controller.selectedItems[product.id] = value ?? false;
                      controller.selectedItems.refresh();
                      controller.updateSelectedTotalPrice();
                    },
                    activeColor: TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // صورة المنتج
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl:
                          product.images.isNotEmpty ? product.images.first : '',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // معلومات المنتج
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المنتج
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // السعر
                        TCustomWidgets.formattedPrice(
                          product.price,
                          14,
                          TColors.primary,
                        ),
                        const SizedBox(height: 8),

                        // أزرار الكمية
                        Row(
                          children: [
                            // زر تقليل
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (quantity > 1) {
                                  controller.decreaseQuantity(product);
                                } else {
                                  _showRemoveDialog(
                                    context,
                                    product,
                                    controller,
                                  );
                                }
                              },
                              color:
                                  quantity > 1 ? TColors.primary : Colors.red,
                            ),
                            const SizedBox(width: 12),

                            // عرض الكمية
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // زر زيادة
                            _buildQuantityButton(
                              icon: Icons.add,
                              onTap: () => controller.addToCart(product),
                              color: TColors.primary,
                            ),

                            const Spacer(),

                            // زر حذف
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed:
                                  () => _showRemoveDialog(
                                    context,
                                    product,
                                    controller,
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
        ),
      );
    });
  }

  /// زر زيادة/تقليل الكمية
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  /// شريط الدفع السفلي
  Widget _buildCheckoutBar(CartController controller, BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر تحديد الكل
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.isAllSelected,
                      onChanged: (value) {
                        controller.toggleSelectAll(value ?? false);
                      },
                      activeColor: TColors.primary,
                    ),
                  ),
                  const Text(
                    'تحديد الكل',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Obx(() {
                    final selectedCount = controller.selectedItemsCount;
                    if (selectedCount > 0) {
                      return Text(
                        '($selectedCount عنصر)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const Divider(height: 16),

              // المجموع وزر الدفع
              Row(
                children: [
                  // المجموع
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'total'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => TCustomWidgets.formattedPrice(
                            controller.selectedTotalPrice,
                            20,
                            TColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // زر الدفع
                  Obx(() {
                    final selectedCount = controller.selectedItemsCount;
                    return ElevatedButton(
                      onPressed:
                          selectedCount > 0
                              ? () => _proceedToCheckout(controller, context)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'checkout'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  selectedCount > 0
                                      ? Colors.white
                                      : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color:
                                selectedCount > 0
                                    ? Colors.white
                                    : Colors.grey.shade500,
                          ),
                        ],
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

  /// حوار تأكيد الحذف
  void _showRemoveDialog(
    BuildContext context,
    ProductModel product,
    CartController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_item'.tr),
        content: Text('delete_item_confirm'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              controller.removeFromCart(product);
              Get.back();
              Get.snackbar(
                'success'.tr,
                'تم حذف المنتج من السلة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade800,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// حوار تأكيد مسح السلة
  void _showClearCartDialog(BuildContext context, CartController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل أنت متأكد من حذف جميع المنتجات من السلة؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              controller.clearCart();
              Get.back();
              Get.snackbar(
                'success'.tr,
                'تم مسح السلة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade800,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// الانتقال للدفع
  void _proceedToCheckout(CartController controller, BuildContext context) {
    final selectedItems =
        controller.cartItems
            .where((item) => controller.selectedItems[item.product.id] ?? false)
            .toList();

    if (selectedItems.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'select_product_first'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    // الانتقال لصفحة الدفع
    // TODO: استبدل بصفحة الدفع الخاصة بك
    Get.snackbar(
      'info'.tr,
      'جاري التحضير للدفع...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
    );
  }
}
