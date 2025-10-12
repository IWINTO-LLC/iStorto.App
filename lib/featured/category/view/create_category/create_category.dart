import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

import 'widget/create_category_form.dart';

class CreateCategory extends StatelessWidget {
  const CreateCategory({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TranslationController.instance.isRTL
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBar(title: 'addNewCategory'.tr),
        body: SafeArea(child: CreateCategoryForm(vendorId: vendorId)),
      ),
    );
  }
}
