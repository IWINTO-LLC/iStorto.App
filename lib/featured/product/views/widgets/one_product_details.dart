import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/home-page/views/widgets/cart_white.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/favorite_widget.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_details.dart';
import 'package:istoreto/featured/product/views/widgets/saved_widget.dart';
import 'package:istoreto/featured/product/views/widgets/share_product_widget.dart';
import 'package:istoreto/featured/shop/view/widgets/category_product_grid.dart';
import 'package:istoreto/featured/shop/view/widgets/control_panel_menu_black_product.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_profile.dart';
import 'package:istoreto/featured/product/views/widgets/product_rating_section.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.edit,
    required this.vendorId,
  });

  final ProductModel product;
  final bool edit;
  final String vendorId;

  @override
  Widget build(BuildContext context) {
    if (product.id.isEmpty) {
      return const Center(child: Text("⚠️ المنتج غير متوفر"));
    }

    //final GlobalKey globalKeyAddButton = GlobalKey();
    final salePrecentage =
        ProductController.instance.calculateSalePresentage(
          product.price,
          product.oldPrice,
        ) ??
        0;
    final oldPrice = product.oldPrice;
    // final langCode = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      //  physics: const BouncingScrollPhysics(),
      child: AnimatedOpacity(
        duration: const Duration(microseconds: 500),
        opacity: 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                TProductImageSliderDetails(
                  product: product,
                  prefferHeight: 100.w * (4 / 3),
                  prefferWidth: 100.w,
                  radius: BorderRadius.circular(0),
                ),
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CartWhite(),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TRoundedContainer(
                      width: 35,
                      height: 35,
                      showBorder: true,
                      backgroundColor: Colors.black,
                      //  enableShadow: true,
                      radius: BorderRadius.circular(100),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    Visibility(
                      visible: edit,
                      child: ControlPanelBlackProduct(
                        withCircle: false,
                        editMode: edit,
                        iconColor: Colors.black,
                        vendorId: vendorId,
                        product: product,
                      ),
                    ),
                    Visibility(visible: !edit, child: const SizedBox(width: 4)),
                    Visibility(
                      visible: !edit,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          left: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        child: Obx(
                          () => GestureDetector(
                            onTap:
                                () =>
                                    TranslateController
                                        .instance
                                        .enableTranslateProductDetails
                                        .value = !TranslateController
                                            .instance
                                            .enableTranslateProductDetails
                                            .value,
                            child: Icon(
                              Icons.translate,
                              color:
                                  TranslateController
                                          .instance
                                          .enableTranslateProductDetails
                                          .value
                                      ? TColors.primary
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FavouriteButton(
                      withBackground: false,
                      editMode: true,
                      product: product,
                      size: 25,
                    ),
                    const SizedBox(width: 12),
                    SavedButton(
                      size: 24,
                      // withBackground:false,
                      product: product,
                    ),
                    const SizedBox(width: 12),
                    ShareButton(
                      size: 22,
                      // withBackground:false,
                      product: product,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: FittedBox(
                    child: TCustomWidgets.formattedPrice(
                      product.price,
                      product.price > 999999999999 ? 18 : 20,
                      TColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //  const SizedBox(width: 20),
                  if (salePrecentage != 0)
                    Visibility(
                      visible: salePrecentage.toString() != 0.toString(),
                      child: Text(
                        '$salePrecentage %',
                        style: titilliumSemiBold.copyWith(
                          color: Colors.black,
                          fontFamily: numberFonts,
                          fontSize: TSizes.fontSizeDefault,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (oldPrice != null && oldPrice > product.price)
                    TCustomWidgets.viewSalePrice(
                      oldPrice.toString(),
                      TSizes.fontSizeDefault + 1,
                    ),
                  // const SizedBox(width: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80.w,
                    child: Obx(
                      () =>
                          TranslateController
                                  .instance
                                  .enableTranslateProductDetails
                                  .value
                              ? FutureBuilder<String>(
                                future: TranslateController.instance
                                    .getTranslatedText(
                                      text: product.title,
                                      targetLangCode:
                                          TranslationController
                                              .instance
                                              .currentLocale
                                              .languageCode,
                                    ),
                                builder: (context, snapshot) {
                                  final displayText =
                                      snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.hasData
                                          ? snapshot.data!
                                          : product.title;
                                  return ReadMoreText(
                                    displayText,
                                    trimLines: 2,
                                    style: titilliumBold.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'more'.tr,
                                    trimExpandedText: 'less'.tr,
                                    moreStyle: robotoHintRegular.copyWith(
                                      color: TColors.primary,
                                      fontSize: 14,
                                    ),
                                    lessStyle: robotoHintRegular.copyWith(
                                      color: TColors.primary,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              )
                              : ReadMoreText(
                                product.title,
                                trimLines: 2,
                                style: titilliumBold.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'more'.tr,
                                trimExpandedText: 'less'.tr,
                                moreStyle: robotoHintRegular.copyWith(
                                  color: TColors.primary,
                                  fontSize: 14,
                                ),
                                lessStyle: robotoHintRegular.copyWith(
                                  color: TColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),

            //  const SizedBox(height: TSizes.spaceBtwInputFields / 2),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Obx(
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
                                    TranslationController
                                        .instance
                                        .currentLocale
                                        .languageCode,
                              ),
                          builder: (context, snapshot) {
                            final displayText =
                                snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData
                                    ? snapshot.data!
                                    : product.description ?? "";
                            return ReadMoreText(
                              displayText,
                              trimLines: 2,
                              style: titilliumBold.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'more'.tr,
                              trimExpandedText: 'less'.tr,
                              moreStyle: robotoHintRegular.copyWith(
                                color: TColors.primary,
                                fontSize: 14,
                              ),
                              lessStyle: robotoHintRegular.copyWith(
                                color: TColors.primary,
                                fontSize: 14,
                              ),
                            );
                          },
                        )
                        : ReadMoreText(
                          product.description ?? "",
                          trimLines: 2,
                          style: titilliumBold.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'more'.tr,
                          trimExpandedText: 'less'.tr,
                          moreStyle: robotoHintRegular.copyWith(
                            color: TColors.primary,
                            fontSize: 14,
                          ),
                          lessStyle: robotoHintRegular.copyWith(
                            color: TColors.primary,
                            fontSize: 14,
                          ),
                        ),
              ),
            ),

            //  const SizedBox(height: 32),

            // Padding(
            //     padding: const EdgeInsets.only(bottom: 0),
            //     child: Text("تبقى منه  ${product.stock}  ",
            //         style: robotoMedium.copyWith(
            //             color: TColors.primary))),
            const SizedBox(height: TSizes.spaceBtWsections),

            Padding(
              padding: const EdgeInsets.all(6.0),
              child: VendorProfilePreview(
                vendorId: vendorId,
                color: TColors.primary,
                withunderLink: false,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtWsections),

            // Product Rating Section
            ProductRatingSection(product: product),

            const SizedBox(height: TSizes.spaceBtWsections),

            // const SizedBox(
            //   height: TSizes.spaceBtWsections * 2,
            // ),//14 pexel
            // TCustomWidgets.buildTitle(
            //     isArabicLocale() ? 'ربما يعجبك هذا' : 'More From This Shop'),
            TCategoryProductGrid(
              product: product,
              editMode: edit,
              userId: vendorId,
            ),
            // ProductTableGrid(vendorId: vendorId),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // : const ProductDetailsShimmer(),
    );
  }
}
