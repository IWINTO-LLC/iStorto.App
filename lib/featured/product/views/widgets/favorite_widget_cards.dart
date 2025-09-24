import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';

class FavouriteButtonCards extends StatelessWidget {
  final Color backgroundColor;
  final ProductModel product;
  final double size;

  const FavouriteButtonCards({
    super.key,
    this.backgroundColor = Colors.black,
    required this.product,
    this.size = 19,
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
            child: Padding(
              padding: const EdgeInsets.only(
                top: 5,
                left: 2,
                right: 2,
                bottom: 5,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isProcessing) ...[
                      Icon(
                        CupertinoIcons.heart_fill,
                        color: Colors.grey.withValues(alpha: 0.3),
                        size: size + 4,
                      ),
                      // مؤشر التحميل
                      SizedBox(
                        width: size - 2,
                        height: size - 2,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSaved ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                    ] else if (isSaved) ...[
                      // إذا كان المنتج محفوظاً، اعرض القلب الأحمر
                      Icon(
                        CupertinoIcons.heart_fill,
                        color: Colors.red,
                        size: size,
                      ),
                    ] else ...[
                      // إذا لم يكن محفوظاً، اعرض القلب الأسود مع القلب الأبيض الداخلي
                      Icon(
                        CupertinoIcons.heart_fill,
                        color: Colors.black,
                        size: size,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.white,
                          size: size - 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
