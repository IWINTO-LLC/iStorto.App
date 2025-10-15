import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/checkout_stepper_screen.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CartController>()) {
      return GestureDetector(
        onTap:
            () => Get.to(
              () => CheckoutStepperScreen(),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 900),
            ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TRoundedContainer(
            width: 35,
            height: 35,
            backgroundColor: Colors.black.withValues(alpha: .9),
            radius: BorderRadius.circular(100),
            child: const Icon(
              CupertinoIcons.shopping_cart,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap:
          () => Get.to(
            () => CheckoutStepperScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900),
          ),
      child: Stack(
        //   key: CartController.instance.globalKeyCartIcon,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TRoundedContainer(
              width: 35,
              //   enableShadow: true,
              height: 35,
              backgroundColor: Colors.black.withValues(alpha: .9),
              radius: BorderRadius.circular(100),
              child: const Icon(
                CupertinoIcons.shopping_cart,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Obx(
            () =>
                CartController.instance.total > 0
                    ? Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${CartController.instance.total}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
