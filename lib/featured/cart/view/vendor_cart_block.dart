import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/cart/view/widgets/cart_menu_item.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_profile.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

/// عرض منتجات السلة لتاجر واحد
class VendorCartBlock extends StatelessWidget {
  final String vendorId;
  final List<CartItem> items;
  final VoidCallback? onCheckout;

  const VendorCartBlock({
    super.key,
    required this.vendorId,
    required this.items,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    print(
      '🎨 Building VendorCartBlock for $vendorId with ${items.length} items',
    );

    // التحقق من وجود منتجات صالحة
    if (items.isEmpty) {
      print('⚠️ No items for vendor $vendorId');
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات التاجر
            VendorProfilePreview(
              vendorId: vendorId,
              color: Colors.black,
              withunderLink: false,
              withPadding: false,
            ),

            const Divider(height: 24),

            // المنتجات
            ...items.map((item) => CartMenuItem(item: item)),

            const Divider(height: 32),

            // الإجمالي وزر Checkout
            Obx(() {
              final cartController = CartController.instance;

              // حساب المجموع والعدد للمنتجات المحددة فقط من هذا التاجر
              double vendorTotal = 0;
              int selectedCount = 0;

              for (var item in items) {
                if (cartController.selectedItems[item.product.id] == true) {
                  vendorTotal += item.totalPrice;
                  selectedCount++;
                }
              }

              // إذا لم يتم اختيار أي منتج من هذا التاجر
              if (selectedCount == 0) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // المجموع
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // SizedBox(
                        //   width: 100,
                        //   height: 50,
                        //   child: ElevatedButton(
                        //     onPressed: () {},
                        //     child: Text("ddd"),
                        //   ),
                        // ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TCustomWidgets.formattedPrice(
                              vendorTotal,
                              18,
                              TColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($selectedCount ${'products'.tr})',
                              style: titilliumRegular.copyWith(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // زر Checkout
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _checkoutVendor(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.shopping_cart_checkout,
                          size: 18,
                        ),
                        label: Text(
                          'checkout'.tr,
                          style: titilliumBold.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// إتمام الطلب لهذا التاجر فقط
  void _checkoutVendor(BuildContext context) {
    final cartController = CartController.instance;

    // التحقق من وجود منتجات محددة من هذا التاجر
    final selectedItems =
        items
            .where(
              (item) => cartController.selectedItems[item.product.id] == true,
            )
            .toList();

    if (selectedItems.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'الرجاء اختيار منتج واحد على الأقل من هذا المتجر',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // استدعاء callback من الـ parent
    if (onCheckout != null) {
      onCheckout!();
    } else {
      // fallback إذا لم يتم تمرير callback
      Get.snackbar(
        'جاري المعالجة',
        'سيتم إتمام الطلب لـ ${selectedItems.length} منتج من هذا المتجر',
        backgroundColor: TColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
