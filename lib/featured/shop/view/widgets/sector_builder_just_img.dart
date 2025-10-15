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
import 'package:istoreto/featured/product/views/widgets/product_actions_menu.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/views/vendor/add_product_page.dart';

import 'package:istoreto/featured/shop/view/widgets/sector_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_stuff.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';

class SectorBuilderJustImg extends StatefulWidget {
  const SectorBuilderJustImg({
    super.key,
    required this.vendorId,
    required this.editMode,
    required this.cardWidth,
    required this.sctionTitle,
    this.withTitle = true,
    required this.cardHeight,
    required this.sectorName,
    this.withPadding = true,
  });

  final String vendorId;
  final bool editMode;
  final double cardWidth;
  final double cardHeight;
  final bool withTitle;
  final String sectorName;
  final String sctionTitle;

  final bool withPadding;

  @override
  State<SectorBuilderJustImg> createState() => _SectorBuilderJustImgState();
}

class _SectorBuilderJustImgState extends State<SectorBuilderJustImg> {
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
      print('Error initializing SectorBuilderJustImg: $e');
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
                  CardType.justImage,
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
    // final ScrollController scrollController = ScrollController(); // Removed

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
              widget.cardWidth > 50.w
                  ? widget.cardHeight + 138
                  : widget.cardHeight + 90,
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
                      cardType: CardType.justImage,
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
                      cardType: CardType.justImage,
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
                      Stack(
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Column(
                              mainAxisAlignment:
                                  widget.cardWidth == 25.w
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                              crossAxisAlignment:
                                  widget.cardWidth == 25.w
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
                                Container(color: Colors.transparent, height: 6),
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
                                                builder: (context, snapshot) {
                                                  final displayText =
                                                      snapshot.connectionState ==
                                                                  ConnectionState
                                                                      .done &&
                                                              snapshot.hasData
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
                                                              FontWeight.bold,
                                                        ),
                                                    maxLines:
                                                        widget.cardWidth > 50.w
                                                            ? 2
                                                            : 1,
                                                    textAlign:
                                                        widget.cardWidth == 25.w
                                                            ? TextAlign.center
                                                            : TextAlign.justify,
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
                                                    widget.cardWidth == 25.w
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
                                                builder: (context, snapshot) {
                                                  final displayText =
                                                      snapshot.connectionState ==
                                                                  ConnectionState
                                                                      .done &&
                                                              snapshot.hasData
                                                          ? snapshot.data!
                                                          : spotList[index]
                                                                  .description ??
                                                              "";
                                                  return Text(
                                                    displayText,
                                                    textAlign:
                                                        widget.cardWidth == 25.w
                                                            ? TextAlign.center
                                                            : TextAlign.justify,
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
                                                  );
                                                },
                                              )
                                              : Text(
                                                spotList[index].description ??
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
                                                    widget.cardWidth == 25.w
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
                              child: ProductActionsMenu.buildProductActionsMenu(
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
                      ),
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
                              : Colors.grey.withValues(alpha: 0.5),
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
                heroTag:
                    'menu_${widget.vendorId}_${widget.sectorName}', // heroTag فريد
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
                heroTag:
                    'add_product_${widget.vendorId}_${widget.sectorName}', // heroTag فريد
                onTap: () {
                  var controller = Get.put(ProductController());
                  controller.deleteTempItems();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddProductPage(
                            vendorId: widget.vendorId,
                            initialSection: widget.sectorName,
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
