import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:line_icons/line_icons.dart';

class FavouriteButton extends StatelessWidget {
  final Color backgroundColor;
  final ProductModel product;
  final bool editMode;
  final bool withBackground;
  final double size;

  const FavouriteButton({
    super.key,
    this.backgroundColor = Colors.black,
    required this.product,
    this.withBackground = true,
    this.size = 19,
    this.editMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoriteProductsController>(
      builder: (controller) {
        return Obx(() {
          final isSaved = controller.isSaved(product.id);
          final isProcessing = controller.isProcessing(product.id);

          return GestureDetector(
            onTapDown:
                isProcessing
                    ? null // تعطيل الزر عندما تكون العملية جارية
                    : (TapDownDetails details) {
                      // حفظ موقع الضغط للأنيميشن
                      final tapPosition = details.globalPosition;

                      if (isSaved) {
                        controller.removeProduct(product);
                      } else {
                        // عرض أنيميشن القلوب المتطايرة عند الإعجاب
                        ProductActionsMenu.showFloatingHearts(
                          context,
                          tapPosition: tapPosition,
                        );
                        controller.saveProduct(product);
                      }
                    },
            child: TRoundedContainer(
              radius: BorderRadius.circular(100),
              backgroundColor:
                  withBackground ? TColors.white : Colors.transparent,
              enableShadow: withBackground ? true : false,
              child: Padding(
                padding:
                    withBackground
                        ? const EdgeInsets.only(
                          top: 5,
                          left: 6,
                          right: 6,
                          bottom: 5,
                        )
                        : const EdgeInsets.only(
                          top: 6,
                          left: 3,
                          right: 3,
                          bottom: 3,
                        ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // إذا كان المنتج قيد المعالجة، اعرض انيميشن الانتظار
                        if (isProcessing) ...[
                          // القلب الخلفي (أكبر حجماً)
                          Icon(
                            LineIcons.heart,
                            color: Colors.grey.withValues(alpha: 0.3),
                            size: withBackground ? size + 1 : size + 3,
                          ),
                          // مؤشر التحميل
                          SizedBox(
                            width: withBackground ? size - 7 : size - 1,
                            height: withBackground ? size - 7 : size - 1,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSaved ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        ] else if (isSaved) ...[
                          // إذا كان المنتج محفوظاً، اعرض القلب الأحمر
                          Icon(
                            LineIcons.heart,
                            color: Colors.red,
                            size: withBackground ? size - 5 : size,
                          ),
                        ] else ...[
                          // إذا لم يكن محفوظاً، اعرض القلب الأسود
                          Icon(
                            LineIcons.heart,
                            color: Colors.black,
                            size: withBackground ? size - 5 : size,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
