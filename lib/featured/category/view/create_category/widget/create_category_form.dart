import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/category/view/edit_category/edit_category.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'image_uploader.dart';

class CreateCategoryForm extends StatelessWidget {
  CreateCategoryForm({super.key});

  /// حساب النسبة المئوية للتقدم بناءً على رسالة الحالة
  int _getProgressPercentage(String message) {
    if (message.contains('جاري التحضير') ||
        message.contains('uploading_photo')) {
      return 10;
    } else if (message.contains('جاري رفع الصورة') ||
        message.contains('رفع الصورة')) {
      return 30;
    } else if (message.contains('جاري إعداد البيانات')) {
      return 50;
    } else if (message.contains('جاري إرسال البيانات') ||
        message.contains('sending_data')) {
      return 70;
    } else if (message.contains('جاري تحديث القوائم')) {
      return 85;
    } else if (message.contains('تم إنشاء الفئة بنجاح') ||
        message.contains('everything_done')) {
      return 100;
    }
    return 0;
  }

  /// حساب قيمة التقدم (0.0 إلى 1.0)
  double _getProgressValue(String message) {
    return _getProgressPercentage(message) / 100.0;
  }

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
              // شريط تقدم النسبة المئوية
              Obx(() {
                return Column(
                  children: [
                    if (createController.isUploading.value ||
                        createController.message.value.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'جاري المعالجة...',
                                  style: titilliumBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${_getProgressPercentage(createController.message.value)}%',
                                  style: titilliumBold.copyWith(
                                    fontSize: 16,
                                    color: TColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: _getProgressValue(
                                createController.message.value,
                              ),
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                TColors.primary,
                              ),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              createController.message.value.isNotEmpty
                                  ? createController.message.value
                                  : 'جاري التحضير...',
                              style: titilliumRegular.copyWith(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    CustomButtonBlack(
                      text:
                          createController.isUploading.value
                              ? 'جاري المعالجة...'
                              : 'post'.tr,
                      onTap:
                          createController.isUploading.value
                              ? null
                              : () async {
                                // التحقق من صحة النموذج أولاً
                                if (!createController.formKey.currentState!
                                    .validate()) {
                                  return;
                                }

                                // التحقق من وجود صورة
                                if (createController.localImage.value.isEmpty) {
                                  Get.snackbar(
                                    'error'.tr,
                                    'category_image_required'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                try {
                                  createController.isUploading.value = true;
                                  createController.message.value =
                                      'جاري التحضير...';

                                  await createController.createCategory(
                                    VendorController
                                        .instance
                                        .profileData
                                        .value
                                        .id!,
                                  );

                                  // إغلاق الصفحة وإرجاع نتيجة نجاح
                                  Navigator.pop(context, true);
                                } catch (e) {
                                  createController.message.value =
                                      'حدث خطأ: $e';

                                  // عرض رسالة خطأ للمستخدم
                                  Get.snackbar(
                                    'error'.tr,
                                    'category_creation_error'.tr + ': $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );

                                  // إعادة تفعيل الزر بعد ثانيتين
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      createController.isUploading.value =
                                          false;
                                      createController.message.value = '';
                                    },
                                  );
                                }
                              },
                    ),
                  ],
                );
              }),
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
