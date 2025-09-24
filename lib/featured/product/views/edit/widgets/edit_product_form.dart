import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/scrolle_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';

import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/validators/validator.dart';

class EditProductForm extends StatefulWidget {
  const EditProductForm({
    super.key,
    required this.product,
    required this.vendorId,
    this.isTemp = false,
  });
  final ProductModel product;
  final String vendorId;
  final bool isTemp;

  @override
  State<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  late EditProductController controller;
  late ScrolleEditController scrolleController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = EditProductController.instance;
    scrolleController = Get.put(ScrolleEditController());

    // تهيئة الكنترولر مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        if (CategoryController.instance.allItems.isEmpty) {
          CategoryController.instance.fetchCategoryData();
        }
        controller.type = widget.product.productType ?? '';
        if (controller.initialImage.isEmpty) {
          controller.init(widget.product);
        }
        _isInitialized = true;
      }
    });
  }

  // دالة لفتح معاينة الصور المرفوعة
  void _openImagePreview(
    BuildContext context,
    EditProductController controller, {
    int? initialIndex,
  }) async {
    // تجميع جميع الصور (الأصلية + المضافة)
    List<dynamic> allImages = [];
    List<String> imageTypes = []; // لتتبع نوع كل صورة: 'url' أو 'file'

    // إضافة الصور الأصلية
    for (String imageUrl in controller.initialImage) {
      allImages.add(imageUrl); // إضافة URL مباشرة
      imageTypes.add('url');
    }

    // إضافة الصور المحددة حديثاً
    for (XFile xFile in controller.selectedImage) {
      allImages.add(File(xFile.path));
      imageTypes.add('file');
    }

    if (allImages.isEmpty) return;

    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // رسالة التحميل باللغتين
                  Text(
                    'product.wait_editing_image'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // مؤشر التحميل
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
    );

    try {
      // تحميل الصور الأصلية إلى ملفات مؤقتة للتعديل
      List<File> processedImages = [];
      for (int i = 0; i < allImages.length; i++) {
        if (imageTypes[i] == 'url') {
          // تحميل الصورة من URL إلى ملف مؤقت
          final tempFile = await _downloadImageToTemp(allImages[i]);
          if (tempFile != null) {
            processedImages.add(tempFile);
          } else {
            // إذا فشل التحميل، استخدم URL مباشرة
            processedImages.add(File('placeholder'));
          }
        } else {
          // الصورة محلية، استخدمها مباشرة
          processedImages.add(allImages[i]);
        }
      }

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // فتح معاينة الصور
      showFullscreenImage(
        context: context,
        images: processedImages,
        initialIndex: initialIndex ?? 0,
        showDeleteButton: true,
        showEditButton: true,
        onDelete: (index) {
          // حذف الصورة من القائمة المناسبة
          if (index < controller.initialImage.length) {
            // حذف صورة أصلية
            controller.removeInitialImage(index);
          } else {
            // حذف صورة محددة حديثاً
            int selectedIndex = index - controller.initialImage.length;
            controller.selectedImage.removeAt(selectedIndex);
          }
          // إغلاق المعاينة بعد الحذف
          Navigator.pop(context);
        },
        onSave: (File processedFile, int index) {
          // استبدال الصورة بالصورة المعدلة
          if (index < controller.initialImage.length) {
            // حذف الصورة الأصلية وإضافة الصورة المعدلة كصورة جديدة
            controller.removeInitialImage(index);
            controller.selectedImage.add(XFile(processedFile.path));
          } else {
            // استبدال الصورة المحددة حديثاً
            int selectedIndex = index - controller.initialImage.length;
            controller.selectedImage[selectedIndex] = XFile(processedFile.path);
          }
          // تحديث الواجهة
          controller.update(['images']);
          // إظهار رسالة تأكيد الحفظ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'product.image_saved_successfully'.tr,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
        },
      );
    } catch (e) {
      // إغلاق مؤشر التحميل
      Navigator.pop(context);
      // إظهار رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'product.error_loading_images'.tr,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  // دالة مساعدة لتحميل الصورة من URL إلى ملف مؤقت
  Future<File?> _downloadImageToTemp(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName =
            'temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  //menu.add_category
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrolleController.scrollController,
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== حقول العنوان والوصف والكمية ======
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
                                    ? 'common.required'.tr
                                    : null,
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      TCustomWidgets.buildLabel('product.description'.tr),
                      TextFormField(
                        controller: controller.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      TCustomWidgets.buildLabel('product.min_quantity'.tr),
                      TextFormField(
                        controller: controller.minQuantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'common.required'.tr;
                          final n = int.tryParse(value);
                          if (n == null || n < 1)
                            return 'product.min_quantity_validation'.tr;
                          return null;
                        },
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      // ====== حقل الفئة ======
                      TCustomWidgets.buildLabel('product.category'.tr),
                      CategoryController.instance.isLoading.value
                          ? const TShimmerEffect(
                            width: double.infinity,
                            height: 55,
                          )
                          : SizedBox(
                            height: 80,
                            child: Obx(() {
                              final items =
                                  CategoryController.instance.allItems.map((
                                      cat,
                                    ) {
                                      return DropdownMenuItem(
                                        value: cat,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(300),
                                              child: SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: CustomCaChedNetworkImage(
                                                  width: 40,
                                                  height: 40,
                                                  url: cat.icon ?? '',
                                                  raduis: BorderRadius.circular(
                                                    300,
                                                  ),
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
                                        value: CategoryModel.empty(),
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
                              final selected =
                                  (CategoryController.instance.allItems.isEmpty)
                                      ? null
                                      : CategoryController.instance.allItems
                                          .firstWhereOrNull(
                                            (cat) =>
                                                cat.id ==
                                                controller
                                                    .selectedCategory
                                                    .value
                                                    .id,
                                          );
                              return DropdownButtonFormField<CategoryModel>(
                                borderRadius: BorderRadius.circular(15),
                                iconSize: 40,

                                itemHeight: 60,
                                value: selected,
                                items: items,
                                onChanged: (newValue) {
                                  if (newValue?.id ==
                                      CategoryModel.empty().id) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CreateCategory(
                                              vendorId: widget.vendorId,
                                            ),
                                      ),
                                    );
                                  } else if (newValue != null) {
                                    controller.selectedCategory.value =
                                        newValue;
                                  }
                                },
                              );
                            }),
                          ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      // ====== حقول السعر والخصم ======
                      TCustomWidgets.buildLabel('product.sale_price'.tr),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: titilliumNormal.copyWith(
                          fontSize: 20,
                          color: TColors.primary,
                          fontFamily: 'Poppins',
                        ),
                        controller: controller.price,
                        validator:
                            (value) =>
                                TValidator.validateEmptyText('price', value),
                        decoration: InputDecoration(
                          labelStyle: titilliumSemiBold,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      TCustomWidgets.buildLabel(
                        'product.discount_percentage'.tr,
                      ),
                      TextFormField(
                        controller: controller.saleprecentage,
                        onChanged: (value) => controller.changePrice(value),
                        style: titilliumBold.copyWith(
                          fontSize: 20,
                          fontFamily: numberFonts,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelStyle: titilliumSemiBold,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      TCustomWidgets.buildLabel('product.original_price'.tr),
                      TextFormField(
                        style: titilliumBold.copyWith(
                          color: TColors.darkGrey,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 1.5,
                          fontSize: 18,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged:
                            (value) => controller.changeSalePresentage(value),
                        controller: controller.oldPrice,
                        decoration: InputDecoration(
                          labelStyle: titilliumSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                // ====== قسم الصور ======
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible:
                          controller.initialImage.isNotEmpty ||
                          controller.selectedImage.isNotEmpty,
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
                                      () => _openImagePreview(
                                        context,
                                        controller,
                                      ),
                                  icon: const Icon(Icons.fullscreen, size: 16),
                                  label: Text(
                                    'common.preview'.tr,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${controller.initialImage.length + controller.selectedImage.length})',
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
                                  (controller.initialImage.isNotEmpty ||
                                          controller.selectedImage.isNotEmpty)
                                      ? SizedBox(
                                        height: 270,
                                        child: GetBuilder<
                                          EditProductController
                                        >(
                                          id: 'images',
                                          builder: (controller) {
                                            return ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  controller
                                                      .initialImage
                                                      .length +
                                                  controller
                                                      .selectedImage
                                                      .length,
                                              itemBuilder: (context, index) {
                                                bool isInitialImage =
                                                    index <
                                                    controller
                                                        .initialImage
                                                        .length;
                                                const double padding = 8;

                                                return GestureDetector(
                                                  onTap:
                                                      () => _openImagePreview(
                                                        context,
                                                        controller,
                                                        initialIndex: index,
                                                      ),
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            TranslationController
                                                                    .instance
                                                                    .isRTL
                                                                ? EdgeInsets.only(
                                                                  left:
                                                                      index ==
                                                                              controller.initialImage.length +
                                                                                  controller.selectedImage.length -
                                                                                  1
                                                                          ? padding
                                                                          : 0,
                                                                  right:
                                                                      padding,
                                                                )
                                                                : EdgeInsets.only(
                                                                  right:
                                                                      index ==
                                                                              controller.initialImage.length +
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
                                                            child:
                                                                isInitialImage
                                                                    ? CustomCaChedNetworkImage(
                                                                      width:
                                                                          200,
                                                                      height:
                                                                          200 *
                                                                          (4 /
                                                                              3),
                                                                      url:
                                                                          controller
                                                                              .initialImage[index],
                                                                      raduis:
                                                                          BorderRadius.circular(
                                                                            15,
                                                                          ),
                                                                    )
                                                                    : Image.file(
                                                                      File(
                                                                        controller
                                                                            .selectedImage[index -
                                                                                controller.initialImage.length]
                                                                            .path,
                                                                      ),
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
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
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: padding,
                                                        right: padding,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            if (isInitialImage) {
                                                              controller
                                                                  .removeInitialImage(
                                                                    index,
                                                                  );
                                                            } else {
                                                              controller.removeSelectedImage(
                                                                index -
                                                                    controller
                                                                        .initialImage
                                                                        .length,
                                                              );
                                                            }
                                                            controller.update([
                                                              'images',
                                                            ]);
                                                          },
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
                                                              Icons
                                                                  .close_rounded,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
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
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
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
                                                () =>
                                                    controller
                                                        .takeCameraImages(),
                                            child: Center(
                                              child: TRoundedContainer(
                                                width: 60,
                                                height: 60,
                                                showBorder: true,
                                                radius: BorderRadius.circular(
                                                  50,
                                                ),
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
                                            onTap:
                                                () => controller.selectImages(),
                                            child: Center(
                                              child: TRoundedContainer(
                                                width: 60,
                                                height: 60,
                                                showBorder: true,
                                                radius: BorderRadius.circular(
                                                  50,
                                                ),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: TranslationController.instance.isRTL ? null : 7,
          left: TranslationController.instance.isRTL ? 7 : null,
          child: showFloatingButton(
            controller,
            context,
            scrolleController,
            widget.product,
            widget.isTemp,
            widget.vendorId,
            controller.minQuantityController,
          ),
        ),
      ],
    );
  }
}

Widget showFloatingButton(
  EditProductController controller,
  BuildContext context,
  ScrolleEditController scrolleController,
  ProductModel product,
  bool isTemp,
  String vendorId,
  TextEditingController minQuantityController,
) {
  return SizedBox(
    width: 100,
    height: 40,
    child: FloatingActionButton(
      backgroundColor: Colors.transparent,

      elevation: 0,
      foregroundColor: Colors.transparent,
      //focusColor: TColors.primary,
      onPressed: () async {
        await controller.updateProduct(
          product,
          vendorId,
          isTemp,
          minQuantity: int.tryParse(minQuantityController.text) ?? 1,
        );
        scrolleController.scrollToTop();
      },

      child: Center(
        child: TRoundedContainer(
          enableShadow: true,
          width: 90,
          height: 40,
          backgroundColor: Colors.black,
          radius: BorderRadius.circular(300),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'common.post'.tr,
                style: titilliumBold.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
