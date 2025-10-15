import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/featured/category/view/create_category/create_category.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/section_model.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'product_add_controller.dart';
import 'package:istoreto/data/models/category_model.dart';

class ProductAddPage extends StatelessWidget {
  final ProductAddController controller = Get.put(ProductAddController());

  ProductAddPage({super.key});
  @override
  Widget build(BuildContext context) {
    var addCat = CategoryModel(title: "menu.add_category");

    return Scaffold(
      appBar: AppBar(
        title: Text('product.add_new_product'.tr),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(
          () =>
              controller.isLoading.value
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('product.saving_product'.tr),
                        if (controller.uploadProgress.value > 0)
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: controller.uploadProgress.value,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${(controller.uploadProgress.value * 100).toInt()}%',
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // معلومات المنتج الأساسية
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'product.basic_info'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.titleController,
                                  decoration: InputDecoration(
                                    labelText: 'product.title_required'.tr,
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.title),
                                  ),
                                  textDirection:
                                      Get.locale?.languageCode == 'ar'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'product.description'.tr,
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.description),
                                  ),
                                  maxLines: 3,
                                  textDirection:
                                      Get.locale?.languageCode == 'ar'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: controller.priceController,
                                        decoration: InputDecoration(
                                          labelText:
                                              'product.price_required'.tr,
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.attach_money),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            controller.minQuantityController,
                                        decoration: InputDecoration(
                                          labelText: 'product.min_quantity'.tr,
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.shopping_cart),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // اختيار الفئة والقسم
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'product.category'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // اختيار الفئة
                                Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    TCustomWidgets.buildLabel(
                                      'product.category'.tr,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                CategoryController.instance.isLoading.value
                                    ? const TShimmerEffect(
                                      width: double.infinity,
                                      height: 55,
                                    )
                                    : Obx(() {
                                      final items =
                                          (CategoryController
                                                      .instance
                                                      .allItems
                                                      .isNotEmpty
                                                  ? CategoryController
                                                      .instance
                                                      .allItems
                                                  : <CategoryModel>[])
                                              .map((cat) {
                                                return DropdownMenuItem(
                                                  value: cat,
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              300,
                                                            ),
                                                        child: SizedBox(
                                                          height: 40,
                                                          width: 40,
                                                          child:
                                                              cat.icon !=
                                                                          null &&
                                                                      cat
                                                                          .icon!
                                                                          .isNotEmpty
                                                                  ? CustomCaChedNetworkImage(
                                                                    width: 40,
                                                                    height: 40,
                                                                    url:
                                                                        cat.icon!,
                                                                    raduis:
                                                                        BorderRadius.circular(
                                                                          300,
                                                                        ),
                                                                  )
                                                                  : Container(
                                                                    width: 40,
                                                                    height: 40,
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .grey[300],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            300,
                                                                          ),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .category,
                                                                      color:
                                                                          Colors
                                                                              .grey[600],
                                                                    ),
                                                                  ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        cat.title,
                                                        style: titilliumRegular
                                                            .copyWith(
                                                              fontSize: 16,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                              .toList()
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
                                                      style: titilliumRegular
                                                          .copyWith(
                                                            color: Colors.blue,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                      final selected =
                                          (CategoryController
                                                  .instance
                                                  .allItems
                                                  .isEmpty)
                                              ? null
                                              : CategoryController
                                                  .instance
                                                  .allItems
                                                  .firstWhereOrNull(
                                                    (cat) =>
                                                        cat.id ==
                                                        controller
                                                            .selectedCategory
                                                            .value
                                                            ?.id,
                                                  );
                                      return DropdownButtonFormField<
                                        CategoryModel
                                      >(
                                        borderRadius: BorderRadius.circular(15),
                                        iconSize: 40,

                                        itemHeight: 60,
                                        value: selected,
                                        items: items,
                                        onChanged: (newValue) {
                                          if (newValue == addCat) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => CreateCategory(
                                                      vendorId:
                                                          VendorController
                                                              .instance
                                                              .vendorData
                                                              .value
                                                              .userId ??
                                                          '',
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
                                SizedBox(height: 16),
                                Obx(
                                  () => DropdownButtonFormField<SectionModel>(
                                    value: controller.selectedSection.value,
                                    items:
                                        [
                                              // هنا يجب إضافة قائمة الأقسام من قاعدة البيانات
                                              SectionModel(
                                                id: '1',
                                                name: 'product.section_1'.tr,
                                              ),
                                              SectionModel(
                                                id: '2',
                                                name: 'product.section_2'.tr,
                                              ),
                                              SectionModel(
                                                id: '3',
                                                name: 'product.section_3'.tr,
                                              ),
                                            ]
                                            .map(
                                              (sec) => DropdownMenuItem(
                                                value: sec,
                                                child: Text(sec.name),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        (sec) =>
                                            controller.selectedSection.value =
                                                sec,
                                    decoration: InputDecoration(
                                      labelText: 'product.section'.tr,
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.inventory),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // صور المنتج
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'product.images'.tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: controller.pickImages,
                                      icon: Icon(Icons.add_a_photo),
                                      label: Text('product.add_images'.tr),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Obx(
                                  () =>
                                      controller.pickedImages.isEmpty
                                          ? Container(
                                            height: 120,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                style: BorderStyle.solid,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    size: 48,
                                                    color: Colors.grey,
                                                  ),
                                                  Text(
                                                    'product.no_images_added'
                                                        .tr,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          : GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 8,
                                                  mainAxisSpacing: 8,
                                                  childAspectRatio:
                                                      0.75, // 3:4 aspect ratio
                                                ),
                                            itemCount:
                                                controller.pickedImages.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Colors.grey[300]!,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.file(
                                                        controller
                                                            .pickedImages[index],
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        GestureDetector(
                                                          onTap:
                                                              () => controller
                                                                  .cropImage(
                                                                    index,
                                                                  ),
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        4,
                                                                      ),
                                                                ),
                                                            child: Icon(
                                                              Icons.crop,
                                                              size: 16,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        GestureDetector(
                                                          onTap:
                                                              () => controller
                                                                  .removeImage(
                                                                    index,
                                                                  ),
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        4,
                                                                      ),
                                                                ),
                                                            child: Icon(
                                                              Icons.close,
                                                              size: 16,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                ),
                                if (controller.pickedImages.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'product.crop_instruction'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // زر الحفظ
                        ElevatedButton(
                          onPressed: controller.saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'product.save_product'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
