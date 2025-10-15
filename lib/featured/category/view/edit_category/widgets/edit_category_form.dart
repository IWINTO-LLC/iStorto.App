import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/edit_category_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/category/view/create_category/widget/image_uploader.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';
import 'package:istoreto/utils/validators/validator.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

class EditCategoryForm extends StatelessWidget {
  const EditCategoryForm({super.key, required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final editController = EditCategoryController.instance;
    editController.init(category);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: editController.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: TSizes.appBarHeight),

              const SizedBox(height: TSizes.spaceBtWsections),

              TCustomWidgets.buildLabel('Image'.tr),

              Center(
                child: Obx(
                  () => TImageUploader(
                    circuler: true,
                    imageType:
                        editController.localImage.isNotEmpty
                            ? ImageType.file
                            : category.icon!.isNotEmpty
                            ? ImageType.network
                            : ImageType.asset,
                    width: 100,
                    height: 100,
                    image:
                        editController.localImage.isNotEmpty
                            ? editController.localImage.value
                            : category.icon!.isNotEmpty
                            ? category.icon!
                            : TImages.imagePlaceholder,
                    onIconButtonPressed: () => editController.pickImage(),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwInputFields),

              // حقل تعديل اسم الفئة
              TCustomWidgets.buildLabel('categoryName'.tr),
              TextFormField(
                controller: editController.name,
                validator:
                    (value) =>
                        TValidator.validateEmptyText('category name', value),
                decoration: InputDecoration(
                  hintText: 'Enter category name'.tr,
                  labelStyle: titilliumSemiBold,
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwInputFields),

              const SizedBox(height: TSizes.spaceBtwInputFields * 2),
              CustomButtonBlack(
                text: 'Post'.tr,
                onTap: () async {
                  // editController.updateCategory(category);

                  await showSimpleLoadingDialog<String>(
                    context: context,
                    future: () async {
                      await editController.updateCategory(category);
                      return "updated1";
                    },
                    // Custom dialog
                    dialogBuilder: (context, _) {
                      return AlertDialog(
                        content: Obx(
                          () => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              const TLoaderWidget(),
                              const SizedBox(height: 16),
                              Text(editController.message.value),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
