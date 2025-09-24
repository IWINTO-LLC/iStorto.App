import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/add_to_cart_button.dart';
import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

class BottomAddToCart extends StatelessWidget {
  const BottomAddToCart({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      height: 85,
      showBorder: true,
      //borderColor: TColors.primary,
      radius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 5, left: 0, right: 0),
        child: Center(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 28),

                Obx(() {
                  final quantity =
                      CartController
                          .instance
                          .productQuantities[product.id]
                          ?.value ??
                      0;
                  return quantity == 0
                      ? AddToCartButton(size: 38, product: product)
                      : DynamicCartAction(product: product, size: 38);
                }),
                Spacer(),

                Obx(() {
                  final quantity =
                      CartController
                          .instance
                          .productQuantities[product.id]
                          ?.value ??
                      0;
                  final unitPrice = product.price;
                  final totalPrice = quantity * unitPrice;

                  return quantity != 0
                      ? Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 60,
                              maxWidth: 200,
                            ),
                            child: TCustomWidgets.formattedPrice(
                              totalPrice,
                              24,
                              Colors.black,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox(width: 100);
                }),

                const SizedBox(width: 16),

                // const ViewCartButton()

                //
              ],
            ),
          ),
        ),
      ),
    );
  }
}
