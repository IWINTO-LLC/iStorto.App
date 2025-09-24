import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/category/view/edit_category/edit_category.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';
import 'image_uploader.dart';

class CreateCategoryForm extends StatelessWidget {
  CreateCategoryForm({super.key});
  @override
  Widget build(BuildContext context) {
    final createController = Get.put(CreateCategoryController());
    return SingleChildScrollView(
      child: Form(
        key: createController.formKey,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: TSizes.appBarHeight),
              viewTempCategory(),
              // حقل إدخال اسم الفئة
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: TSizes.sm),
                  TCustomWidgets.buildLabel('${'Category'.tr} *'),
                  TextFormField(
                    style: titilliumBold.copyWith(fontSize: 18),
                    controller: createController.name,
                    validator: (value) {
                      if (value == null || value == '') {
                        return "required".tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          TranslationController.instance.isRTL
                              ? EdgeInsets.only(right: 5)
                              : EdgeInsets.only(left: 5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TCustomWidgets.buildLabel('Image'.tr),
              Obx(
                () => Visibility(
                  visible: createController.localImage.isEmpty,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => createController.pickImage(),
                      child: Center(
                        child: Visibility(
                          visible: createController.localImage.isEmpty,
                          child: TRoundedContainer(
                            width: 60,
                            height: 60,
                            showBorder: true,
                            radius: BorderRadius.circular(50),
                            child: Center(
                              child: Icon(CupertinoIcons.photo_fill, size: 30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: createController.localImage.isNotEmpty,
                  child: Center(
                    child: TImageUploader(
                      circuler: true,
                      imageType:
                          createController.localImage.isNotEmpty
                              ? ImageType.file
                              : ImageType.asset,
                      width: 150,
                      height: 150,
                      image:
                          createController.localImage.isNotEmpty
                              ? createController.localImage.value
                              : TImages.imagePlaceholder,
                      onIconButtonPressed: () => createController.pickImage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              CustomButtonBlack(
                text: 'post'.tr,
                onTap: () async {
                  await showSimpleLoadingDialog<String>(
                    context: context,
                    future: () async {
                      await createController.createCategory();
                      return "add category done";
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
                              Text(
                                createController.message.value,
                                style: titilliumBold,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Center viewTempCategory() {
    var controller = CreateCategoryController.instance;
    return Center(
      child: Obx(
        () =>
            controller.tempItems.isNotEmpty
                ? Container(
                  color: Colors.transparent,
                  height: 120,
                  width: 85 * (controller.tempItems.length + 0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.tempItems.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditCategory(
                                      category: controller.tempItems[index],
                                    ),
                              ),
                            ),
                        child: TCategoryGridItem(
                          category: controller.tempItems[index],
                          editMode: false,
                        ),
                      );
                    },
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
