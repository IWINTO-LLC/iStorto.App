import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';

class AddToCartWidget extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onAdd;
  final double size;
  const AddToCartWidget({
    super.key,
    required this.product,
    this.onAdd,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final quantity = cartController.productQuantities[product.id] ?? 0.obs;

    return GestureDetector(
      onTap: () => onAdd?.call(),
      child: Obx(() {
        return TRoundedContainer(
          width: size,
          height: size,
          showBorder: true,
          borderWidth: 1.5,

          borderColor: TColors.white,
          radius: BorderRadius.circular(12),
          backgroundColor:
              quantity.value > 0 ? Colors.black : Colors.grey.shade100,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                quantity.value > 0
                    ? Center(
                      key: ValueKey('count-${product.id}'),
                      child: FittedBox(
                        child: Text(
                          '${quantity.value}',
                          style: titilliumBold.copyWith(
                            fontFamily: numberFonts,
                            fontSize: (size - 5) / 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    : Icon(
                      Icons.add,
                      key: const ValueKey('add-icon'),
                      size: size - 10,
                      color: Colors.black,
                    ),
          ),
        );
      }),
    );
  }
}
