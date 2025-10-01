import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/constants/color.dart';

import 'widgets/create_product_form.dart';

class CreateProduct extends GetView<ProductController> {
  const CreateProduct({
    super.key,
    required this.sectionId,
    required this.type,
    required this.vendorId,
    required this.initialList,
    required this.sectorTitle,
    this.viewCategory = true,
  });

  final String vendorId;
  final String sectionId;
  final SectorModel sectorTitle;
  final bool viewCategory;
  final String type;
  final List<ProductModel> initialList;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          !TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Item'.tr),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: TColors.primary),
            onPressed: () => Get.back(),
          ),
          actions: [
            Obx(() {
              final hasChanges = controller.hasChanges.value;

              return AnimatedOpacity(
                opacity: hasChanges ? 1.0 : 0.4,
                duration: Duration(milliseconds: 300),
                child: TextButton.icon(
                  onPressed:
                      hasChanges
                          ? () async {
                            await controller.createProduct(
                              type,
                              vendorId,
                              title: controller.title.text.trim(),
                              description: controller.description.text.trim(),
                              minQuantity:
                                  int.tryParse(
                                    controller.minQuantityController.text,
                                  ) ??
                                  1,
                            );
                          }
                          : null,
                  icon: Icon(
                    Icons.check,
                    color: hasChanges ? Colors.green : Colors.grey,
                  ),
                  label: Text(
                    'product.publish'.tr,
                    style: TextStyle(
                      color: hasChanges ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        body: SafeArea(
          child: CreateProductForm(
            vendorId: vendorId,
            initialList: initialList,
            type: type,
            sectorTitle: sectorTitle,
            viewCategory: viewCategory,
          ),
        ),
      ),
    );
  }
}
