import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

import 'widgets/edit_category_form.dart';

class EditCategory extends StatelessWidget {
  EditCategory({super.key, required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TranslationController.instance.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'updateCategory'.tr ,
        ),
        body: SafeArea(child: EditCategoryForm(category: category)),
      ),
    );
  }
}
