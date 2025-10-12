import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/checkout_stepper_screen.dart';
import 'package:istoreto/featured/cart/view/checkout_stepper_screen_simple.dart';
import 'package:istoreto/featured/home-page/views/widgets/cart_white.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/views/global_product_search_page.dart';
import 'package:sizer/sizer.dart';

/// ويدجت البحث في الصفحة الرئيسية
class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // التأكد من وجود CartController
    final cartController = Get.put(CartController());

    return Row(
      children: [
        // شعار التطبيق
        Container(
          width: 20.w,
          child: const Image(image: AssetImage(TImages.istortoLogo)),
        ),
        const SizedBox(width: 16),

        // أيقونة البحث - تقود إلى GlobalProductSearchPage
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(
                () => const GlobalProductSearchPage(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey.shade500),
                  const SizedBox(width: 12),
                  Text(
                    'search'.tr,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // أيقونة السلة - تقود إلى CheckoutStepperScreenSimple
        CartWhite(),
      ],
    );
  }
}
