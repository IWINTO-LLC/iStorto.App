import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/utils/dialog/reusable_dialog.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/edit/edit_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TProductItem extends StatelessWidget {
  TProductItem({super.key, required this.product});
  final ProductModel product;

  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false.obs;
  var mini = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection =
      TranslationController.instance.isRTL
          ? SpeedDialDirection.right
          : SpeedDialDirection.left;
  var buttonSize = const Size(35.0, 35.0);
  var childrenButtonSize = const Size(45.0, 45.0);

  @override
  Widget build(BuildContext context) {
    final localizedDescription = product.description;
    return Stack(
      children: [
        Container(
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(10),
          //   border: Border.all(color: TColors.black),
          // ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TProductImageSliderMini(
                editMode: false,
                prefferHeight: 200,
                prefferWidth: 150,
                enableShadow: true,
                product: product,
                radius: BorderRadius.circular(15),
              ),

              // CustomCaChedNetworkImage(
              //     width: 150,
              //     height: 200,
              //     url: product.images!.first,
              //     raduis: BorderRadius.circular(15))
              // // TRoundedImage(
              //   imageUrl: product.images!.first,
              //   width: 150,
              //   height: 200,
              //   imageType: ImageType.network,
              //   fit: BoxFit.cover,
              //   borderRaduis: BorderRadius.circular(15),
              // ),
              const SizedBox(width: TSizes.sm),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductController.getTitle(product, 13, 2, true),
                    const SizedBox(height: 6),
                    Text(
                      localizedDescription ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumNormal,
                    ),
                    const SizedBox(height: 10),
                    TCustomWidgets.formattedPrice(
                      product.price,
                      16,
                      Colors.black,
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Align(
            alignment:
                TranslationController.instance.isRTL
                    ? Alignment.topLeft
                    : Alignment.topRight,
            child: SpeedDial(
              overlayOpacity: 0,
              icon: Icons.more_vert,
              iconTheme: const IconThemeData(size: 30),
              activeIcon: Icons.close,
              spacing: 0,
              mini: mini,
              openCloseDial: isDialOpen,
              childPadding: const EdgeInsets.all(3),
              spaceBetweenChildren: 0,
              buttonSize: buttonSize,
              childrenButtonSize: childrenButtonSize,
              visible: visible,
              direction: speedDialDirection,
              switchLabelPosition: switchLabelPosition,
              closeManually: false,
              renderOverlay: renderOverlay,
              useRotationAnimation: useRAnimation,
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Colors.black,
              elevation: 0,
              animationCurve: Curves.elasticInOut,
              isOpenOnStart: false,
              // shape: customDialRoot
              //     ? const RoundedRectangleBorder()
              //     : const StadiumBorder(),
              onOpen: () {
                extend.value = true;
              },
              onClose: () {
                extend.value = false;
              },
              children: [
                SpeedDialChild(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(TImages.editIcon, color: Colors.black),
                  ),
                  onTap: () {
                    EditProductController.instance.init(product);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditProduct(
                              product: product,
                              vendorId: product.vendorId!,
                            ),
                      ),
                    );
                  }, //EditProduct
                ),
                // SpeedDialChild(
                //     elevation: 0,
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Image.asset(
                //         TImages.imagePlaceholder,
                //         color: TColors.black,
                //       ),
                //     ),
                //     onTap: () =>
                //         ProductController.instance.updateProductImage(context)),
                SpeedDialChild(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(TImages.delete, color: Colors.black),
                  ),
                  onTap: () async {
                    ReusableAlertDialog.show(
                      context: context,
                      title: 'deleteItem'.tr,
                      content: 'delete_item_confirm'.tr,

                      onConfirm: () async {
                        ProductController.instance.markProductAsDeleted(
                          product,
                          product.vendorId!,
                          false,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
