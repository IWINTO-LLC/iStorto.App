import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/vendor_cart_block.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

import 'empty_cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late ScrollController _scrollController;
  late CartController cartController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // إضافة listener للتحكم في Visibility
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.forward) {
        cartController.setCheckoutVisibility(true);
      } else {
        cartController.setCheckoutVisibility(false);
      }
    });

    // تهيئة CartController
    Get.lazyPut(() => VendorRepository());
    cartController = Get.put(CartController());
    cartController.toggleSelectAll(true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'cart.shopList'.tr,
              style: titilliumBold.copyWith(color: Colors.black, fontSize: 16),
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
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Obx(
            () => SingleChildScrollView(
              controller: _scrollController,
              child:
                  cartController.cartItems.isEmpty
                      ? const EmptyCartView() // هذا هو الـ widget اللي صممناه
                      : Column(
                        children: [
                          Column(
                            children:
                                cartController.groupedByVendor.entries.map((
                                  entry,
                                ) {
                                  final vendorId = entry.key;
                                  final items = entry.value;

                                  final allZero = items.every((item) {
                                    final quantity =
                                        cartController
                                            .productQuantities[item.product.id]
                                            ?.value ??
                                        0;
                                    return quantity == 0;
                                  });

                                  if (allZero) return const SizedBox.shrink();

                                  return VendorCartBlock(
                                    vendorId: vendorId,
                                    items: items,
                                  );
                                }).toList(),
                          ),
                          // const SavedItems(),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
