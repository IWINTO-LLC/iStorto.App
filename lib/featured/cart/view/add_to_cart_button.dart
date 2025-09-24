import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/cart_screen.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/constant.dart';

// ignore: must_be_immutable
class AddToCartButton extends StatelessWidget {
  AddToCartButton({super.key, this.size = 35, required this.product});

  final ProductModel product;
  // static final globalKeyAddButton = GlobalKey(); // هنا التعديل
  double size;
  @override
  Widget build(BuildContext context) {
    var quantity = 0;
    // final GlobalKey globalKeyAddButton =
    //     GlobalKey(debugLabel: 'add_${product.id}');
    // final GlobalKey globalKeyAddButton = GlobalKey();
    // final GlobalKey globalKeyAddButton = GlobalKey();
    var cartController = CartController.instance;
    Future.microtask(() {
      cartController.getProductQuantity(product.id);
    });

    return GestureDetector(
      onTap: () {
        if (quantity > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartScreen()),
          );
        } else {
          cartController.addToCart(product);
        }
      },
      child: Obx(() {
        quantity = cartController.productQuantities[product.id]?.value ?? 0;
        return TRoundedContainer(
          borderColor: Colors.black,
          borderWidth: 2,
          width: (size * 4) - 5,
          height: size,
          radius: cartRadius,
          showBorder: true,
          backgroundColor: Colors.black,
          child: Center(
            //padding: const EdgeInsets.all(4.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                quantity > 0 ? "cart.view_cart".tr : "cart.add_to_cart".tr,
                style: titilliumBold.copyWith(
                  fontSize: size - 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
