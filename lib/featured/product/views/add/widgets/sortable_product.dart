import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/all_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_small.dart';
import 'package:istoreto/utils/common/widgets/layout/grid_layout.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({super.key, required this.products});

  final List<ProductModel> products;
  @override
  Widget build(BuildContext context) {
    //final isEg = Get.locale?.languageCode == 'en';
    final controller = Get.put(AllProductController());
    controller.assignProducts(products);
    return Column(
      children: [
        DropdownButtonFormField(
          value: controller.selectedSortOption.value,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.sort)),
          items:
              [
                    'Name',
                    //AppLocalizations.of(Get.context!)!.name,
                    'Higher price',
                    'Lower price',
                    'Sale',
                  ]
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
          onChanged: (value) {
            controller.sortProducts(value!);
          },
        ),
        const SizedBox(height: TSizes.spaceBtWsections),
        Obx(
          () => TGridLayout(
            //  maxAxisExtent: 500,
            itemCount: controller.products.length,
            itemBuilder:
                (_, index) => ProductWidgetSmall(
                  product: controller.products[index],
                  vendorId: controller.products[index].vendorId!,
                ),
          ),
        ),
      ],
    );
  }
}
