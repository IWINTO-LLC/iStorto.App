import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/product/controllers/image_crop_rotation_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/controllers/scrolle_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_xsmall.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/validators/validator.dart';

class CreateProductForm extends StatelessWidget {
  CreateProductForm({
    super.key,
    required this.type,
    required this.initialList,
    required this.sectorTitle,
    required this.vendorId,
    required this.viewCategory,
  });
  // CategoryModel? suggestingCategory;

  final String vendorId;
  final String type;
  final bool viewCategory;
  final SectorModel sectorTitle;
  final List<ProductModel> initialList;

  // كنترولرز للعنوان والوصف فقط
  // final TextEditingController titleController = TextEditingController();
  // final TextEditingController descriptionController = TextEditingController();
  // final TextEditingController minQuantityController = TextEditingController(text: '1');

  // دالة لفتح معاينة الصور المرفوعة
  void _openImagePreview(
    BuildContext context,
    ProductController controller, {
    int? initialIndex,
  }) {
    if (controller.selectedImage.isEmpty) return;

    // تحويل XFile إلى File
    List<File> imageFiles =
        controller.selectedImage.map((xFile) => File(xFile.path)).toList();

    showFullscreenImage(
      context: context,
      images: imageFiles,
      initialIndex: initialIndex ?? 0,
      showDeleteButton: true,
      showEditButton: true,
      onDelete: (index) {
        // حذف الصورة من القائمة
        controller.selectedImage.removeAt(index);
        // إغلاق المعاينة بعد الحذف
        Navigator.pop(context);
      },
      onSave: (File processedFile, int index) {
        // استبدال الصورة الأصلية بالصورة المعدلة
        controller.selectedImage[index] = XFile(processedFile.path);
        // تحديث الواجهة لتعكس التغييرات بطريقة أكثر فعالية
        controller.selectedImage.value = List.from(controller.selectedImage);
        // إظهار رسالة تأكيد الحفظ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image saved successfully'.tr,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        // لا نغلق المعاينة بعد الحفظ - يبقى المستخدم في وضعية التعديل
        // Navigator.pop(context); // تم إزالة هذا السطر
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 8;
    final ScrolleEditController scrolleController = Get.put(
      ScrolleEditController(),
    );
    var addCat = CategoryModel(title: "menu.add_category".tr);

    final controller = ProductController.instance;
    controller.spotList.value = initialList;

    // Setup listeners for changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.title.addListener(() => controller.checkForChanges());
      controller.description.addListener(() => controller.checkForChanges());
      controller.minQuantityController.addListener(
        () => controller.checkForChanges(),
      );
      controller.price.addListener(() => controller.checkForChanges());
      controller.saleprecentage.addListener(() => controller.checkForChanges());
      controller.oldPrice.addListener(() => controller.checkForChanges());
      controller.selectedImage.listen((_) => controller.checkForChanges());
    });

    return SingleChildScrollView(
      controller: scrolleController.scrollController,
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Obx(
              () =>
                  controller.spotList.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: TCustomWidgets.buildTitle(
                          sectorTitle.englishName,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            Obx(
              () =>
                  controller.spotList.isNotEmpty
                      ? SizedBox(
                        height: 285,
                        child: ListView.builder(
                          // padding: EdgeInsets.symmetric(vertical: 5),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.spotList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  !TranslationController.instance.isRTL
                                      ? EdgeInsets.only(
                                        left: padding,
                                        bottom: 20,
                                        right:
                                            index ==
                                                    controller.spotList.length -
                                                        1
                                                ? padding
                                                : 0,
                                      )
                                      : EdgeInsets.only(
                                        right: padding,
                                        bottom: 20,
                                        left:
                                            index ==
                                                    controller.spotList.length -
                                                        1
                                                ? padding
                                                : 0,
                                      ),
                              child: SizedBox(
                                width: 127,
                                height: 127 * (4 / 3) + 10,
                                child: ActionsMethods.customLongMethode(
                                  controller.spotList[index],
                                  context,
                                  true,
                                  ProductWidgetXSmall(
                                    product: controller.spotList[index],
                                    vendorId: vendorId,
                                  ),
                                  () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 1000,
                                        ),
                                        pageBuilder:
                                            (context, anim1, anim2) =>
                                                ProductDetails(
                                                  key: UniqueKey(),
                                                  selected: index,
                                                  spotList: controller.spotList,
                                                  product:
                                                      controller
                                                          .spotList[index],
                                                  vendorId: vendorId,
                                                ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            // ====== حقول العنوان والوصف فقط ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TCustomWidgets.buildLabel('product.title'.tr),
                  TextFormField(
                    controller: controller.title,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'validation.required'.tr
                                : null,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TCustomWidgets.buildLabel('product.description'.tr),
                  TextFormField(
                    controller: controller.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TCustomWidgets.buildLabel('product.minimum_quantity'.tr),
                  TextFormField(
                    controller: controller.minQuantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'validation.required'.tr;
                      final n = int.tryParse(value);
                      if (n == null || n < 1)
                        return 'validation.minimum_one'.tr;
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // TCustomWidgets.buildDivider(),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            Row(
              children: [
                const SizedBox(width: 8),
                TCustomWidgets.buildLabel('product.category'.tr),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  CategoryController.instance.isLoading.value
                      ? const TShimmerEffect(width: double.infinity, height: 55)
                      : Center(
                        child: SizedBox(
                          height: 80,
                          child: Obx(() {
                            final items =
                                CategoryController.instance.allItems.map((cat) {
                                    return DropdownMenuItem(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              300,
                                            ),
                                            child: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    int.parse(
                                                      cat.color.replaceFirst(
                                                        '#',
                                                        '0xff',
                                                      ),
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        300,
                                                      ),
                                                ),
                                                child:
                                                    cat.icon != null
                                                        ? Icon(
                                                          Icons.category,
                                                          color: Colors.white,
                                                          size: 20,
                                                        )
                                                        : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            cat.title,
                                            style: titilliumRegular.copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                  ..add(
                                    DropdownMenuItem(
                                      value: addCat,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.add,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "menu.add_category".tr,
                                            style: titilliumRegular.copyWith(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                            // إزالة العناصر المكررة والتأكد من وجود القيمة المحددة
                            final uniqueItems = items.toSet().toList();

                            // البحث عن القيمة المحددة في العناصر الفريدة
                            CategoryModel? selected;
                            if (CategoryController
                                .instance
                                .allItems
                                .isNotEmpty) {
                              try {
                                final selectedItem = uniqueItems.firstWhere(
                                  (item) =>
                                      item.value?.id == controller.category.id,
                                );
                                selected = selectedItem.value;
                              } catch (e) {
                                // إذا لم توجد القيمة، اختر العنصر الأول
                                selected =
                                    uniqueItems.isNotEmpty
                                        ? uniqueItems.first.value
                                        : null;
                              }
                            }
                            return DropdownButtonFormField<CategoryModel>(
                              borderRadius: BorderRadius.circular(15),
                              iconSize: 40,

                              itemHeight: 60,
                              value: selected,
                              items: uniqueItems,
                              onChanged: (newValue) {
                                if (newValue == addCat) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CreateCategory(
                                            vendorId: vendorId,
                                          ),
                                    ),
                                  );
                                } else if (newValue != null) {
                                  controller.category = newValue;
                                }
                              },
                            );
                          }),
                        ),
                      ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),
            TCustomWidgets.buildDivider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 14),
                  TCustomWidgets.buildLabel('product.currency'.tr),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Container(), //currentCurrencyWidget(),
                  ),
                  const SizedBox(width: 14),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder:
                        //         (context) => VendorSettingsPage(
                        //           fromBage: 'add',
                        //           vendorId: vendorId,
                        //         ),
                        //   ),
                        // );
                      },
                      child: Row(
                        children: [
                          Text(
                            'info.changeHere'.tr,
                            style: titilliumBold.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 14),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: Icon(
                              CupertinoIcons.right_chevron,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TCustomWidgets.buildLabel('product.sale_price'.tr),
                  TextFormField(
                    style: titilliumNormal.copyWith(
                      fontSize: 20,
                      color: TColors.primary,
                      fontFamily: 'Poppins',
                    ),
                    controller: controller.price,
                    validator:
                        (value) => TValidator.validateEmptyText('price', value),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(labelStyle: titilliumSemiBold),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TCustomWidgets.buildLabel('product.discount_percentage'.tr),
                  TextFormField(
                    controller: controller.saleprecentage,
                    onChanged: (value) => controller.changePrice(value),
                    style: titilliumBold.copyWith(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelStyle: titilliumSemiBold),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TCustomWidgets.buildLabel('product.price'.tr),
                  TextFormField(
                    onChanged:
                        (value) => controller.changeSalePresentage(value),
                    style: titilliumBold.copyWith(
                      color: TColors.darkGrey,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 1.5,
                      fontSize: 18,
                    ),
                    controller: controller.oldPrice,
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(labelStyle: titilliumSemiBold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtWsections),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: controller.selectedImage.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TCustomWidgets.buildLabel('product.images'.tr),
                        // زر معاينة جميع الصور
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed:
                                  () => _openImagePreview(context, controller),
                              icon: const Icon(Icons.fullscreen, size: 16),
                              label: Text(
                                'product.preview'.tr,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${controller.selectedImage.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtWItems),
                Obx(
                  () => Visibility(
                    visible: true,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              controller.selectedImage.isNotEmpty
                                  ? SizedBox(
                                    height: 270,
                                    child: Obx(
                                      () => ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            controller.selectedImage.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onScaleUpdate: (
                                              ScaleUpdateDetails details,
                                            ) {
                                              controller.updateRotation(
                                                details.rotation,
                                              );
                                            },

                                            //   child: Obx(() => Transform.rotate(
                                            //         angle: controller.rotationAngle.value,
                                            //         child: Image.asset(imagePath),
                                            //       )),
                                            // ,
                                            onTap:
                                                () => _openImagePreview(
                                                  context,
                                                  controller,
                                                  initialIndex: index,
                                                ),
                                            child: Obx(
                                              () => Transform.rotate(
                                                angle:
                                                    controller
                                                        .rotationAngle
                                                        .value,
                                                child: Stack(
                                                  // alignment: Alignment.bottomLeft,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          TranslationController
                                                                  .instance
                                                                  .isRTL
                                                              ? EdgeInsets.only(
                                                                left:
                                                                    index ==
                                                                            controller.selectedImage.length -
                                                                                1
                                                                        ? padding
                                                                        : 0,
                                                                right: padding,
                                                              )
                                                              : EdgeInsets.only(
                                                                right:
                                                                    index ==
                                                                            controller.selectedImage.length -
                                                                                1
                                                                        ? padding
                                                                        : 0,
                                                                left: 16,
                                                              ),
                                                      child: TRoundedContainer(
                                                        width: 200,
                                                        height: 200 * (4 / 3),
                                                        showBorder: true,
                                                        radius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                          child: GestureDetector(
                                                            onScaleUpdate: (
                                                              ScaleUpdateDetails
                                                              details,
                                                            ) {
                                                              controller
                                                                  .updateRotation(
                                                                    details
                                                                        .rotation,
                                                                  );
                                                              controller
                                                                  .updateScale(
                                                                    details
                                                                        .scale,
                                                                  );
                                                            },

                                                            // onTap: () => controller
                                                            //     .cropImage(controller
                                                            //         .selectedImage[index]
                                                            //         .path),
                                                            child: Image.file(
                                                              File(
                                                                controller
                                                                    .selectedImage[index]
                                                                    .path,
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: padding,
                                                      right: padding,
                                                      child: Visibility(
                                                        visible: false,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                          child: IconButton(
                                                            onPressed:
                                                                () => CropRotateImage(
                                                                  imagePath:
                                                                      controller
                                                                          .selectedImage[index]
                                                                          .path,
                                                                ),
                                                            icon: TRoundedContainer(
                                                              width: 30,
                                                              height: 30,
                                                              radius:
                                                                  BorderRadius.circular(
                                                                    40,
                                                                  ),
                                                              backgroundColor:
                                                                  TColors.black
                                                                      .withValues(
                                                                        alpha:
                                                                            .5,
                                                                      ),
                                                              child: const Icon(
                                                                Icons.crop,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // زر معاينة الصور
                                                    Positioned(
                                                      bottom: padding,
                                                      left: padding,
                                                      child: IconButton(
                                                        onPressed:
                                                            () =>
                                                                _openImagePreview(
                                                                  context,
                                                                  controller,
                                                                  initialIndex:
                                                                      index,
                                                                ),
                                                        icon: TRoundedContainer(
                                                          width: 30,
                                                          height: 30,
                                                          radius:
                                                              BorderRadius.circular(
                                                                40,
                                                              ),
                                                          backgroundColor:
                                                              TColors.black
                                                                  .withValues(
                                                                    alpha: .5,
                                                                  ),
                                                          child: const Icon(
                                                            Icons.fullscreen,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: padding,
                                                      right: padding,
                                                      child: IconButton(
                                                        onPressed:
                                                            () => controller
                                                                .selectedImage
                                                                .removeAt(
                                                                  index,
                                                                ),
                                                        icon: TRoundedContainer(
                                                          width: 30,
                                                          height: 30,
                                                          radius:
                                                              BorderRadius.circular(
                                                                40,
                                                              ),
                                                          backgroundColor:
                                                              TColors.black
                                                                  .withValues(
                                                                    alpha: .5,
                                                                  ),
                                                          child: const Icon(
                                                            Icons.close_rounded,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  : Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            size: 50,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'product.no_images_uploaded'.tr,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 28.0,
                                  right: 28,
                                  bottom: 28,
                                  top: 0,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => controller.takeCameraImages(),
                                        child: Center(
                                          child: TRoundedContainer(
                                            width: 60,
                                            height: 60,
                                            showBorder: true,
                                            radius: BorderRadius.circular(50),
                                            child: const Center(
                                              child: Icon(
                                                CupertinoIcons.photo_camera,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: TSizes.spaceBtWItems,
                                      ),
                                      GestureDetector(
                                        onTap: () => controller.selectImages(),
                                        child: Center(
                                          child: TRoundedContainer(
                                            width: 60,
                                            height: 60,
                                            showBorder: true,
                                            radius: BorderRadius.circular(50),
                                            child: const Center(
                                              child: Icon(
                                                CupertinoIcons.photo_fill,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            //  const SizedBox(height: TSizes.spaceBtwInputFields),
            // Text(createController.message.value),
            // Obx(() => Text(createController.message.value)),
            const SizedBox(height: 20),
            // const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
