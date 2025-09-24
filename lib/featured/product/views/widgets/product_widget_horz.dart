import 'package:flutter/material.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

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
    final salePrecentage =
        controller.calculateSalePresentage(product.price, product.oldPrice) ??
        0;
    final localizedTitle = product.title ?? '';
    final localizedDescription = product.description ?? '';

    return Column(
      children: [
        Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 30.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TProductImageSliderMini(
                      editMode: false,
                      product: product,
                      enableShadow: true,
                      prefferHeight: 30.w * (4 / 3),
                      prefferWidth: 30.w,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        ProductController.getTitle(product, 16, 2, true),
                        const SizedBox(height: 8),
                        Text(
                          localizedDescription,
                          style: robotoRegular.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: TColors.darkerGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        TCustomWidgets.formattedPrice(
                          product.price,
                          18,
                          TColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment:
                              TranslationController.instance.isRTL
                                  ? Alignment.bottomLeft
                                  : Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {}, // منع انتشار الحدث للأب
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 28.0,
                                bottom: 28,
                                left: 4,
                                right: 4,
                              ),
                              child: DynamicCartAction(product: product),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 300,
                    height: 127,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TProductImageSliderMini(
                      editMode: false,
                      product: product,
                      enableShadow: true,
                      prefferHeight: 170,
                      prefferWidth: 127,
                    ),
                  ),

                  // Product Details
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 8),

                        Text(
                          localizedTitle ?? '',
                          textAlign: TextAlign.center,
                          style: titilliumBold.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Text(
                        //     isArabicLocale()
                        //         ? product.arabicDescription!
                        //         : product.description!,
                        //     textAlign: TextAlign.center,
                        //     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        //         fontSize: TSizes.fontSizeDefault,
                        //         fontWeight: FontWeight.w400),
                        //     maxLines: 3,
                        //     overflow: TextOverflow.ellipsis),
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (product.oldPrice != null)
                              TCustomWidgets.viewSalePrice(
                                product.oldPrice.toString(),
                                12,
                              ),
                            const SizedBox(height: 4),
                            TCustomWidgets.formattedPrice(
                              product.price,
                              13,
                              TColors.primary,
                            ),
                          ],
                        ),
                        // SizedBox(height: 4),
                        // Padding(
                        //     padding: const EdgeInsets.only(bottom: 0),
                        //     child: Text("تبقى منه  ${product.stock}  ",
                        //         style:
                        //             robotoRegular.copyWith(color: TColors.primary))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
