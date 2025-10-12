import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/checkout_stepper_screen.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class CartWhite extends StatelessWidget {
  const CartWhite({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    return GestureDetector(
      onTap: () {
        Get.to(
          () => const CheckoutStepperScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Obx(() {
        final itemCount = cartController.cartItems.length;

        return TRoundedContainer(
          height: 40,
          width: 40,
          showBorder: true,
          radius: BorderRadius.circular(10),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              // Badge عدد المنتجات
              if (itemCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        itemCount > 99 ? '99+' : '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
