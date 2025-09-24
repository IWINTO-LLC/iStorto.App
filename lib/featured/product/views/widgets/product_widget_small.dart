import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/cart/view/add_to_cart_wid_small.dart';
import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/favorite_widget.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/featured/product/views/widgets/saved_widget.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class ProductWidgetSmall extends StatelessWidget {
  const ProductWidgetSmall({
    super.key,
    required this.product,
    required this.vendorId,
  });
  final ProductModel product;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    //var oldPrice = product.oldPrice ?? 0;
    final salePrecentage =
        controller.calculateSalePresentage(product.price, product.oldPrice) ??
        0;
    // String ratting =
    //     product.rating != null && product.rating!.isNotEmpty
    //         ? product.rating![0].average!
    //         : "0";

    var prefferHeight = 33.333.w * (4 / 3);
    final langCode = Localizations.localeOf(context).languageCode;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TProductImageSliderMini(
              editMode: false,
              product: product,
              enableShadow: true,
              prefferWidth: 33.333.w,
              prefferHeight: 33.333.w * (4 / 3),
              radius: BorderRadius.circular(15),
            ),

            Container(color: Colors.transparent, height: 10),
            Obx(
              () =>
                  TranslateController
                          .instance
                          .enableTranslateProductDetails
                          .value
                      ? FutureBuilder<String>(
                        future: TranslateController.instance.getTranslatedText(
                          text: product.title ?? "",
                          targetLangCode:
                              Localizations.localeOf(context).languageCode,
                        ),
                        builder: (context, snapshot) {
                          final displayText =
                              snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData
                                  ? snapshot.data!
                                  : product.title ?? "";
                          return Text(
                            displayText,
                            style: titilliumBold.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      )
                      : Text(
                        product.title,
                        style: titilliumBold.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
            ),
            const SizedBox(height: 6),
            TCustomWidgets.formattedPrice(product.price, 15, TColors.primary),
            // Product Details
          ],
        ),

        Visibility(
          visible: true,
          child: Positioned(
            top: prefferHeight - 70,
            right: 2,
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(top: 28.0, bottom: 28, right: 4),
                child: AddToCartWidgetSmall(product: product),
              ),
            ),
          ),
        ),

        // Off
        if (salePrecentage != 0)
          Visibility(
            visible: salePrecentage.toString() != 0.toString(),
            child: Positioned(
              top: 20,
              left: 0,
              child: Container(
                height: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.paddingSizeExtraSmall,
                ),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(TSizes.paddingSizeExtraSmall),
                    // topLeft: Radius.circular(TSizes.paddingSizeExtraSmall),
                    bottomRight: Radius.circular(TSizes.paddingSizeExtraSmall),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$salePrecentage %',
                    // PriceConverter.percentageCalculation(
                    //     context,
                    //     product.unitPrice,
                    //     product.discount,
                    //     product.discountType),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Colors.white,
                      fontSize: TSizes.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
