import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/shemmer/product_horizental_list_shimmer.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_small.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class AllProducts extends StatelessWidget {
  const AllProducts({
    super.key,
    required this.title,
    this.futureMethode,
    required this.editMode,
    required this.vendorId,
    this.categoryId = '',
  });

  final String title;
  final bool editMode;

  final String categoryId;
  final String vendorId;
  final Future<List<ProductModel>>? futureMethode;

  // Get ProductRepository instance
  ProductRepository get _productRepository => Get.find<ProductRepository>();

  // Get products based on category or vendor
  Future<List<ProductModel>> _getProducts() async {
    try {
      if (categoryId.isNotEmpty) {
        // Get products by category
        return await _productRepository.getProductsByCategory(
          categoryId: categoryId,
          vendorId: vendorId,
        );
      } else {
        // Get all products for vendor
        return await _productRepository.getProductsByVendor(vendorId);
      }
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBar(title: title),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(TSizes.defaultSpace),
              child: FutureBuilder<List<ProductModel>>(
                future: _getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const TProductHorizentalShimmer();
                  }
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        const TShimmerEffectdark(width: 120, height: 180),
                        if (editMode)
                          Column(
                            children: [
                              InkWell(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CreateProduct(
                                              initialList: [],
                                              sectorTitle: SectorModel(
                                                id: '',
                                                englishName: '',
                                                name: '',
                                                vendorId: '',
                                              ),
                                              vendorId: vendorId,
                                              type: '',
                                              sectionId: 'all',
                                            ),
                                      ),
                                    ),
                                child: const Icon(Icons.add, size: 30),
                              ),
                              const SizedBox(height: 4),
                              Text('product.add_item'.tr, style: titilliumBold),
                            ],
                          ),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'common.something_went_wrong'.tr,
                        style: robotoMedium,
                      ),
                    );
                  }
                  final products = snapshot.data!;

                  // .where((p) =>
                  //     int.parse(ProductController.instance
                  //         .calculateSalePresentage(
                  //             p.price, p.salePrice)!) >
                  //     0)
                  // .take(8);
                  // .toList();

                  if (products.isEmpty) {
                    return editMode
                        ? Column(
                          children: [
                            InkWell(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CreateProduct(
                                            initialList: [],
                                            sectorTitle: SectorModel(
                                              id: '',
                                              englishName: '',
                                              name: '',
                                              vendorId: '',
                                            ),
                                            vendorId: vendorId,
                                            type: '',
                                            sectionId: 'all',
                                          ),
                                    ),
                                  ),
                              child: const Icon(Icons.add, size: 30),
                            ),
                            const SizedBox(height: 4),
                            Text('product.add_item'.tr, style: titilliumBold),
                          ],
                        )
                        : const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 10),
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder:
                              (_, index) => SizedBox(
                                width: 120,
                                child: ProductWidgetSmall(
                                  product: products[index],
                                  vendorId: vendorId,
                                ),
                              ),
                        ),
                      ),
                    ],
                  );

                  //return TSortableProducts(products: products);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
