import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/product/controllers/floating_button_vendor_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/featured/sector/view/build_sector_title.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class GridBuilderCustomCard extends StatefulWidget {
  GridBuilderCustomCard({
    super.key,
    required this.vendorId,
    required this.editMode,
    this.withoutPadding = false,
  });

  final String vendorId;
  final bool editMode;
  final bool withoutPadding;

  @override
  State<GridBuilderCustomCard> createState() => _GridBuilderCustomCardState();
}

class _GridBuilderCustomCardState extends State<GridBuilderCustomCard>
    with TickerProviderStateMixin {
  late ProductController controller;
  late RxList<ProductModel> spotList;
  var showMore = true.obs;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showFloatingMessage = true;

  @override
  void initState() {
    super.initState();
    controller = ProductController.instance;
    // تأجيل جلب البيانات إلى ما بعد اكتمال البناء لتجنب مشاكل البناء

    controller.fetchOffersData(widget.vendorId, 'mixlin1');

    spotList = controller.mixline1Dynamic;

    // تهيئة الـ AnimationController للرسالة المضية
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // بدء التمرير المضى
    _pulseController.repeat(reverse: true);

    // إخفاء الرسالة بعد 10 ثوانٍ
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showFloatingMessage = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = 48.w;
    double cardHeight = cardWidth * (4 / 3);
    var sectorName = 'mixlin1';
    var floatControllerVendor = Get.put(FloatingButtonsController());
    floatControllerVendor.isEditabel = widget.editMode;
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
          child: MasonryGridView.count(
            itemCount: 8,
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return TRoundedContainer(
                width: cardWidth,
                height: cardHeight,
                showBorder: true,
                borderWidth: 1,
                radius: BorderRadius.circular(15),
                borderColor: TColors.white,
                child: TShimmerEffect(
                  width: cardWidth,
                  height: cardHeight + 100,
                  raduis: BorderRadius.circular(15),
                ),
              );
            },
          ),
        );
      } else {
        if (spotList.isEmpty) {
          return widget.editMode
              ? Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BuildSectorTitle(
                      name: sectorName,
                      vendorId: widget.vendorId,
                    ),
                    TCustomWidgets.buildDivider(),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 14,
                        right: 14,
                        top: 10,
                      ),
                      child: MasonryGridView.count(
                        itemCount: 8,
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              TRoundedContainer(
                                borderColor: TColors.grey,
                                showBorder: true,
                                enableShadow: true,
                                width: cardWidth,
                                height: cardHeight + 100,
                                radius: BorderRadius.circular(15),
                              ),
                              // رسالة عائمة ومضية للتاجر عندما يكون عدد المنتجات 0
                              if (widget.editMode &&
                                  CategoryController
                                          .instance
                                          .productCount
                                          .value ==
                                      0 &&
                                  _showFloatingMessage &&
                                  index == 0)
                                Positioned(
                                  top: -60,
                                  left: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showFloatingMessage = false;
                                      });
                                    },
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _pulseAnimation.value,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: TColors.primary
                                                  .withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: TColors.primary
                                                      .withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.add_shopping_cart,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    (Get.locale?.languageCode ==
                                                            'ar')
                                                        ? 'ابدأ بإضافة منتجاتك الآن!'
                                                        : 'Start adding your products now!',
                                                    style: titilliumBold
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              InkWell(
                                onTap: () {
                                  var controller = Get.put(ProductController());
                                  controller.deleteTempItems();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CreateProduct(
                                            initialList: spotList,
                                            vendorId: widget.vendorId,
                                            sectorTitle: SectorModel(
                                              id: '',
                                              vendorId: widget.vendorId,
                                              englishName: 'try this',
                                              name: 'mixlin1',
                                            ),
                                            type: 'mixlin1',
                                            sectionId: 'all',
                                          ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    TRoundedContainer(
                                      showBorder: true,
                                      width: cardWidth,
                                      height: cardHeight,
                                      borderColor: TColors.grey.withValues(
                                        alpha: .5,
                                      ),
                                      radius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
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
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
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
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                Stack(
                  children: [
                    (spotList.length > 12 && showMore.value)
                        ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 14,
                                top: 10,
                              ),
                              child: MasonryGridView.count(
                                itemCount:
                                    widget.editMode
                                        ? spotList.sublist(0, 12).length + 2
                                        : spotList.sublist(0, 12).length,
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                padding: const EdgeInsets.all(0),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  if (widget.editMode &&
                                      index ==
                                          spotList.sublist(0, 12).length + 1) {
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
                                                  initialList: spotList,
                                                  vendorId: widget.vendorId,
                                                  sectorTitle: SectorModel(
                                                    id: '',
                                                    vendorId: widget.vendorId,
                                                    englishName: 'try this',
                                                    name: 'mixlin1',
                                                  ),
                                                  type: 'mixlin1',
                                                  sectionId: 'all',
                                                ),
                                          ),
                                        );
                                      },
                                      child: emptyMedium(
                                        cardHeight + 80,
                                        cardWidth,
                                      ),
                                    );
                                  }

                                  if (widget.editMode &&
                                      index == spotList.sublist(0, 12).length) {
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
                                                    id: '',
                                                    englishName: 'try this',
                                                    name: 'mixlin1',
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
                                        cardHeight + 80,
                                        cardWidth,
                                      ),
                                    );
                                  }

                                  return ActionsMethods.customLongMethode(
                                    spotList.sublist(0, 12)[index],
                                    context,
                                    VendorController.instance.isVendor.value,
                                    ProductWidgetMedium(
                                      prefferWidth: cardWidth,
                                      prefferHeight: cardHeight,
                                      product: spotList.sublist(0, 12)[index],
                                      vendorId: widget.vendorId,
                                      editMode:
                                          VendorController
                                              .instance
                                              .isVendor
                                              .value,
                                    ),
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          pageBuilder:
                                              (context, anim1, anim2) =>
                                                  ProductDetails(
                                                    key: UniqueKey(),
                                                    selected: index,
                                                    spotList: spotList.sublist(
                                                      0,
                                                      12,
                                                    ),
                                                    product:
                                                        spotList.sublist(
                                                          0,
                                                          12,
                                                        )[index],
                                                    vendorId: widget.vendorId,
                                                  ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Visibility(
                              visible: showMore.value,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => showMore.value = false,
                                    child: TRoundedContainer(
                                      width: 100.w,
                                      backgroundColor: TColors.grey,
                                      height: 40,
                                      radius: BorderRadius.circular(15),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              (Get.locale?.languageCode == 'en')
                                                  ? "Show More"
                                                  : "عرض المزيد",
                                              style: titilliumBold.copyWith(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Icon(
                                              CupertinoIcons.arrow_down_circle,
                                              color: Colors.black,

                                              // SvgPicture.asset(
                                              //   'assets/images/ecommerce/icons/arrowdown.svg',
                                              //   width: 7,
                                              //   height: 12,
                                              // ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 15,
                                right: 15,
                                bottom: 14,
                              ),
                              child: MasonryGridView.count(
                                itemCount:
                                    widget.editMode
                                        ? spotList.length + 2
                                        : spotList.length,
                                crossAxisCount: 2,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                padding: const EdgeInsets.all(0),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  if (widget.editMode &&
                                      index == spotList.length + 1) {
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
                                                  sectorTitle:
                                                      SectorController
                                                          .instance
                                                          .sectors
                                                          .where(
                                                            (e) =>
                                                                e.name ==
                                                                sectorName,
                                                          )
                                                          .first,
                                                  initialList: spotList,
                                                  vendorId: widget.vendorId,
                                                  type: 'mixlin1',
                                                  sectionId: 'all',
                                                ),
                                          ),
                                        );
                                      },
                                      child: emptyMedium(
                                        cardHeight + 80,
                                        cardWidth,
                                      ),
                                    );
                                  }

                                  if (widget.editMode &&
                                      index == spotList.length) {
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
                                                    id: '',
                                                    vendorId: widget.vendorId,
                                                    englishName: 'try this',
                                                    name: 'mixlin1',
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
                                        cardHeight + 80,
                                        cardWidth,
                                      ),
                                    );
                                  }

                                  return ActionsMethods.customLongMethode(
                                    spotList[index],
                                    context,
                                    VendorController.instance.isVendor.value,
                                    ProductWidgetMedium(
                                      prefferWidth: cardWidth,
                                      prefferHeight: cardHeight,
                                      product: spotList[index],
                                      vendorId: widget.vendorId,
                                      editMode: widget.editMode,
                                    ),
                                    () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          pageBuilder:
                                              (context, anim1, anim2) =>
                                                  ProductDetails(
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
                            ),
                            Visibility(
                              visible: !showMore.value && spotList.length > 12,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => showMore.value = true,
                                  child: TRoundedContainer(
                                    width: 100.w,
                                    backgroundColor: TColors.grey,
                                    height: 40,
                                    radius: BorderRadius.circular(15),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            (Get.locale?.languageCode == 'en')
                                                ? "Show Less"
                                                : "عرض أقل",
                                            style: titilliumBold.copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(
                                            CupertinoIcons.arrow_up_circle,
                                            color: Colors.black,

                                            // SvgPicture.asset(
                                            //   'assets/images/ecommerce/icons/arrowdown.svg',
                                            //   width: 7,
                                            //   height: 12,
                                            // ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    Visibility(
                      visible: widget.editMode,
                      child: Positioned(
                        bottom: 50,
                        right: (Get.locale?.languageCode == 'ar') ? null : 8,
                        left: (Get.locale?.languageCode == 'ar') ? 08 : null,
                        child: CustomFloatActionButton(
                          onTap: () {
                            var controller = Get.put(ProductController());
                            controller.deleteTempItems();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CreateProduct(
                                      sectorTitle: SectorModel(
                                        id: '',
                                        vendorId: widget.vendorId,
                                        englishName: 'try this',
                                        name: 'mixlin1',
                                      ),
                                      initialList: spotList,
                                      vendorId: widget.vendorId,
                                      type: 'mixlin1',
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
          );
        }
      }
    });
  }

  Widget emptyMedium(double cardHeight, double cardWidth) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight + 30,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          TRoundedContainer(
            borderColor: TColors.grey,
            showBorder: true,
            enableShadow: true,
            height: cardHeight + 1,
            width: cardWidth,
            radius: BorderRadius.circular(15),
          ),
        ],
      ),
    );
  }
}
