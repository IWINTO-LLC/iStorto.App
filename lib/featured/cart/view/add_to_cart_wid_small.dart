import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/constant.dart';

class AddToCartWidgetSmall extends StatelessWidget {
  const AddToCartWidgetSmall({super.key, required this.product});

  final ProductModel product;
  // static final globalKeyAddButton = GlobalKey(); // هنا التعديل

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;

    return Obx(() {
      // الحصول على الكمية الفعلية
      final quantity = cartController.productQuantities[product.id]?.value ?? 0;

      return GestureDetector(
        onTap: () {
          // إضافة المنتج للسلة
          cartController.addToCart(product);
        },
        child: TRoundedContainer(
          width: 35,
          height: 35,
          radius: cartRadius,
          showBorder: true,
          borderWidth: 1.5,
          borderColor: Colors.white,
          enableShadow: true,
          backgroundColor: Colors.black,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child:
                quantity > 0
                    ? Center(
                      key: ValueKey('count-${product.id}'),
                      child: Text(
                        '$quantity',
                        style: titilliumBold.copyWith(
                          fontFamily: numberFonts,
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : const Icon(
                      Icons.add,
                      key: ValueKey('add-icon'),
                      size: 20,
                      color: Colors.white,
                    ),
          ),
        ),
      );
    });
  }
}
