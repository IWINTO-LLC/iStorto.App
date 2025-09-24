import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/cart/view/add_to_cart_wid_small.dart';
import 'package:istoreto/featured/cart/view/widgets/dynamic_add_cart.dart';
import 'package:istoreto/featured/product/controllers/floating_button_vendor_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium_fixed_height.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_small.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';

import 'package:istoreto/featured/shop/view/widgets/sector_stuff.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';

class SectorBuilder extends StatefulWidget {
  const SectorBuilder({
    super.key,
    required this.vendorId,
    required this.editMode,
    required this.cardWidth,
    required this.sctionTitle,
    this.withTitle = true,
    required this.cardHeight,
    required this.sectorName,
    this.withPadding = true,
    required this.cardType,
  });

  final String vendorId;
  final bool editMode;
  final double cardWidth;
  final double cardHeight;
  final bool withTitle;
  final String sectorName;
  final String sctionTitle;
  final CardType cardType;
  final bool withPadding;

  @override
  State<SectorBuilder> createState() => _SectorBuilderState();
}

class _SectorBuilderState extends State<SectorBuilder> {
  late ProductController productController;
  bool _isInitialized = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // التأكد من وجود ProductController
      if (!Get.isRegistered<ProductController>()) {
        Get.put(ProductController());
      }

      productController = Get.find<ProductController>();

      // جلب البيانات فوراً
      await productController.fetchListData(widget.vendorId, widget.sectorName);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing SectorBuilder: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 10;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    final floatControllerVendor = Get.put(FloatingButtonsController());
    floatControllerVendor.isEditabel = widget.editMode;

    // var floatControllerVendor = Get.put(FloatingButtonsController());
    // floatControllerVendor.isEditabel = editMode;
    RxList<ProductModel> spotList = <ProductModel>[].obs;

    // إذا لم يتم التهيئة بعد، اعرض loading
    if (!_isInitialized) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              height: widget.cardHeight + 16,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder:
                    (context, index) => TShimmerEffect(
                      raduis: BorderRadius.circular(15),
                      height: widget.cardHeight + 2,
                      width: widget.cardWidth,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<ProductModel>>(
      future: productController.fetchListData(
        widget.vendorId,
        widget.sectorName,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  height: widget.cardHeight + 16,
                  child: ListView.separated(
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder:
                        (context, index) => TShimmerEffect(
                          raduis: BorderRadius.circular(15),
                          height: widget.cardHeight + 2,
                          width: widget.cardWidth,
                        ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final products = getSpotList(widget.sectorName);

          if (products.isEmpty) {
            return widget.editMode
                ? getEmptyEdit(
                  context,
                  padding,
                  products,
                  widget.cardType,
                  widget.cardHeight,
                  widget.cardWidth,
                  widget.sectorName,
                  widget.vendorId,
                  widget.withTitle,
                  widget.editMode,
                  widget.withPadding,
                )
                : const SizedBox.shrink();
          } else {
            return Container(
              color: Colors.transparent,
              child: Padding(
                padding:
                    widget.withPadding
                        ? const EdgeInsets.only(top: 20)
                        : const EdgeInsets.only(top: 10),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.editMode) SizedBox(height: 8),
                    titleWithEdit(
                      context,
                      widget.sectorName,
                      widget.withTitle,
                      widget.vendorId,
                      widget.editMode,
                    ),
                    SizedBox(height: 8),
                    // Visibility(
                    //     visible: withTitle,
                    //     child: TCustomWidgets.buildDivider()),
                    buildContent(products, padding, context),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  Stack buildContent(
    RxList<ProductModel> spotList,
    double padding,
    BuildContext context,
  ) {
    final langCode = Localizations.localeOf(context).languageCode;

    // إنشاء RxInt لمؤشر النقاط
    final String tag = 'currentIndex_${spotList.hashCode}';
    if (!Get.isRegistered<RxInt>(tag: tag)) {
      Get.put(RxInt(0), tag: tag);
    }
    final RxInt currentIndex = Get.find<RxInt>(tag: tag);

    // إضافة listener للـ ScrollController لتحديث مؤشر النقاط
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        double offset = _scrollController.offset;
        int newIndex = (offset / (widget.cardWidth + padding)).round();
        newIndex = newIndex.clamp(0, spotList.length - 1);
        currentIndex.value = newIndex;
      }
    });

    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          height:
              widget.cardType == CardType.justImage
                  ? widget.cardWidth > 50.w
                      ? widget.cardHeight + 138
                      : widget.cardHeight + 90
                  : widget.cardType == CardType.smallCard
                  ? widget.cardHeight + 75
                  : widget.cardHeight + 136,
          child: Obx(
            () => ListView.builder(
              controller: _scrollController,
              // padding: EdgeInsets.symmetric(vertical: 5),
              scrollDirection: Axis.horizontal,
              itemCount:
                  widget.editMode ? spotList.length + 2 : spotList.length,
              itemBuilder: (context, index) {
                if (widget.editMode && index == spotList.length + 1) {
                  return Padding(
                    padding:
                        !TranslationController.instance.isRTL
                            ? const EdgeInsets.only(
                              left: 7.0,
                              bottom: 22,
                              right: 14,
                            )
                            : const EdgeInsets.only(
                              right: 7.0,
                              bottom: 22,
                              left: 10,
                            ),
                    child: EmptyAddItem(
                      cardHeight: widget.cardHeight,
                      cardWidth: widget.cardWidth,
                      sctionTitle: widget.sectorName,
                      vendorId: widget.vendorId,
                      sectorTitle:
                          SectorController.instance.sectors
                              .where((s) => s.name == widget.sectorName)
                              .first,
                      cardType: widget.cardType,
                    ),
                  );
                }
                if (widget.editMode && index == spotList.length) {
                  return Padding(
                    padding:
                        !TranslationController.instance.isRTL
                            ? const EdgeInsets.only(
                              left: 0.0,
                              bottom: 10,
                              right: 7,
                            )
                            : const EdgeInsets.only(
                              right: 0.0,
                              bottom: 10,
                              left: 7,
                            ),
                    child: EmptyAddItem(
                      cardHeight: widget.cardHeight,
                      cardWidth: widget.cardWidth,
                      sctionTitle: widget.sectorName,
                      vendorId: widget.vendorId,
                      sectorTitle:
                          SectorController.instance.sectors
                              .where((s) => s.name == widget.sectorName)
                              .first,
                      cardType: widget.cardType,
                    ),
                  );
                }

                return Padding(
                  padding:
                      !TranslationController.instance.isRTL
                          ? EdgeInsets.only(
                            left: padding,
                            bottom: 10,
                            right: index == spotList.length - 1 ? padding : 0,
                          )
                          : EdgeInsets.only(
                            right: padding,
                            bottom: 10,
                            left: index == spotList.length - 1 ? padding : 0,
                          ),
                  child: TRoundedContainer(
                    // backgroundColor: Colors.red,
                    //backgroundColor: Colors.yellow,
                    // height: cardHeight,
                    radius: BorderRadius.circular(15),
                    width: widget.cardWidth,
                    child: ActionsMethods.customLongMethode(
                      spotList[index],
                      context,
                      VendorController.instance.isVendor.value,
                      widget.cardType == CardType.justImage
                          ? Stack(
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Column(
                                  mainAxisAlignment:
                                      widget.cardWidth == 26.w
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      widget.cardWidth == 26.w
                                          ? CrossAxisAlignment.center
                                          : CrossAxisAlignment.start,
                                  // mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TProductImageSliderMini(
                                      editMode: widget.editMode,
                                      withActions: false,
                                      enableShadow: true,
                                      product: spotList[index],
                                      prefferHeight:
                                          widget.cardWidth * (4 / 3) + 12,
                                      prefferWidth: widget.cardWidth,
                                    ),
                                    Container(
                                      color: Colors.transparent,
                                      height: 6,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: SizedBox(
                                        width:
                                            widget.cardHeight > 50.w
                                                ? widget.cardWidth - 55
                                                : widget.cardWidth,
                                        child: Obx(
                                          () =>
                                              TranslateController
                                                      .instance
                                                      .enableTranslateProductDetails
                                                      .value
                                                  ? FutureBuilder<String>(
                                                    future: TranslateController
                                                        .instance
                                                        .translateText(
                                                          text:
                                                              spotList[index]
                                                                  .title ??
                                                              "",
                                                          targetLangCode:
                                                              Localizations.localeOf(
                                                                context,
                                                              ).languageCode,
                                                        ),
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      final displayText =
                                                          snapshot.connectionState ==
                                                                      ConnectionState
                                                                          .done &&
                                                                  snapshot
                                                                      .hasData
                                                              ? snapshot.data!
                                                              : spotList[index]
                                                                      .title ??
                                                                  "";
                                                      return Text(
                                                        displayText,
                                                        style: titilliumSemiBold
                                                            .copyWith(
                                                              fontSize:
                                                                  widget.cardWidth >
                                                                          50.w
                                                                      ? 15
                                                                      : 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        maxLines:
                                                            widget.cardWidth >
                                                                    50.w
                                                                ? 2
                                                                : 1,
                                                        textAlign:
                                                            widget.cardWidth ==
                                                                    26.w
                                                                ? TextAlign
                                                                    .center
                                                                : TextAlign
                                                                    .justify,
                                                      );
                                                    },
                                                  )
                                                  : Text(
                                                    spotList[index].title ?? "",
                                                    style: titilliumSemiBold
                                                        .copyWith(
                                                          fontSize:
                                                              widget.cardWidth >
                                                                      50.w
                                                                  ? 15
                                                                  : 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    maxLines:
                                                        widget.cardWidth > 50.w
                                                            ? 2
                                                            : 1,
                                                    textAlign:
                                                        widget.cardWidth == 26.w
                                                            ? TextAlign.center
                                                            : TextAlign.start,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: SizedBox(
                                        width:
                                            widget.cardHeight > 50.w
                                                ? widget.cardWidth - 55
                                                : widget.cardWidth,
                                        child: Obx(
                                          () =>
                                              TranslateController
                                                      .instance
                                                      .enableTranslateProductDetails
                                                      .value
                                                  ? FutureBuilder<String>(
                                                    future: TranslateController
                                                        .instance
                                                        .translateText(
                                                          text:
                                                              spotList[index]
                                                                  .description ??
                                                              "",
                                                          targetLangCode:
                                                              Localizations.localeOf(
                                                                context,
                                                              ).languageCode,
                                                        ),
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      final displayText =
                                                          snapshot.connectionState ==
                                                                      ConnectionState
                                                                          .done &&
                                                                  snapshot
                                                                      .hasData
                                                              ? snapshot.data!
                                                              : spotList[index]
                                                                      .description ??
                                                                  "";
                                                      return Text(
                                                        displayText,
                                                        textAlign:
                                                            widget.cardWidth ==
                                                                    26.w
                                                                ? TextAlign
                                                                    .center
                                                                : TextAlign
                                                                    .justify,
                                                        style: titilliumSemiBold
                                                            .copyWith(
                                                              fontSize:
                                                                  widget.cardWidth >
                                                                          50.w
                                                                      ? 15
                                                                      : 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                        maxLines:
                                                            widget.cardWidth >
                                                                    50.w
                                                                ? 2
                                                                : 1,
                                                      );
                                                    },
                                                  )
                                                  : Text(
                                                    spotList[index]
                                                            .description ??
                                                        "",
                                                    style: titilliumSemiBold
                                                        .copyWith(
                                                          fontSize:
                                                              widget.cardWidth >
                                                                      50.w
                                                                  ? 15
                                                                  : 12,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                    maxLines:
                                                        widget.cardWidth > 50.w
                                                            ? 2
                                                            : 1,
                                                    textAlign:
                                                        widget.cardWidth == 26.w
                                                            ? TextAlign.center
                                                            : TextAlign.justify,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: TCustomWidgets.formattedPrice(
                                        spotList[index].price,
                                        widget.cardWidth > 50.w ? 17 : 14,
                                        TColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible:
                                    !widget.editMode && widget.cardWidth > 50.w,
                                child: Positioned(
                                  top: widget.cardHeight + 18,
                                  right: 8,
                                  child:
                                      ProductActionsMenu.buildProductActionsMenu(
                                        spotList[index],
                                      ),
                                ),
                              ),

                              Visibility(
                                visible: !widget.editMode,
                                child: Positioned(
                                  top:
                                      widget.cardWidth > 50.w
                                          ? widget.cardHeight - 30
                                          : widget.cardHeight - 58,
                                  right: 6,
                                  child:
                                      widget.cardWidth > 50.w
                                          ? DynamicCartAction(
                                            product: spotList[index],
                                          )
                                          : GestureDetector(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 28.0,
                                                bottom: 28,
                                              ),
                                              child: AddToCartWidgetSmall(
                                                product: spotList[index],
                                              ),
                                            ),
                                          ),
                                ),
                              ),

                              // Visibility(
                              //   visible: cardWidth > 200,
                              //   child:  Positioned(
                              //       top: 0,
                              //       right: 0,
                              //       child: ControlPanelBlackProducttype2(
                              //         editMode: editMode,
                              //         product: spotList[index],
                              //         vendorId: vendorId,
                              //         withCircle: true,
                              //       )),
                              // ),
                            ],
                          )
                          : widget.cardType == CardType.smallCard
                          ? ProductWidgetSmall(
                            product: spotList[index],
                            vendorId: widget.vendorId,
                          )
                          : widget.cardType == CardType.mediumCard
                          ? ProductWidgetMediumFixedHeight(
                            vendorId: widget.vendorId,
                            editMode: widget.editMode,
                            prefferWidth: widget.cardWidth,
                            prefferHeight: widget.cardHeight,
                            product: spotList[index],
                          )
                          : const SizedBox.shrink(),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetails(
                                  key: UniqueKey(),
                                  selected: index,
                                  spotList: spotList,
                                  product: spotList[index],
                                  vendorId: widget.vendorId,
                                ),
                          ),
                        );
                        // Navigator.push(
                        //     context,
                        //     PageRouteBuilder(
                        //       transitionDuration:
                        //           const Duration(milliseconds: 1000),
                        //       pageBuilder: (context, anim1, anim2) =>

                        //     ));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // مؤشر النقاط أسفل القائمة
        Visibility(
          visible:
              !widget.editMode &&
              spotList.length > 1 &&
              widget.cardWidth == 94.w,
          child: Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(spotList.length, (index) {
                  bool isActive = index == currentIndex.value;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 15 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? TColors.primary
                              : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        Visibility(
          visible: widget.editMode,
          child: Visibility(
            visible: spotList.length > 2,
            child: Positioned(
              bottom: 15,
              right: TranslationController.instance.isRTL ? null : 47,
              left: TranslationController.instance.isRTL ? 47 : null,
              child: CustomFloatActionButton(
                icon: Icons.menu_open_rounded,
                onTap: () {
                  showExcelBottomSheet(context, spotList, widget.vendorId);
                  // var controller = Get.put(ProductController());
                  // controller.deleteTempItems();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             ProductManageBulkMenu(
                  //               initialList: spotList,
                  //             )));
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.editMode,
          child: Positioned(
            bottom: 15,
            right: TranslationController.instance.isRTL ? null : 7,
            left: TranslationController.instance.isRTL ? 7 : null,
            child: Visibility(
              visible: spotList.length > 2,
              child: CustomFloatActionButton(
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
                            type: widget.sectorName,
                            sectorTitle:
                                SectorController.instance.sectors
                                    .where((s) => s.name == widget.sectorName)
                                    .first,
                            sectionId: widget.sectorName,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyAddItem extends StatelessWidget {
  const EmptyAddItem({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    required this.vendorId,
    required this.sectorTitle,
    required this.sctionTitle,
    required this.cardType,
  });

  final double cardHeight;
  final double cardWidth;
  final String vendorId;
  final SectorModel sectorTitle;
  final String sctionTitle;
  final CardType cardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: cardWidth,
      // height: cardHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          InkWell(
            onTap: () {
              var controller = Get.put(ProductController());
              controller.deleteTempItems();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CreateProduct(
                        vendorId: vendorId,
                        initialList: [],
                        type: sectorTitle.name,
                        sectorTitle: sectorTitle,
                        sectionId: sctionTitle,
                      ),
                ),
              );
            },
            child: TRoundedContainer(
              borderColor: TColors.grey,
              showBorder: true,
              enableShadow: true,
              height:
                  cardType == CardType.mediumCard
                      ? cardHeight + 136
                      : cardType == CardType.justImage
                      ? cardHeight + 12
                      : cardHeight,
              width: cardWidth,
              radius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }
}
