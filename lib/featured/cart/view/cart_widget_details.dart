import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/checkout_stepper_screen.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class CartWidgetDetails extends StatelessWidget {
  const CartWidgetDetails({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.black;
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
            child: Center(
              child: TRoundedContainer(
                width: 80.w,
                //   enableShadow: true,
                height: 15.w,
                showBorder: true,
                //  backgroundColor: Colors.black.withValues(alpha: .5),
                radius: BorderRadius.circular(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        //  width: 50,
                        child: Stack(
                          children: [
                            TRoundedContainer(
                              width: 30,
                              height: 30,
                              child: FreeCaChedNetworkImage(
                                url:
                                    CartController
                                        .instance
                                        .cartItems
                                        .first
                                        .product
                                        .images
                                        .first,
                                raduis: BorderRadius.circular(50),
                              ),
                            ),
                            // if (CartController.instance.total > 2)
                            //   Positioned(
                            //     right: isRtl ? 5 : null,
                            //     left: isRtl ? null : 5,
                            //     child: TRoundedContainer(
                            //       width: 30,
                            //       height: 30,
                            //       child: FreeCaChedNetworkImage(
                            //           url: CartController
                            //               .instance
                            //               .cartItems[2]
                            //               .product
                            //               .images!
                            //               .first,
                            //           raduis: BorderRadius.circular(50)),
                            //     ),
                            // ),
                            // if (CartController.instance.total > 1)
                            //   Positioned(
                            //     left: isRtl ? 3 : null,
                            //     right: isRtl ? null : 3,
                            //     child: TRoundedContainer(
                            //       width: 30,
                            //       height: 30,
                            //       child: FreeCaChedNetworkImage(
                            //           url: CartController
                            //               .instance
                            //               .cartItems[1]
                            //               .product
                            //               .images!
                            //               .first,
                            //           raduis: BorderRadius.circular(50)),
                            //     ),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Obx(
                      () =>
                          CartController.instance.total > 0
                              ? Text(
                                "${CartController.instance.total} ",
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                ),
                              )
                              : SizedBox.shrink(),
                    ),
                    const Icon(
                      CupertinoIcons.bag,
                      size: 20,
                      color: TColors.primary,
                    ),
                    SizedBox(width: 16),
                    Obx(
                      () =>
                          (CartController.instance.cartItems.isNotEmpty)
                              ? TCustomWidgets.formattedPrice(
                                CartController.instance.totalPrice,
                                16,
                                textColor,
                              )
                              : const SizedBox.shrink(),
                    ),
                    //
                    // Text("View Cart"),
                    Spacer(),
                    const Icon(
                      CupertinoIcons.shopping_cart,
                      color: textColor,
                      size: 30,
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
