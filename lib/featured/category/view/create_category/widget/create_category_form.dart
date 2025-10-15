import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/controllers/create_category_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/featured/shop/controllers/vendor_categories_controller.dart';
import 'image_uploader.dart';

class CreateCategoryForm extends StatelessWidget {
  const CreateCategoryForm({super.key, required this.vendorId});
  final String vendorId;

  /// حساب النسبة المئوية للتقدم بناءً على رسالة الحالة
  int _getProgressPercentage(String message) {
    // دعم مفاتيح الترجمة والقيم المحلية السابقة
    final loadingTr = 'loading'.tr;
    final savingTr = 'saving'.tr;
    final uploadingPhotoKey = 'uploading_photo';
    final uploadingPhotoTr = 'uploading_photo'.tr;
    final sendingDataKey = 'sending_data';
    final sendingDataTr = 'sending_data'.tr;
    final doneKey = 'everything_done';
    final doneTr = 'everything_done'.tr;

    if (message.contains(loadingTr) ||
        message.contains(savingTr) ||
        message.contains(uploadingPhotoKey) ||
        message.contains(uploadingPhotoTr) ||
        message.contains('جاري التحضير')) {
      return 10;
    } else if (message.contains(uploadingPhotoKey) ||
        message.contains(uploadingPhotoTr) ||
        message.contains('جاري رفع الصورة') ||
        message.contains('رفع الصورة')) {
      return 30;
    } else if (message.contains('جاري إعداد البيانات')) {
      return 50;
    } else if (message.contains(sendingDataKey) ||
        message.contains(sendingDataTr) ||
        message.contains('جاري إرسال البيانات')) {
      return 70;
    } else if (message.contains('جاري تحديث القوائم')) {
      return 85;
    } else if (message.contains(doneKey) ||
        message.contains(doneTr) ||
        message.contains('تم إنشاء الفئة بنجاح')) {
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
                  TCustomWidgets.buildLabel('${'category'.tr} *'),
                  TextFormField(
                    style: titilliumBold.copyWith(fontSize: 18),
                    controller: createController.name,
                    validator: (value) {
                      if (value == null || value == '') {
                        return 'common.required'.tr;
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

              // حقل إدخال وصف الفئة (اختياري)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TCustomWidgets.buildLabel(
                    '${'description'.tr} (${'optional'.tr})',
                  ),
                  TextFormField(
                    style: titilliumRegular.copyWith(fontSize: 16),
                    controller: createController.description,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding:
                          TranslationController.instance.isRTL
                              ? EdgeInsets.only(right: 5)
                              : EdgeInsets.only(left: 5),
                      hintText: 'category_description_hint'.tr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TCustomWidgets.buildLabel('product.image'.tr),
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
                            radius: BorderRadius.circular(30),
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TImageUploader(
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
                          onIconButtonPressed:
                              () => createController.pickImage(),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                createController.localImage.value = '';
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                  'saving'.tr,
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
                                  : 'loading'.tr,
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
                              ? 'saving'.tr
                              : 'post'.tr,
                      onTap:
                          createController.isUploading.value
                              ? null
                              : () async {
                                // التحقق من صحة النموذج أولاً
                                final isValidForm =
                                    createController.formKey.currentState
                                        ?.validate() ??
                                    false;
                                if (!isValidForm) {
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

                                // التحقق من vendorId
                                if (vendorId.isEmpty) {
                                  Get.snackbar(
                                    'error'.tr,
                                    'user_data_error'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                try {
                                  createController.isUploading.value = true;
                                  createController.message.value = 'loading'.tr;

                                  await createController.createCategory(
                                    vendorId,
                                  );

                                  // تحديث قائمة الفئات في الصفحة بدون الرجوع
                                  if (Get.isRegistered<
                                    VendorCategoriesController
                                  >()) {
                                    await VendorCategoriesController.instance
                                        .refreshCategories();
                                  }

                                  // إشعار نجاح وإعادة تهيئة الحالة
                                  Get.snackbar(
                                    'success'.tr,
                                    'everything_done'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );

                                  createController.isUploading.value = false;
                                  createController.message.value = '';
                                } catch (e) {
                                  createController.message.value =
                                      'حدث خطأ: $e';

                                  // عرض رسالة خطأ للمستخدم
                                  Get.snackbar(
                                    'error'.tr,
                                    '${'category_creation_error'.tr}: $e',
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
                ? SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        ...controller.tempItems.map((vc) {
                          final temp = CategoryModel(
                            id: vc.id,
                            vendorId: vc.vendorId,
                            title: vc.title,
                            icon: controller.imageUrl.value,
                            isActive: true,
                            sortOrder: 0,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 90,
                              child: TCategoryGridItem(
                                category: temp,
                                editMode: false,
                                selected: false,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
