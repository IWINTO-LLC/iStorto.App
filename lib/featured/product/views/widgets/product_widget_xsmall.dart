import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

class ProductWidgetXSmall extends StatelessWidget {
  const ProductWidgetXSmall({
    super.key,
    required this.product,
    required this.vendorId,
  });
  final ProductModel product;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TProductImageSliderMini(
              editMode: false,
              product: product,
              withActions: false,
              enableShadow: true,
              prefferWidth: 33.333.w,
              prefferHeight: 33.333.w * (4 / 3),
              radius: BorderRadius.circular(15),
            ),

            // CustomCaChedNetworkImage(
            //            url: product.images![0],
            //            enableShadow: true,
            //            enableborder: true,
            //    height:33.333.w * (4 / 3) ,
            //    width: 33.333.w,
            //   fit: BoxFit.cover,
            //   raduis: BorderRadius.circular(15),
            //   ),
            Container(color: Colors.transparent, height: 10),
            Obx(
              () =>
                  TranslateController
                          .instance
                          .enableTranslateProductDetails
                          .value
                      ? FutureBuilder<String>(
                        future: TranslateController.instance.getTranslatedText(
                          text: product.title,
                          targetLangCode:
                              Localizations.localeOf(context).languageCode,
                        ),
                        builder: (context, snapshot) {
                          final displayText =
                              snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData
                                  ? snapshot.data!
                                  : product.title;
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

        // Off
      ],
    );
  }
}
