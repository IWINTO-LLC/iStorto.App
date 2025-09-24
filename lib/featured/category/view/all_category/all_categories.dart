import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';
import 'package:sizer/sizer.dart';

import 'widgets/category_list_item.dart';

class CategoryMobileScreen extends StatelessWidget {
  const CategoryMobileScreen({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    RxBool gridType = false.obs;

    return Directionality(
      textDirection:
          TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        floatingActionButton: SizedBox(
          width: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => FloatingActionButton(
                  backgroundColor: Colors.black.withValues(alpha: .5),
                  onPressed: () => gridType.value = !gridType.value,
                  child: SizedBox(
                    width: 30,
                    child: Icon(gridType.value ? Icons.grid_3x3 : Icons.list),
                  ),
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.black.withValues(alpha: .5),
                onPressed: () {
                  var controller = Get.put(CreateCategoryController());
                  controller.deleteTempItems();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CreateCategory(vendorId: vendorId);
                      },
                    ),
                  );
                },
                child: SizedBox(width: 30, child: Image.asset(TImages.add)),
              ),
            ],
          ),
        ),
        appBar: CustomAppBar(title: 'shop.allCategories'),
      ),
    );
  }
}

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.vendorId,
    required this.editMode,
  });
  final String vendorId;
  final bool editMode;
  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    var categories = controller.allItems;
    return Padding(
      padding: const EdgeInsets.only(left: 1.0, right: 1, top: 1, bottom: 70),
      child:
          controller.allItems.isEmpty
              ? Column(
                children: [
                  SizedBox(height: 50.w),
                  const TLoaderWidget(),
                  SizedBox(height: 10.w),
                  Text("No Data"),
                ],
              )
              : Obx(
                () => RefreshIndicator(
                  onRefresh: () async {
                    controller.fetchCategoryData();
                  },
                  child: TRoundedContainer(
                    child: ListView.separated(
                      separatorBuilder: (_, __) => Divider(),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder:
                          (_, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: TCategoryListItem(
                              category: categories[index],
                            ),
                          ),
                    ),
                  ),
                ),
              ),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.vendorId,
    required this.editMode,
  });
  final String vendorId;
  final bool editMode;
  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    var categories = controller.allItems;
    //controller.felteredItems;

    return Stack(
      children: [
        MasonryGridView.count(
          itemCount: categories.length,
          crossAxisCount: 5,
          mainAxisSpacing: 15,
          crossAxisSpacing: 7,
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return TCategoryGridItem(
              category: categories[index],
              editMode: false,
            );
          },
        ),
        Visibility(
          visible: editMode,
          child: Positioned(
            bottom: 15,
            right: TranslationController.instance.isRTL ? null : 7,
            left: TranslationController.instance.isRTL ? 7 : null,
            child: CustomFloatActionButton(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateCategory(
                            vendorId: vendorId,
                            // suggestingCategory:
                            //     category,
                          ),
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
