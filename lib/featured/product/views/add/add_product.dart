import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
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
        appBar: CustomAppBar(
          title: 'Add Item'.tr,
          icon: Icons.reply,
          iconColor: TColors.primary,
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
