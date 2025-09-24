import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/featured/product/views/widgets/saved_widget.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/controllers/translate_controller.dart';

class ProductWidgetMedium extends StatelessWidget {
  const ProductWidgetMedium({
    super.key,
    required this.product,
    required this.vendorId,
    required this.editMode,
    required this.prefferHeight,
    required this.prefferWidth,
  });
  final ProductModel product;
  final double prefferHeight;
  final double prefferWidth;
  final bool editMode;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePrecentage = controller.calculateSalePresentage(
      product.price,
      product.oldPrice,
    );
    final localizedTitle = product.title ?? '';
    final localizedDescription = product.description ?? '';

    return TRoundedContainer(
      // padding: const EdgeInsets.only(bottom: TSizes.paddingSizeSmall / 2),
      showBorder: true,
      enableShadow: true,
      radius: BorderRadius.circular(15),
      backgroundColor: TColors.lightgrey,
      child: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: "cart_${product.id}",
                  child: TProductImageSliderMini(
                    editMode: editMode,
                    product: product,
                    enableShadow: true,
                    radius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    prefferHeight: prefferHeight,
                    prefferWidth: prefferWidth + 3,
                    // prefferWidth: 174,
                  ),
                ),
                SizedBox(
                  //  height: 110,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 2),
                        Obx(
                          () =>
                              TranslateController
                                      .instance
                                      .enableTranslateProductDetails
                                      .value
                                  ? FutureBuilder<String>(
                                    future: TranslateController.instance
                                        .getTranslatedText(
                                          text: product.title ?? "",
                                          targetLangCode:
                                              Localizations.localeOf(
                                                context,
                                              ).languageCode,
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
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  )
                                  : Text(
                                    product.title ?? "",
                                    style: titilliumBold.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                        ),
                        const SizedBox(height: 4),

                        (product.description == null ||
                                product.description!.isEmpty)
                            ? const SizedBox.shrink()
                            : Obx(
                              () =>
                                  TranslateController
                                          .instance
                                          .enableTranslateProductDetails
                                          .value
                                      ? FutureBuilder<String>(
                                        future: TranslateController.instance
                                            .getTranslatedText(
                                              text: product.description ?? "",
                                              targetLangCode:
                                                  Localizations.localeOf(
                                                    context,
                                                  ).languageCode,
                                            ),
                                        builder: (context, snapshot) {
                                          final displayText =
                                              snapshot.connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData
                                                  ? snapshot.data!
                                                  : product.description ?? "";
                                          return Text(
                                            displayText,
                                            style: robotoRegular.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: TColors.darkerGray,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      )
                                      : Text(
                                        product.description ?? "",
                                        style: robotoRegular.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: TColors.darkerGray,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                            ),
                        (localizedDescription == "")
                            ? const SizedBox.shrink()
                            : const SizedBox(height: 4),
                        // const Spacer(),
                        SizedBox(
                          width: prefferHeight - 50,
                          child: Wrap(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TCustomWidgets.formattedPrice(
                                product.price,
                                16,
                                TColors.primary,
                              ),
                              // AddToCartWidget(product: product)
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Visibility(
            visible: !editMode,
            child: Positioned(
              bottom: 0,
              right: 6,
              child: ProductActionsMenu.buildProductActionsMenu(product),
            ),
          ),

          Visibility(
            visible: !editMode,
            child: Positioned(
              top: prefferHeight - 68,
              right: 0,
              //left: isArabicLocale() ? 4 : null,
              child: GestureDetector(
                onTap: () {}, // منع انتشار الحدث للأب
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 28.0,
                    bottom: 28,
                    left: 24,
                    right: 4,
                  ),
                  child: DynamicCartAction(product: product),
                ),
              ),
            ),
          ),
          if (salePrecentage != null && salePrecentage != '0')
            Positioned(
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
                    bottomRight: Radius.circular(TSizes.paddingSizeExtraSmall),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$salePrecentage %',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Colors.white,
                      fontSize: TSizes.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
