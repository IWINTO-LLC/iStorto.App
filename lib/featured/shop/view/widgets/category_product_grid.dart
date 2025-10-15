import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_small.dart';

import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class TCategoryProductGrid extends StatelessWidget {
  TCategoryProductGrid({
    super.key,
    required this.editMode,
    required this.product,
    required this.userId,
  });
  final ProductModel product;
  final bool editMode;
  final String userId;

  final Rx<CategoryModel> selectedCategory = CategoryModel.empty().obs;
  @override
  Widget build(BuildContext context) {
    if (product.category == null) {
      return const SizedBox.shrink();
    }
    var category = product.category!;
    final controller = CategoryController.instance;
    if (product.category == null) {
      return const SizedBox(); // أو رسالة مناسبة
    }

    //  RxList<ProductModel> offersItems = <ProductModel>[].obs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 35,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'search.search'.tr,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  controller: controller.searchTextController,
                  onChanged: (query) => controller.searchQuery(query),
                  style: robotoSmallTitleRegular,
                ),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtWItems),
          // Text(userId.toString()),
          // Text(category.id.toString()),
          Visibility(
            visible: true,
            child: FutureBuilder(
              future: controller.getCategoryProduct(
                categoryId: category.id!,
                userId: userId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: TLoaderWidget()),
                  );
                }
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Stack(
                    alignment: Alignment.center,
                    children: [TShimmerEffectdark(width: 120, height: 180)],
                  );
                }

                var items = snapshot.data!;
                List<ProductModel> products = [];
                products.assignAll(items.where((p) => p.id != product.id));

                //  offersItems.assignAll(items.where((p) => p.oldPrice! > 0));
                // .where((p) =>
                //     int.parse(ProductController.instance
                //         .calculateSalePresentage(
                //             p.price, p.salePrice)!) >
                //     0)
                // .take(8);
                // .toList();

                if (products.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            Text(
                              'more_from_this_shop'.tr,
                              style: titilliumBold.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: .5,
                              ),
                            ),
                          ],
                        ),
                        TCustomWidgets.buildDivider(),
                        MasonryGridView.count(
                          itemCount: products.length,
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          padding: const EdgeInsets.all(0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(
                              children: [
                                SizedBox(
                                  width: 30.w,
                                  height: 30.w * (4 / 3) + 100,
                                  child: ActionsMethods.customLongMethode(
                                    products[index],
                                    context,
                                    VendorController.instance.isVendor.value,
                                    ProductWidgetSmall(
                                      product: products[index],
                                      vendorId: products[index].vendorId ?? '',
                                    ),
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProductDetails(
                                                product: product,
                                                selected: index,
                                                vendorId:
                                                    product.vendorId ?? '',
                                                spotList: products,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
                //return TSortableProducts(products: products);
              },
            ),
          ),

          const SizedBox(height: TSizes.spaceBtWsections),
        ],
      ),
    );
  }
}
