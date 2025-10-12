import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

class ProductWidgetHorzental extends StatelessWidget {
  const ProductWidgetHorzental({
    super.key,
    required this.product,
    required this.vendorId,
  });
  final ProductModel product;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePrecentageStr = controller.calculateSalePresentage(
      product.price,
      product.oldPrice,
    );
    final salePrecentage =
        salePrecentageStr != null ? double.tryParse(salePrecentageStr) ?? 0 : 0;
    final localizedDescription = product.description ?? '';

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // يمكن إضافة navigation لصفحة التفاصيل هنا
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة المنتج مع badge الخصم
                    Stack(
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w * (4 / 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: TProductImageSliderMini(
                              editMode: false,
                              product: product,
                              enableShadow: false,
                              prefferHeight: 28.w * (4 / 3),
                              prefferWidth: 28.w,
                            ),
                          ),
                        ),
                        // Badge الخصم
                        if (salePrecentage > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-${salePrecentage.toInt()}%',
                                style: titilliumBold.copyWith(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // تفاصيل المنتج
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // العنوان
                          ProductController.getTitle(product, 15, 2, true),
                          const SizedBox(height: 6),

                          // الوصف
                          if (localizedDescription.isNotEmpty)
                            Text(
                              localizedDescription,
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),

                          // السعر وزر السلة
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // السعر
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // السعر بعد الخصم
                                    TCustomWidgets.formattedPrice(
                                      product.price,
                                      18,
                                      Colors.black,
                                    ),
                                    // السعر القديم (إذا كان هناك خصم)
                                    if (product.oldPrice != null &&
                                        salePrecentage > 0)
                                      TCustomWidgets.viewSalePrice(
                                        product.oldPrice.toString(),
                                        12,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // زر السلة
                              GestureDetector(
                                onTap: () {}, // منع انتشار الحدث للأب
                                child: DynamicCartAction(product: product),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
