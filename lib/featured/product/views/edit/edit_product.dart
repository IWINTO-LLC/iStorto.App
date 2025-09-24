import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/edit/widgets/edit_product_form.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

class EditProduct extends StatelessWidget {
  const EditProduct({
    super.key,
    required this.product,
    required this.vendorId,
    this.isTemp = false,
  });
  final ProductModel product;
  final String vendorId;
  final bool isTemp;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Edit_Item'.tr),
        body: SafeArea(
          child: EditProductForm(
            product: product,
            vendorId: vendorId,
            isTemp: isTemp,
          ),
        ),
      ),
    );
  }
}
