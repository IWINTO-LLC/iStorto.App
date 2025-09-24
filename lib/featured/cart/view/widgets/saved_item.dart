import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';

import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_horz.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

class SavedItems extends StatelessWidget {
  const SavedItems({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SavedController>(
      builder: (controller) {
        // فحص أن controller موجود

        return Obx(() {
          // فحص أن savedProducts موجود وغير null
          if (controller.savedProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              const SizedBox(height: 16),
              TCustomWidgets.buildDivider(),
              const SizedBox(height: 16),
              TCustomWidgets.buildTitle('you already save :'),
              ListView.separated(
                separatorBuilder:
                    (context, index) => TCustomWidgets.buildDivider(),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.savedProducts.length,
                itemBuilder: (context, index) {
                  try {
                    // فحص أن index صحيح
                    if (index < 0 || index >= controller.savedProducts.length) {
                      return const SizedBox.shrink();
                    }

                    final product = controller.savedProducts[index];

                    // فحص أن product موجود وغير null
                    if (product.id.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // إخفاء العنصر إذا كان محذوفاً
                    if (controller.isDeleted(product.id)) {
                      return const SizedBox.shrink();
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform:
                          controller.isDeleted(product.id)
                              ? Matrix4.translationValues(0, -100, 0)
                              : Matrix4.translationValues(0, 0, 0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: SizedBox(
                              child: InkWell(
                                onTap: () {
                                  try {
                                    // فحص أن product صحيح قبل الانتقال
                                    if (product.id.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          pageBuilder:
                                              (context, anim1, anim2) =>
                                                  ProductDetails(
                                                    key: UniqueKey(),
                                                    selected: index,
                                                    spotList:
                                                        controller
                                                            .savedProducts,
                                                    product: product,
                                                    vendorId: product.vendorId!,
                                                  ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // معالجة الأخطاء عند الانتقال
                                    debugPrint(
                                      'Error navigating to ProductDetails: $e',
                                    );
                                  }
                                },
                                child: ProductWidgetHorzental(
                                  product: product,
                                  vendorId: product.vendorId!,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      try {
                                        // فحص أن product صحيح قبل الحذف
                                        if (product.id.isNotEmpty) {
                                          controller.removeProduct(product);
                                        }
                                      } catch (e) {
                                        // معالجة الأخطاء عند الحذف
                                        debugPrint(
                                          'Error removing product: $e',
                                        );
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            controller.isDeleting(product.id)
                                                ? Colors.red.withValues(
                                                  alpha: 0.8,
                                                )
                                                : TColors.black.withValues(
                                                  alpha: .5,
                                                ),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child:
                                              controller.isDeleting(product.id)
                                                  ? const SizedBox(
                                                    key: ValueKey('loading'),
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : const Icon(
                                                    key: ValueKey('close'),
                                                    Icons.close_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    // معالجة الأخطاء العامة في itemBuilder
                    debugPrint('Error building saved item at index $index: $e');
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  // دالة لبناء ظل عند عدم وجود controller
}
