import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';

import 'package:istoreto/controllers/edit_category_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/dialog/confirmation_dialog.dart';

import '../../edit_category/edit_category.dart';

class TCategoryListItem extends StatelessWidget {
  TCategoryListItem({super.key, required this.category});
  final CategoryModel category;

  final renderOverlay = true;
  final visible = true;
  final switchLabelPosition = false;
  final extend = false.obs;
  final mini = false;
  final customDialRoot = false;
  final closeManually = false;
  final useRAnimation = true;
  final isDialOpen = ValueNotifier<bool>(false);
  final speedDialDirection =
      TranslationController.instance.isRTL
          ? SpeedDialDirection.right
          : SpeedDialDirection.left;
  final buttonSize = const Size(35.0, 35.0);
  final childrenButtonSize = const Size(45.0, 45.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TRoundedContainer(
          // enableShadow: true,
          // showBorder: true,
          radius: BorderRadius.circular(10),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.grey),
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: category.icon!,
                    imageBuilder:
                        (context, imageProvider) => GestureDetector(
                          onTap: () {},
                          //  Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => AllProducts(
                          //               title: Get.locale?.languageCode == 'en'
                          //                   ? category.name
                          //                   : category.arabicName,
                          //               categoryId: category.id,
                          //               editMode: true,
                          //               userId: userId,
                          //               futureMethode: CategoryController
                          //                   .instance
                          //                   .getCategoryProduct(
                          //                       categoryId: category.id!,
                          //                       userId: FirebaseAuth
                          //                           .instance.currentUser!.uid,
                          //                       limit: -1),
                          //             ))),
                          child: Container(
                            // width: 80,
                            // height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(image: imageProvider),
                            ),
                          ),
                        ),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => ClipRRect(
                          //  borderRadius: BorderRadius.circular(0),
                          child: TShimmerEffect(
                            raduis: BorderRadius.circular(100),
                            width: 80,
                            height: 80,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.error, size: 50),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.sm),
              Expanded(
                flex: 4,
                child: Container(
                  // color: TColors.light,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                category.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(fontFamily: 'Tajawal-Medium'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [SizedBox(width: 120)],
                          ),
                        ],
                      ),
                    ],
                  ),
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
              spaceBetweenChildren: 4,
              buttonSize: buttonSize,
              childrenButtonSize: childrenButtonSize,
              visible: visible,
              direction: speedDialDirection,
              switchLabelPosition: switchLabelPosition,
              closeManually: false,
              renderOverlay: renderOverlay,
              useRotationAnimation: useRAnimation,
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: TColors.black,
              elevation: 0,
              animationCurve: Curves.elasticInOut,
              isOpenOnStart: false,
              shape:
                  customDialRoot
                      ? const RoundedRectangleBorder()
                      : const StadiumBorder(),
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
                    child: Icon(Icons.edit, color: TColors.black),
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditCategory(category: category),
                        ),
                      ), //EditCategory
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
                //     onTap: () => EditCategoryController.instance
                //         .updateCategoryImage(context)),
                SpeedDialChild(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(TImages.delete, color: TColors.black),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                          icon: TImages.deleteProduct,
                          refund: false,
                          description:
                              'dialog.are_you_sure_want_to_delete_this_product'
                                  .tr,

                          onYesPressed:
                              () => EditCategoryController.instance
                                  .deleteCategory(category),
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
