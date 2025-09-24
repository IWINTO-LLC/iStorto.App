import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/product/cashed_network_image.dart';

import 'package:istoreto/featured/product/controllers/floating_button_vendor_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/featured/sector/view/build_sector_title.dart';

import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class GridBuilder extends StatefulWidget {
  GridBuilder({super.key, required this.vendorId, required this.editMode});

  final String vendorId;
  final bool editMode;

  @override
  State<GridBuilder> createState() => _GridBuilderState();
}

class _GridBuilderState extends State<GridBuilder> {
  var showMore = true.obs;
  late ProductController controller;
  late RxList<ProductModel> spotList;

  @override
  void initState() {
    super.initState();
    controller = ProductController.instance;
    // تأجيل جلب البيانات إلى ما بعد اكتمال البناء لتجنب مشاكل البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOffersData(widget.vendorId, 'newArrival');
    });
    spotList = controller.newArrivalDynamic;
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = 33.33333.w;
    double cardHeight = cardWidth * (4 / 3);
    var floatControllerVendor = Get.put(FloatingButtonsController());
    floatControllerVendor.isEditabel = widget.editMode;
    var sectorName = 'mixlin1';
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Obx(
        () =>
            controller.isLoading.value
                ? MasonryGridView.count(
                  itemCount: 9,
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return TRoundedContainer(
                      width: cardWidth,
                      height: cardHeight,
                      showBorder: true,
                      borderWidth: 1,
                      borderColor: TColors.white,
                      child: TShimmerEffect(
                        width: cardWidth,
                        height: cardHeight,
                        raduis: BorderRadius.circular(0),
                      ),
                    );
                  },
                )
                :
                //loading finish
                controller.newArrivalDynamic.isEmpty
                ? widget.editMode
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BuildSectorTitle(
                              name: sectorName,
                              vendorId: widget.vendorId,
                            ),
                            GestureDetector(
                              onTap:
                                  () => showEditDialog(
                                    context,
                                    SectorController.instance.sectors
                                        .where((s) => s.name == sectorName)
                                        .first,
                                  ),
                              child: Visibility(
                                visible: widget.editMode,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8,
                                  ),
                                  child: TRoundedContainer(
                                    width: 28,
                                    height: 28,
                                    //showBorder: true,
                                    enableShadow: true,
                                    radius: BorderRadius.circular(300),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.edit, size: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.spaceBtWItems),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: MasonryGridView.count(
                            itemCount: 12,
                            crossAxisCount: 3,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            padding: const EdgeInsets.all(0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      var controller = Get.put(
                                        ProductController(),
                                      );
                                      controller.deleteTempItems();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CreateProduct(
                                                vendorId: widget.vendorId,
                                                type: 'newArrival',
                                                initialList: spotList,
                                                sectionId: 'all',
                                                sectorTitle: SectorModel(
                                                  name: 'newArrival',
                                                  englishName: 'New Arrival',
                                                  vendorId: '',
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    child: TRoundedContainer(
                                      width: cardWidth,
                                      height: cardHeight,
                                      borderColor: TColors.grey,
                                      showBorder: true,
                                      borderWidth: 1,
                                      child: Visibility(
                                        visible: index == 0,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0,
                                            ),
                                            child: TRoundedContainer(
                                              enableShadow: true,
                                              width: 50,
                                              height: 50,
                                              radius: BorderRadius.circular(
                                                300,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.add,
                                                color: TColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink()
                : (spotList.length < 3 && !widget.editMode)
                ? SizedBox.shrink()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TCustomWidgets.buildTitle('New_Arrival'.tr),
                    const SizedBox(height: TSizes.spaceBtWItems),
                    Stack(
                      children: [
                        (spotList.length < 3 && !widget.editMode)
                            ? SizedBox.shrink()
                            : (spotList.length > 12 && showMore.value)
                            ? Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: Column(
                                children: [
                                  MasonryGridView.count(
                                    itemCount:
                                        widget.editMode
                                            ? spotList.sublist(0, 12).length + 2
                                            : spotList.sublist(0, 12).length,
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 0,
                                    padding: const EdgeInsets.all(0),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      if (widget.editMode &&
                                          index ==
                                              spotList.sublist(0, 12).length +
                                                  1) {
                                        return GestureDetector(
                                          onTap: () {
                                            var controller = Get.put(
                                              ProductController(),
                                            );
                                            controller.deleteTempItems();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => CreateProduct(
                                                      vendorId: widget.vendorId,
                                                      type: 'mixlin1',
                                                      sectorTitle: SectorModel(
                                                        name: 'newArrival',
                                                        englishName:
                                                            'New Arrival',
                                                        vendorId: '',
                                                      ),
                                                      initialList: spotList,
                                                      sectionId: 'all',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: emptyMedium(
                                            cardHeight,
                                            cardWidth,
                                          ),
                                        );
                                      }

                                      if (widget.editMode &&
                                          index ==
                                              spotList.sublist(0, 12).length) {
                                        return GestureDetector(
                                          onTap: () {
                                            var controller = Get.put(
                                              ProductController(),
                                            );
                                            controller.deleteTempItems();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => CreateProduct(
                                                      sectorTitle: SectorModel(
                                                        name: 'newArrival',
                                                        englishName:
                                                            'New Arrival',
                                                        vendorId: '',
                                                      ),
                                                      initialList: spotList,
                                                      vendorId: widget.vendorId,
                                                      type: 'mixlin1',
                                                      sectionId: 'all',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: emptyMedium(
                                            cardHeight,
                                            cardWidth,
                                          ),
                                        );
                                      }

                                      return ActionsMethods.customLongMethode(
                                        spotList.sublist(0, 12)[index],
                                        context,
                                        VendorController
                                            .instance
                                            .isVendor
                                            .value,
                                        TRoundedContainer(
                                          width: cardWidth,
                                          height: cardHeight,
                                          showBorder: true,
                                          borderWidth: 1,
                                          borderColor: TColors.white,
                                          child: CustomCaChedNetworkImage(
                                            width: cardWidth,
                                            enableShadow: false,
                                            height: cardHeight,
                                            raduis: BorderRadius.circular(0),
                                            url:
                                                spotList
                                                    .sublist(0, 12)[index]
                                                    .images!
                                                    .first,
                                          ),
                                        ),
                                        () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 1000,
                                                  ),
                                              pageBuilder:
                                                  (context, anim1, anim2) =>
                                                      ProductDetails(
                                                        key: UniqueKey(),
                                                        selected: index,
                                                        spotList: spotList
                                                            .sublist(0, 12),
                                                        product:
                                                            spotList.sublist(
                                                              0,
                                                              12,
                                                            )[index],
                                                        vendorId:
                                                            widget.vendorId,
                                                      ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  Visibility(
                                    visible: showMore.value,
                                    child: GestureDetector(
                                      onTap: () => showMore.value = false,
                                      child: TRoundedContainer(
                                        width: 100.w,
                                        backgroundColor: TColors.grey,
                                        height: 40,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "show_more".tr,
                                                style: titilliumBold.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Icon(
                                                CupertinoIcons
                                                    .arrow_down_circle,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: Column(
                                children: [
                                  MasonryGridView.count(
                                    itemCount:
                                        widget.editMode ? 12 : spotList.length,
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 0,
                                    padding: const EdgeInsets.all(0),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      if (widget.editMode &&
                                          index >= spotList.length) {
                                        return InkWell(
                                          onTap: () {
                                            var controller = Get.put(
                                              ProductController(),
                                            );
                                            controller.deleteTempItems();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => CreateProduct(
                                                      sectorTitle: SectorModel(
                                                        name: 'newArrival',
                                                        englishName:
                                                            'New Arrival',
                                                        vendorId: '',
                                                      ),
                                                      initialList: spotList,
                                                      vendorId: widget.vendorId,
                                                      type: 'newArrival',
                                                      sectionId: 'all',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: emptyMedium(
                                            cardHeight,
                                            cardWidth,
                                          ),
                                        );
                                      }
                                      return ActionsMethods.customLongMethode(
                                        spotList[index],
                                        context,
                                        widget.editMode,
                                        TRoundedContainer(
                                          width: cardWidth,
                                          height: cardHeight,
                                          showBorder: true,
                                          borderWidth: 1,
                                          borderColor: TColors.white,
                                          child: CustomCaChedNetworkImage(
                                            width: cardWidth,
                                            height: cardHeight,
                                            enableShadow: false,
                                            raduis: BorderRadius.circular(0),
                                            url: spotList[index].images!.first,
                                          ),
                                        ),
                                        () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 1000,
                                                  ),
                                              pageBuilder:
                                                  (
                                                    context,
                                                    anim1,
                                                    anim2,
                                                  ) => ProductDetails(
                                                    key: UniqueKey(),
                                                    selected: index,
                                                    spotList: spotList,
                                                    product: spotList[index],
                                                    vendorId: widget.vendorId,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  Visibility(
                                    visible:
                                        !showMore.value && spotList.length > 12,
                                    child: GestureDetector(
                                      onTap: () => showMore.value = true,
                                      child: TRoundedContainer(
                                        width: 100.w,
                                        backgroundColor: TColors.grey,
                                        height: 40,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'show_less'.tr,
                                                style: titilliumBold.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Icon(
                                                CupertinoIcons.arrow_up_circle,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        Visibility(
                          visible: false,
                          child: Positioned(
                            bottom: 40,
                            right:
                                TranslationController.instance.isRTL ? null : 8,
                            left:
                                TranslationController.instance.isRTL ? 8 : null,
                            child: CustomFloatActionButton(
                              onTap: () {
                                var controller = Get.put(ProductController());
                                controller.deleteTempItems();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CreateProduct(
                                          vendorId: widget.vendorId,
                                          sectorTitle: SectorModel(
                                            name: 'newArrival',
                                            englishName: 'New Arrival',
                                            vendorId: '',
                                          ),
                                          initialList: spotList,
                                          type: 'newArrival',
                                          sectionId: 'all',
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}

Widget emptyMedium(double cardHeight, double cardWidth) {
  return SizedBox(
    width: cardWidth,
    height: cardHeight,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        TRoundedContainer(
          borderColor: TColors.grey,
          showBorder: true,
          // enableShadow: true,
          height: cardHeight,
          width: cardWidth,
          radius: BorderRadius.circular(0),
        ),
      ],
    ),
  );
}
