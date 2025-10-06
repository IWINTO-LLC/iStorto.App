import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/vendor_cart_block.dart';
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
    // تهيئة Controllers
    Get.lazyPut(() => VendorRepository());
    final cartController = Get.put(CartController());
    final scrollController = Get.put(CartScrollController());
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  'cart.shopList'.tr,
                  style: titilliumBold.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Obx(
                  () =>
                      (cartController.cartItems.isNotEmpty)
                          ? TCustomWidgets.formattedPrice(
                            cartController.totalPrice,
                            14,
                            Colors.black,
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),

            Expanded(
              child: Obx(() {
                // إضافة تحميل أثناء جلب البيانات
                if (cartController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  controller: scrollController.scrollController,
                  child:
                      cartController.cartItems.isEmpty
                          ? const EmptyCartView()
                          : Column(
                            children: [
                              Column(
                                children:
                                    cartController.groupedByVendor.entries.map((
                                      entry,
                                    ) {
                                      final vendorId = entry.key;
                                      final items = entry.value;

                                      // التحقق من وجود عناصر ذات كمية أكبر من الصفر
                                      final hasValidItems = items.any(
                                        (item) => item.quantity > 0,
                                      );

                                      if (!hasValidItems)
                                        return const SizedBox.shrink();

                                      return VendorCartBlock(
                                        vendorId: vendorId,
                                        items: items,
                                      );
                                    }).toList(),
                              ),
                              // const SavedItems(),
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
