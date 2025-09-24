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

class ProductWidgetMediumFixedHeight extends StatelessWidget {
  const ProductWidgetMediumFixedHeight({
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

    return TRoundedContainer(
      // padding: const EdgeInsets.only(bottom: TSizes.paddingSizeSmall / 2),
      showBorder: true,
      radius: BorderRadius.circular(15),
      backgroundColor: TColors.lightgrey,
      enableShadow: true,
      child: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                // Product Details
                SizedBox(
                  height: 108,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 8),
                        Wrap(
                          children: [
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
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData
                                                  ? snapshot.data!
                                                  : product.title ?? "";
                                          return Text(
                                            displayText,
                                            style: titilliumBold.copyWith(
                                              fontSize: 13,
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        product.description == null ||
                                product.description!.isEmpty
                            ? const SizedBox(height: 20)
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
                        const SizedBox(height: 4),
                        const Spacer(),
                        TCustomWidgets.formattedPrice(
                          product.price,
                          16,
                          TColors.primary,
                        ),
                        const SizedBox(height: 8),
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
              bottom: 4,
              right: 4,
              child: ProductActionsMenu.buildProductActionsMenu(product),
            ),
          ),
          Visibility(
            visible: !editMode,
            child: Positioned(
              top: prefferHeight - 70,
              right: 4,
              // left: isArabicLocale() ? 4 : null,
              child: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 28.0,
                    bottom: 28,
                    left: 28,
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

          Visibility(
            visible: false,
            child: Positioned(
              top: prefferHeight - 40,
              left: 5,
              child: SavedButton(product: product),
            ),
          ),
        ],
      ),
    );
  }

  void animateToCart(BuildContext context, GlobalKey fromKey, GlobalKey toKey) {
    final fromRender = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toRender = toKey.currentContext?.findRenderObject() as RenderBox?;
    if (fromRender == null || toRender == null) return;

    final fromPosition = fromRender.localToGlobal(Offset.zero);
    final toPosition = toRender.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    late OverlayEntry entry; // تأكد من تعريفه هنا

    entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          top: fromPosition.dy,
          left: fromPosition.dx,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<Offset>(
              begin: Offset.zero,
              end: toPosition - fromPosition,
            ),
            builder: (context, Offset offset, child) {
              return Transform.translate(
                offset: offset,
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.red,
                  size: 30,
                ),
              );
            },
            onEnd: () => entry.remove(), // الآن يمكن الوصول إليه بشكل صحيح
          ),
        );
      },
    );

    overlay.insert(entry);
  }
}
