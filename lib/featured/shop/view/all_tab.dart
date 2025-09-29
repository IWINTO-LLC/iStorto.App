import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/banner/view/front/promo_slider.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium_fixed_height.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/shop/view/widgets/grid_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/grid_builder_custom_card.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_builder.dart';
import 'package:istoreto/featured/shop/view/widgets/sector_builder_just_img.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:sizer/sizer.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key, required this.editMode, required this.vendorId});
  final bool editMode;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    Get.put(SectorController(vendorId));
    ProductController.instance.closeList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const SizedBox(
        //   height: 4,
        // ),
        // TPromoSlider(editMode: editMode, vendorId: vendorId),
        Container(color: Colors.transparent, height: 16),

        viewCategories(),
        // const SizedBox(
        //   height: 16,
        // ),
        GridBuilderCustomCard(vendorId: vendorId, editMode: editMode),
        Container(color: Colors.transparent, height: 10),
        SectorBuilder(
          cardWidth: 70.w,
          cardHeight: 70.w * 4 / 3,
          sectorName: 'mixone',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          cardType: CardType.justImage,
          withPadding: false,
        ),
        // const SizedBox(
        //   height: 16,
        // ),
        SectorBuilderJustImg(
          cardWidth: 25.w,
          cardHeight: 25.w * (4 / 3),
          sectorName: "offers",
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
          // cardType: CardType.justImage,
        ),
        // const SizedBox(
        //   height: 8,
        // ),
        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
          cardType: CardType.smallCard,
        ),

        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all1',
          sctionTitle: 'all',
          vendorId: vendorId,

          withPadding: false,
          editMode: editMode,
          // withTitle: false,
          cardType: CardType.smallCard,
        ),

        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all2',
          vendorId: vendorId,
          sctionTitle: 'all',
          editMode: editMode,
          withPadding: false,
          cardType: CardType.smallCard,
        ),
        SectorBuilder(
          cardWidth: 33.333.w,
          cardHeight: 33.333.w * (4 / 3),
          sectorName: 'all3',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          withPadding: false,
          cardType: CardType.smallCard,
        ),
        //   SectorBuilder(
        //   cardWidth: 127,
        //   cardHeight: 170,
        //   sectorTitle: SectorModel(
        //          name: 'all4', englishName: 'Product List4', arabicName: 'قائمة المنتجات 4'),
        //   sctionTitle: 'all',
        //   vendorId: vendorId,
        //   editMode: editMode,

        //   cardType: CardType.smallCard,
        // ),
        SectorBuilderJustImg(
          cardWidth: 94.w,
          cardHeight: 94.w * (8 / 6),
          sectorName: 'sales',
          vendorId: vendorId,
          editMode: editMode,
          // cardType: CardType.justImage,
          withPadding: false,
          sctionTitle: '',
        ),

        SectorBuilderJustImg(
          cardWidth: 25.w,
          cardHeight: 25.w * (4 / 3),
          sectorName: 'foryou',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          //cardType: CardType.justImage,
          withPadding: false,
        ),
        // const SizedBox(
        //   height: 30,
        // ),
        GridBuilder(vendorId: vendorId, editMode: editMode),

        /////////////////////////////

        // SectorBuilder(
        //   cardWidth: 70.w,
        //   cardHeight: 70.w * 4 / 3,
        //   sectorName: 'mixone',
        //   sctionTitle: 'all',
        //   vendorId: vendorId,
        //   editMode: editMode,
        //   withPadding: false,
        //   cardType: CardType.justImage,
        // ),
        SectorBuilder(
          cardWidth: 40.w,
          cardHeight: 40.w * (4 / 3),
          sectorName: 'mixlin2',
          sctionTitle: 'all',
          vendorId: vendorId,
          editMode: editMode,
          cardType: CardType.mediumCard,
          withTitle: true,
          withPadding: false,
        ),

        /////////////////////mix ones
        Visibility(
          visible: CategoryController.instance.productCount > 40,
          child: Container(color: Colors.transparent, height: 20),
        ),

        Visibility(
          visible: CategoryController.instance.productCount > 40,
          child: viewCategories(),
        ),

        Container(color: Colors.transparent, height: 60),
      ],
    );
  }

  viewCategories() {
    var controller = ProductController.instance;

    var cardWidth = 40.w;
    var cardHeight = 40.w * (4 / 3);

    if (CategoryController.instance.allItems.isEmpty) {
      return editMode
          ? Column(
            children: [
              Container(
                color: Colors.transparent,
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: addCategoryItem(index, context, vendorId),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TRoundedContainer(
                          backgroundColor: Colors.white,
                          showBorder: true,
                          enableShadow: true,
                          radius: BorderRadius.circular(300),
                          width: 70,
                          height: 70,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          )
          : const SizedBox.shrink();
    } else {
      return editMode
          ? Column(
            children: [
              Stack(
                children: [
                  Obx(
                    () => Center(
                      child: TRoundedContainer(
                        backgroundColor: Colors.transparent,
                        height: 120,
                        showBorder: false,
                        width:
                            85 *
                            (CategoryController.instance.allItems.length + 1),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              CategoryController.instance.allItems.length + 1,
                          itemBuilder: (context, index) {
                            try {
                              if (index ==
                                  CategoryController.instance.allItems.length) {
                                // العنصر الثابت في النهاية
                                return Center(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 45.0,
                                        ),
                                        child: addCategoryItem(
                                          index,
                                          context,
                                          vendorId,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                );
                              }

                              // فحص أن index صحيح
                              if (index < 0 ||
                                  index >=
                                      CategoryController
                                          .instance
                                          .allItems
                                          .length) {
                                return const SizedBox.shrink();
                              }

                              final category =
                                  CategoryController.instance.allItems[index];

                              // فحص أن category صحيح
                              if (category.id?.isEmpty ?? true) {
                                return const SizedBox.shrink();
                              }

                              return Row(
                                children: [
                                  if (index == 0) const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap:
                                        () => controller.selectCategory(
                                          category,
                                          vendorId,
                                        ),
                                    child: Obx(
                                      () => TCategoryGridItem(
                                        category: category,
                                        editMode: editMode,
                                        selected:
                                            controller.selectedCategory.value ==
                                            category,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } catch (e) {
                              debugPrint(
                                'Error building category item at index $index: $e',
                              );
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  height: controller.isExpanded.value ? cardHeight + 200 : 0,
                  child:
                      controller.isExpanded.value
                          ? Column(
                            children: [
                              SizedBox(
                                height: cardHeight + 150,
                                child: Obx(() {
                                  if (controller.loadProduct.value) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (controller.products.isEmpty) {
                                    return Center(
                                      child: Image.asset(
                                        'assets/images/liquid_loading.gif',
                                        width: 50.w,
                                        height: 50.w,
                                      ),
                                    );
                                  }

                                  var spotList = controller.products;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                    ),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: spotList.length,
                                      itemBuilder: (context, index) {
                                        try {
                                          // فحص أن index صحيح
                                          if (index < 0 ||
                                              index >= spotList.length) {
                                            return const SizedBox.shrink();
                                          }

                                          final product = spotList[index];

                                          // فحص أن product صحيح
                                          if (product.id.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          return InkWell(
                                            onTap: () {
                                              try {
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
                                                          selected: index,
                                                          spotList: spotList,
                                                          key: UniqueKey(),
                                                          product: product,
                                                          vendorId: vendorId,
                                                        ),
                                                  ),
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                  'Error navigating to ProductDetails: $e',
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  !TranslationController
                                                          .instance
                                                          .isRTL
                                                      ? EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 22,
                                                        top: 8,
                                                        right:
                                                            index ==
                                                                    spotList.length -
                                                                        1
                                                                ? 14
                                                                : 0,
                                                      )
                                                      : EdgeInsets.only(
                                                        right: 14.0,
                                                        bottom: 22,
                                                        top: 8,
                                                        left:
                                                            index ==
                                                                    spotList.length -
                                                                        1
                                                                ? 14
                                                                : 0,
                                                      ),
                                              child: SizedBox(
                                                width: cardWidth,
                                                child:
                                                    ProductWidgetMediumFixedHeight(
                                                      prefferWidth: cardWidth,
                                                      prefferHeight: cardHeight,
                                                      product: product,
                                                      vendorId: vendorId,
                                                      editMode: editMode,
                                                    ),
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          debugPrint(
                                            'Error building product item at index $index: $e',
                                          );
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  );
                                }),
                              ),
                              // زر الإغلاق
                              GestureDetector(
                                onTap: controller.closeList,
                                child: Center(
                                  child: Container(
                                    width: 50,
                                    padding: const EdgeInsets.fromLTRB(
                                      5,
                                      7,
                                      5,
                                      7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_circle_up_sharp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                            ],
                          )
                          : const SizedBox.shrink(),
                );
              }),
            ],
          )
          : Column(
            children: [
              Center(
                child: Container(
                  color: Colors.transparent,
                  height: 120,
                  width: _calculateCategoryContainerWidth(),
                  child: Obx(() {
                    if (CategoryController.instance.allItems.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CategoryController.instance.allItems.length,
                      itemBuilder: (context, index) {
                        try {
                          // فحص أن index صحيح
                          if (index < 0 ||
                              index >=
                                  CategoryController.instance.allItems.length) {
                            return const SizedBox.shrink();
                          }

                          final category =
                              CategoryController.instance.allItems[index];

                          // فحص أن category صحيح
                          if (category.id?.isEmpty ?? true) {
                            return const SizedBox.shrink();
                          }

                          return GestureDetector(
                            onTap:
                                () => controller.selectCategory(
                                  category,
                                  vendorId,
                                ),
                            child: Padding(
                              padding: _calculateCategoryPadding(),
                              child: Obx(
                                () => TCategoryGridItem(
                                  category: category,
                                  editMode: editMode,
                                  selected:
                                      controller.selectedCategory.value ==
                                      category,
                                ),
                              ),
                            ),
                          );
                        } catch (e) {
                          debugPrint(
                            'Error building category item at index $index: $e',
                          );
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  }),
                ),
              ),
              Obx(() {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  height: controller.isExpanded.value ? cardHeight + 200 : 0,
                  child:
                      controller.isExpanded.value
                          ? Column(
                            children: [
                              SizedBox(
                                height: cardHeight + 150,
                                child: Obx(() {
                                  if (controller.loadProduct.value) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (controller.products.isEmpty) {
                                    return Center(
                                      child: Image.asset(
                                        'assets/images/liquid_loading.gif',
                                        width: 50.w,
                                        height: 50.w,
                                      ),
                                    );
                                  }

                                  var spotList = controller.products;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                    ),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: spotList.length,
                                      itemBuilder: (context, index) {
                                        try {
                                          // فحص أن index صحيح
                                          if (index < 0 ||
                                              index >= spotList.length) {
                                            return const SizedBox.shrink();
                                          }

                                          final product = spotList[index];

                                          // فحص أن product صحيح
                                          if (product.id.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          return InkWell(
                                            onTap: () {
                                              try {
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
                                                          spotList: spotList,
                                                          selected: index,
                                                          key: UniqueKey(),
                                                          product: product,
                                                          vendorId: vendorId,
                                                        ),
                                                  ),
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                  'Error navigating to ProductDetails: $e',
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  !TranslationController
                                                          .instance
                                                          .isRTL
                                                      ? EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 22,
                                                        top: 8,
                                                        right:
                                                            index ==
                                                                    spotList.length -
                                                                        1
                                                                ? 14
                                                                : 0,
                                                      )
                                                      : EdgeInsets.only(
                                                        right: 14.0,
                                                        bottom: 22,
                                                        top: 8,
                                                        left:
                                                            index ==
                                                                    spotList.length -
                                                                        1
                                                                ? 14
                                                                : 0,
                                                      ),
                                              child: SizedBox(
                                                width: cardWidth,
                                                child:
                                                    ProductWidgetMediumFixedHeight(
                                                      prefferWidth: cardWidth,
                                                      prefferHeight: cardHeight,
                                                      product: product,
                                                      vendorId: vendorId,
                                                      editMode: editMode,
                                                    ),
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          debugPrint(
                                            'Error building product item at index $index: $e',
                                          );
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  );
                                }),
                              ),
                              // زر الإغلاق
                              GestureDetector(
                                onTap: controller.closeList,
                                child: Center(
                                  child: Container(
                                    width: 50,
                                    padding: const EdgeInsets.fromLTRB(
                                      5,
                                      7,
                                      5,
                                      7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_circle_up_sharp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : const SizedBox.shrink(),
                );
              }),
            ],
          );
    }
  }

  Stack addCategoryItem(int index, BuildContext context, String vendorId) {
    return Stack(
      alignment: Alignment.center,
      children: [
        InkWell(
          onTap: () {
            var controller = Get.put(CreateCategoryController());
            controller.deleteTempItems();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateCategory(
                      vendorId: vendorId,
                      // suggestingCategory:
                      //     category,
                    ),
              ),
            );
          },
          child: TRoundedContainer(
            showBorder: false,
            width: 70,
            height: 70,
            radius: BorderRadius.circular(100),
            enableShadow: true,
            child: const Center(
              child: Icon(CupertinoIcons.add, color: TColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  // حساب عرض الحاوية بناءً على عدد الفئات
  double _calculateCategoryContainerWidth() {
    final itemCount = CategoryController.instance.allItems.length;

    if (itemCount < 3) {
      // أقل من 3 فئات: عرض ثابت مع مسافات أكبر
      return 300.0;
    } else if (itemCount < 5) {
      // من 3 إلى 4 فئات: عرض متوسط مع مسافات متوسطة
      return 85.0 * itemCount + 50.0;
    } else {
      // 5 فئات أو أكثر: العرض الافتراضي
      return 85.0 * itemCount;
    }
  }

  // حساب المسافات بين الفئات بناءً على العدد
  EdgeInsets _calculateCategoryPadding() {
    final itemCount = CategoryController.instance.allItems.length;

    if (itemCount < 3) {
      // أقل من 3 فئات: مسافات كبيرة
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (itemCount < 5) {
      // من 3 إلى 4 فئات: مسافات متوسطة
      return const EdgeInsets.symmetric(horizontal: 10.0);
    } else {
      // 5 فئات أو أكثر: مسافات صغيرة
      return const EdgeInsets.symmetric(horizontal: 4.0);
    }
  }
}
