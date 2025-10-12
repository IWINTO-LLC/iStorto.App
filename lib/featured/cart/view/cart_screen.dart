import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/vendor_cart_block.dart';
import 'package:istoreto/featured/cart/view/widgets/cart_shimmer.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

import 'empty_cart.dart';

/// Controller لإدارة ScrollController في CartScreen
class CartScrollController extends GetxController {
  late ScrollController scrollController;
  final CartController cartController = Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();

    // إضافة listener للتحكم في Visibility
    scrollController.addListener(() {
      final direction = scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.forward) {
        cartController.setCheckoutVisibility(true);
      } else {
        cartController.setCheckoutVisibility(false);
      }
    });

    // تأجيل تحديد الكل بعد تحميل البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.toggleSelectAll(true);
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة Controllers - استخدام Get.find مع fallback آمن
    if (!Get.isRegistered<VendorRepository>()) {
      Get.lazyPut(() => VendorRepository());
    }

    final cartController =
        Get.isRegistered<CartController>()
            ? Get.find<CartController>()
            : Get.put(CartController());

    final scrollController =
        Get.isRegistered<CartScrollController>()
            ? Get.find<CartScrollController>()
            : Get.put(CartScrollController());

    return Column(
      children: [
        // AppBar كـ Row
        _buildAppBar(cartController),

        // Body
        Expanded(
          child: Obx(() {
            // عرض Shimmer أثناء التحميل
            if (cartController.isLoading.value) {
              return const CartShimmer();
            }

            // عرض السلة الفارغة
            if (cartController.cartItems.isEmpty) {
              return const EmptyCartView();
            }

            // الحصول على العناصر المجمعة حسب البائع
            final groupedItems = cartController.groupedByVendor;

            debugPrint(
              '📦 Cart Items Count: ${cartController.cartItems.length}',
            );
            debugPrint('🏪 Vendors Count: ${groupedItems.length}');
            groupedItems.forEach((vendorId, items) {
              debugPrint('   Vendor $vendorId: ${items.length} items');
            });

            // التحقق من وجود عناصر مجمعة
            if (groupedItems.isEmpty) {
              return const EmptyCartView();
            }

            return SingleChildScrollView(
              controller: scrollController.scrollController,
              padding: const EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
                bottom: 150, // مساحة للشريط السفلي
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان "منتجات حسب المتاجر"
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      Get.locale?.languageCode == 'ar'
                          ? 'منتجات حسب المتاجر'
                          : 'Products by Vendors',
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // عرض كل بائع مع منتجاته
                  ...groupedItems.entries.map((entry) {
                    final vendorId = entry.key;
                    final items = entry.value;

                    // التحقق من وجود عناصر ذات كمية أكبر من الصفر
                    final hasValidItems = items.any(
                      (item) => item.quantity > 0,
                    );

                    if (!hasValidItems) {
                      debugPrint('⚠️ No valid items for vendor $vendorId');
                      return const SizedBox.shrink();
                    }

                    debugPrint(
                      '✅ Rendering VendorCartBlock for $vendorId with ${items.length} items',
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: VendorCartBlock(vendorId: vendorId, items: items),
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ),

        // Bottom Bar
        Obx(() {
          if (cartController.cartItems.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildBottomBar(cartController);
        }),
      ],
    );
  }

  /// AppBar كـ Row
  Widget _buildAppBar(CartController cartController) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'cart.shopList'.tr,
                    style: titilliumBold.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(
                    () =>
                        (cartController.cartItems.isNotEmpty)
                            ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: TCustomWidgets.formattedPrice(
                                cartController.totalPrice,
                                12,
                                Colors.grey.shade600,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Bar
  Widget _buildBottomBar(CartController cartController) {
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
                      value: cartController.isAllSelected,
                      onChanged:
                          (value) =>
                              cartController.toggleSelectAll(value ?? false),
                      activeColor: const Color(0xFF1E88E5),
                    ),
                  ),
                  Text(
                    'select_all'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final count = cartController.selectedItemsCount;
                    if (count > 0) {
                      return Text(
                        '($count ${'selected'.tr})',
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

              const Divider(),

              // المجموع والدفع
              Row(
                children: [
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
                            cartController.selectedTotalPrice,
                            18,
                            const Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() {
                    final count = cartController.selectedItemsCount;
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
                        backgroundColor: const Color(0xFF1E88E5),
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
                                  count > 0
                                      ? Colors.white
                                      : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color:
                                count > 0 ? Colors.white : Colors.grey.shade500,
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
}
