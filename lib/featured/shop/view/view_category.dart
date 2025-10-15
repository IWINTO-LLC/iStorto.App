import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium_fixed_height.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

Widget viewCategories({
  required bool editMode,
  required String vendorId,
  required BuildContext context,
}) {
  var controller = ProductController.instance;

  // التأكد من تحميل الفئات للتاجر الحالي (مرة واحدة فقط)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (CategoryController.instance.lastFetchedUserId != vendorId) {
      print("🔄 viewCategories: Loading categories for vendor: $vendorId");
      CategoryController.instance.getCategoryOfVendor(vendorId);
    } else {
      print(
        "✅ viewCategories: Categories already loaded for vendor: $vendorId",
      );
    }
  });

  var cardWidth = 40.w;
  var cardHeight = 40.w * (4 / 3);

  // إظهار مؤشر التحميل إذا كانت البيانات في حالة التحميل
  if (CategoryController.instance.load.value) {
    print("🔄 viewCategories: Showing loading indicator");
    return Column(
      children: [
        Container(
          color: Colors.transparent,
          height: 86,
          child: const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // طباعة معلومات التصحيح
  print("🔍 viewCategories: Building UI");
  print("🔍 Categories count: ${CategoryController.instance.allItems.length}");
  print("🔍 Edit mode: $editMode");
  print("🔍 Vendor ID: $vendorId");

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

                          return Row(
                            children: [
                              if (index == 0) const SizedBox(width: 5),
                              GestureDetector(
                                onTap:
                                    () => controller.selectCategory(
                                      CategoryController
                                          .instance
                                          .allItems[index],
                                      vendorId,
                                    ),
                                child: Obx(
                                  () => TCategoryGridItem(
                                    category:
                                        CategoryController
                                            .instance
                                            .allItems[index],
                                    editMode: editMode,
                                    selected:
                                        controller.selectedCategory.value ==
                                        CategoryController
                                            .instance
                                            .allItems[index],
                                  ),
                                ),
                              ),
                            ],
                          );
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
                                    itemBuilder:
                                        (context, index) => InkWell(
                                          onTap: () {
                                            Get.toNamed(
                                              '/product-details',
                                              arguments: {
                                                'product': spotList[index],
                                                'vendorId': vendorId,
                                                'selected': index,
                                                'spotList': spotList,
                                              },
                                            );
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
                                                    product: spotList[index],
                                                    vendorId: vendorId,
                                                    editMode: editMode,
                                                  ),
                                            ),
                                          ),
                                        ),
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
                width: 95 * (CategoryController.instance.allItems.length + 0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: CategoryController.instance.allItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap:
                          () => controller.selectCategory(
                            CategoryController.instance.allItems[index],
                            vendorId,
                          ),
                      child: Obx(
                        () => Padding(
                          padding:
                              CategoryController.instance.allItems.length < 5
                                  ? const EdgeInsets.symmetric(horizontal: 5.0)
                                  : const EdgeInsets.symmetric(horizontal: 1),
                          child: TCategoryGridItem(
                            category:
                                CategoryController.instance.allItems[index],
                            editMode: editMode,
                            selected:
                                controller.selectedCategory.value ==
                                CategoryController.instance.allItems[index],
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                                    itemBuilder:
                                        (context, index) => InkWell(
                                          onTap: () {
                                            Get.toNamed(
                                              '/product-details',
                                              arguments: {
                                                'product': spotList[index],
                                                'vendorId': vendorId,
                                                'selected': index,
                                                'spotList': spotList,
                                              },
                                            );
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
                                            child: InkWell(
                                              onTap: () {
                                                Get.toNamed(
                                                  '/product-details',
                                                  arguments: {
                                                    'product': spotList[index],
                                                    'vendorId': vendorId,
                                                    'selected': index,
                                                    'spotList': spotList,
                                                  },
                                                );
                                              },
                                              child: SizedBox(
                                                width: cardWidth,
                                                child:
                                                    ProductWidgetMediumFixedHeight(
                                                      prefferWidth: cardWidth,
                                                      prefferHeight: cardHeight,
                                                      product: spotList[index],
                                                      vendorId: vendorId,
                                                      editMode: editMode,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
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
          Get.toNamed('/create-category', arguments: {'vendorId': vendorId});
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
