import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/view/checkout_stepper_screen.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';

class ViewCartButton extends StatelessWidget {
  const ViewCartButton({super.key});

  // static final globalKeyAddButton = GlobalKey(); // هنا التعديل

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Get.to(
            () => const CheckoutStepperScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900),
          ),

      child: TRoundedContainer(
        // borderColor: Colors.black,
        // borderWidth: 2,
        width: 100,
        height: 32,
        radius: BorderRadius.circular(10),
        showBorder: true,
        backgroundColor: Colors.white,
        child: Center(
          //padding: const EdgeInsets.all(4.0),
          child: Text(
            "View Cart",
            style: titilliumBold.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
