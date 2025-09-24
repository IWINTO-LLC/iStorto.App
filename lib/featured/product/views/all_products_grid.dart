import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/all_products_list.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_small.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key, required this.vendorId});
  final String vendorId;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    return Directionality(
      textDirection:
          TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.black.withValues(alpha: .5),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsList(vendorId: vendorId),
                      ),
                    ),
                child: SizedBox(width: 30, child: Icon(Icons.list)),
              ),
            ),
            SizedBox(
              width: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.black.withValues(alpha: .5),
                onPressed: () {
                  controller.tempProducts = <ProductModel>[].obs;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateProduct(
                            initialList: [],
                            vendorId: vendorId,
                            sectorTitle: SectorModel.empty(),
                            type: '',
                            sectionId: 'all',
                          ),
                    ),
                  );
                },
                child: SizedBox(width: 30, child: Image.asset(TImages.add)),
              ),
            ),
          ],
        ),
        appBar: CustomAppBar(title: 'shop.products'.tr),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchdata(vendorId);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: TSizes.sm,
                right: TSizes.sm,
                top: TSizes.sm,
                bottom: 100, // إضافة مساحة أسفل للـ FloatingActionButton
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const TLoaderWidget();
                }

                return ProductTableGrid(vendorId: vendorId);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductTableGrid extends StatelessWidget {
  const ProductTableGrid({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    // controller.fetchdata(vendorId);
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child:
          controller.allItems.isEmpty
              ? Column(
                children: [
                  SizedBox(height: 50.w),
                  const TLoaderWidget(),
                  SizedBox(height: 10.w),
                  Text('common.no_data'.tr),
                ],
              )
              : Obx(
                () => MasonryGridView.count(
                  itemCount: controller.allItems.length,
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 8,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        ProductWidgetSmall(
                          product: controller.allItems[index],
                          vendorId: controller.allItems[index].vendorId ?? '',
                        ),
                      ],
                    );
                  },
                ),
              ),
    );
  }
}
