import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/add_min_tocart.dart';
import 'package:istoreto/featured/cart/view/add_to_cart_widget.dart';
import 'package:istoreto/featured/product/data/product_model.dart';

class DynamicCartAction extends StatefulWidget {
  final ProductModel product;
  final double size;
  const DynamicCartAction({super.key, required this.product, this.size = 35});

  @override
  State<DynamicCartAction> createState() => _DynamicCartActionState();
}

class _DynamicCartActionState extends State<DynamicCartAction> {
  final CartController cartController = CartController.instance;

  @override
  void initState() {
    super.initState();

    // التهيئة الآمنة بعد أول frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.product.id;

      cartController.productQuantities.putIfAbsent(id, () => 0.obs);
      cartController.showMinus.putIfAbsent(id, () => false.obs);
      cartController.tapInsideWidget.putIfAbsent(id, () => false.obs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return TapRegion(
      onTapInside: (_) => cartController.setTapInside(product.id, true),
      onTapOutside: (_) {
        final isFocused = cartController.focusedProductId.value == product.id;
        final tappedInside = cartController.getTapInside(product.id);
        if (isFocused && !tappedInside) {
          cartController.setShowMinus(product.id, false);
          cartController.focusedProductId.value = null;
        }
      },
      child: Obx(() {
        final quantity =
            cartController.productQuantities[product.id]?.value ?? 0;
        final isFocused = cartController.focusedProductId.value == product.id;
        final show = quantity > 0 && isFocused;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child:
              show
                  ? AddMinusToCartWidget(product: product, size: widget.size)
                  : AddToCartWidget(
                    product: product,
                    size: widget.size,
                    onAdd: () {
                      cartController.addToCart(product);
                      cartController.focusOn(product.id);
                      cartController.setShowMinus(product.id, true);
                    },
                  ),
        );
      }),
    );
  }
}
