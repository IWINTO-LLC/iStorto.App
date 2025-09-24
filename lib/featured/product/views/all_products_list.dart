import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/all_products_grid.dart';
import 'package:istoreto/featured/product/views/widgets/product_item.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({super.key, required this.vendorId});
  final String vendorId;

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  late ProductController controller;
  late ProductRepository productRepository;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductController());
    productRepository = Get.put(ProductRepository());
    controller.fetchdata(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
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
                        builder:
                            (context) =>
                                ProductsGrid(vendorId: widget.vendorId),
                      ),
                    ),
                child: const SizedBox(
                  width: 30,
                  child: Icon(CupertinoIcons.grid),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.black.withValues(alpha: .5),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CreateProduct(
                              initialList: [],
                              vendorId: widget.vendorId,
                              sectorTitle: SectorModel(
                                id: '',
                                englishName: '',
                                name: '',
                                vendorId: '',
                              ),
                              type: '',
                              sectionId: 'all',
                            ),
                      ),
                    ),
                child: SizedBox(width: 30, child: Image.asset(TImages.add)),
              ),
            ),
          ],
        ),
        appBar: CustomAppBar(title: 'shop.products'.tr),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchdata(widget.vendorId);
              setState(() {});
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.sm),
                child: Column(
                  children: [
                    TRoundedContainer(
                      child: Column(
                        children: [ProductsTable(vendorId: widget.vendorId)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductsTable extends StatelessWidget {
  const ProductsTable({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: FutureBuilder<List<ProductModel>>(
        future: ProductRepository.instance.getProductsByVendor(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                SizedBox(height: 50.w),
                const TLoaderWidget(),
                SizedBox(height: 10.w),
                Text('common.loading_data'.tr),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('common.something_went_wrong'.tr));
          } else {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text('product.add_product_here'.tr));
            } else {
              return Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TRoundedContainer(
                    child: ListView.separated(
                      separatorBuilder:
                          (_, __) => const Divider(color: TColors.grey),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.allItems.length,
                      itemBuilder:
                          (_, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: TProductItem(
                              product: controller.allItems[index],
                            ),
                          ),
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
