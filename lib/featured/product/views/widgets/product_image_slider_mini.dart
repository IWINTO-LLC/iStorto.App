import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/utils/dialog/reusable_dialog.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/edit/edit_product.dart';
import 'package:istoreto/featured/product/views/widgets/favorite_widget_cards.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/dialog/reusable_dialog.dart';

class TProductImageSliderMini extends StatelessWidget {
  const TProductImageSliderMini({
    super.key,
    required this.product,
    required this.prefferHeight,
    required this.prefferWidth,
    required this.enableShadow,
    required this.editMode,
    this.withActions = true,
    this.radius,
  });
  final ProductModel product;
  final BorderRadius? radius;
  final double prefferHeight;
  final double prefferWidth;
  final bool enableShadow;
  final bool editMode;
  final bool withActions;
  @override
  Widget build(BuildContext context) {
    RxInt selectdindex = 0.obs;
    final PageController pageController = PageController(viewportFraction: 1);
    final images = product.images!;

    if (images.length > 1) {
      var items =
          images
              .map((e) => e)
              .toList()
              .map(
                (item) => CustomCaChedNetworkImage(
                  width: prefferWidth,
                  height: prefferHeight,
                  enableShadow: enableShadow,
                  url: item,
                  raduis: BorderRadius.circular(0),
                ),
              )
              .toList();
      return Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TRoundedContainer(
                //backgroundColor: Colors.yellow,
                radius: radius ?? BorderRadius.circular(15),
                showBorder: false,
                enableShadow: enableShadow,

                child: ClipRRect(
                  borderRadius: radius ?? BorderRadius.circular(15),
                  child: SizedBox(
                    height: prefferHeight,
                    width: prefferWidth,
                    child: PageView.builder(
                      onPageChanged: (index) {
                        selectdindex.value =
                            index; // تحديث المتغير عند تغيير الصفحة
                      },
                      controller: pageController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return TRoundedContainer(
                          //backgroundColor: Colors.yellow,
                          radius: radius ?? BorderRadius.circular(15),
                          //showBorder: true,
                          //enableShadow: true,
                          child: items[index],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 18,
              left: 4,
              right: 4,
              child: SizedBox(
                height: 4,
                child: Center(
                  child: ListView.separated(
                    itemCount: images.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder:
                        (_, index) => Obx(
                          () => TRoundedContainer(
                            width: index == selectdindex.value ? 8 : 4,
                            enableShadow: true,
                            radius: BorderRadius.circular(100),
                            showBorder: true,
                            //  height: .5,
                            // margin: const EdgeInsets.only(right: 2, left: 2),
                            backgroundColor:
                                index == selectdindex.value
                                    ? TColors.primary
                                    : TColors.white,
                          ),
                        ),
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(width: TSizes.spaceBtWItems / 3),
                  ),
                ),
              ),
            ),

          Visibility(
            visible: !editMode,
            child: Positioned(
              top: 2,
              right: 4,
              child: FavouriteButtonCards(product: product, size: 28),
            ),
          ),
          editCircle(context),
        ],
      );
    } else if (images.length == 1) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TRoundedContainer(
              width: prefferWidth,
              height: prefferHeight,
              showBorder: false,
              enableShadow: true,
              // borderColor: Colors.red,
              radius: radius ?? BorderRadius.circular(15),
              // enableShadow: true,
              child: CustomCaChedNetworkImage(
                width: prefferWidth,
                enableShadow: false,
                enableborder: false,
                height: prefferHeight,
                url: images.first,
                raduis: radius ?? BorderRadius.circular(15),
              ),
            ),
          ),

          Visibility(
            visible: !editMode,
            child: Positioned(
              top: 2,
              right: 4,
              child: FavouriteButtonCards(product: product, size: 28),
            ),
          ),
          if (withActions) editCircle(context),
        ],
      );
    } else {
      return TRoundedContainer(
        radius: radius ?? BorderRadius.circular(15),
        showBorder: false,
        enableShadow: enableShadow,
        child: ClipRRect(
          borderRadius: radius ?? BorderRadius.circular(15),
          child: Image(
            image: const AssetImage(TImages.imagePlaceholder),
            width: prefferWidth,
            height: prefferHeight,
          ),
        ),
      );
    }
  }

  // Visibility likeCircle() {
  //   return Visibility(
  //       visible: !editMode,
  //       child: Positioned(
  //         top: 8,
  //         right: 8,
  //         child: GestureDetector(
  //           onTap: () {
  //             if (FavoriteProductsController.instance.isSaved(product.id)) {
  //               FavoriteProductsController.instance.removeProduct(product);
  //             } else {
  //               FavoriteProductsController.instance.saveProduct(product);
  //             }
  //           },
  //           child: TRoundedContainer(
  //             width: 35,
  //             height: 35,
  //             showBorder: true,
  //             radius: BorderRadius.circular(300),
  //             backgroundColor: Colors.white.withValues(alpha: .7),
  //             child: Center(
  //               child: Obx(
  //                 () => FavoriteProductsController.instance.isSaved(product.id)
  //                     ? const Icon(CupertinoIcons.heart_fill,
  //                         color: Colors.red, size: 25)
  //                     : const Icon(CupertinoIcons.heart,
  //                         color: Colors.black, size: 25),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ));
  // }

  Visibility editCircle(BuildContext context) {
    return Visibility(
      visible: editMode,
      child: Positioned(
        top: 5,
        right: 5,
        child: Row(
          children: [
            GestureDetector(
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
              },
              child: TRoundedContainer(
                radius: BorderRadius.circular(300),
                backgroundColor: Colors.black.withValues(alpha: .7),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    TImages.editIcon,
                    color: Colors.white,
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ),
            if (withActions) const SizedBox(width: 5),
            if (withActions)
              GestureDetector(
                onTap: () {
                  ReusableAlertDialog.show(
                    context: context,
                    title: 'delete_item'.tr,
                    content: 'Adelete_item_confirm'.tr,
                    onConfirm: () async {
                      await ProductController.instance.markProductAsDeleted(
                        product,
                        product.vendorId!,
                        false,
                      );
                    },
                  );
                },
                child: TRoundedContainer(
                  radius: BorderRadius.circular(300),
                  backgroundColor: Colors.black.withValues(alpha: .7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      TImages.delete,
                      color: Colors.white,
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
