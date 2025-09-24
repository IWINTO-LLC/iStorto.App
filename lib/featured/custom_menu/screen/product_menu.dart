// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/custom_menu/controller/bulk_product_control.dart';
import 'package:istoreto/featured/custom_menu/screen/widgets/bulk_menu_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

class ProductManageBulkMenu extends StatelessWidget {
  final controller = Get.put(ProductControllerx());
  final List<ProductModel> initialList;
  final String vendorId;
  ProductManageBulkMenu({
    super.key,
    required this.initialList,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    controller.products.value = initialList;

    return Scaffold(
      appBar: CustomAppBar(title: 'menuManagement'.tr),
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (controller.selectedProducts.isNotEmpty) {
                controller.clearSelection();
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          // onPopInvoked: (didPop) {
          //   if (!didPop) {
          //     controller.clearSelection();
          //     // تنفيذ حدث إلغاء التحديد عند محاولة الرجوع
          //   }
          // },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Obx(
                    () => Text("Total Number is ${initialList.length}"),
                  ),
                ),
                // مربع البحث
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    onChanged: (query) => controller.searchProducts(query),
                    decoration: const InputDecoration(
                      labelText: "ابحث عن المنتجات...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),

                Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];

                      return GestureDetector(
                        onLongPress:
                            () => controller.selectionMode.value = true,
                        child: Stack(
                          alignment:
                              TranslationController.instance.isRTL
                                  ? Alignment.topLeft
                                  : Alignment.topRight,
                          children: [
                            BulkMenuItem(product: product),
                            Obx(
                              () =>
                                  controller.selectionMode.value
                                      ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Checkbox(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ), // تعديل الزوايا
                                          ),
                                          activeColor: Colors.black,
                                          value: controller.selectedProducts
                                              .contains(product),
                                          onChanged:
                                              (checked) => controller
                                                  .toggleSelection(product),
                                        ),
                                      )
                                      : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ✅ Bottom Floating Action Buttons
      bottomNavigationBar: Obx(
        () =>
            controller.selectionMode.value
                ? Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Obx(
                            () => TRoundedContainer(
                              radius: BorderRadius.circular(10),
                              showBorder: true,
                              borderWidth: 1,
                              borderColor:
                                  controller.selectAll.value
                                      ? Colors.blue
                                      : Colors.grey,
                              child: Center(
                                child: IconButton(
                                  onPressed: controller.toggleSelectAll,
                                  icon: const Icon(Icons.checklist, size: 25),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              () => controller.deleteSelectedProducts(vendorId),
                          icon: Icon(Icons.delete),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(4.0),
                        //   child: CustomButtonBlack(
                        //     width: 21.w,
                        //     text: "Delete",
                        //     onTap: () => openDeleteSelectionDialog(context),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomButtonBlack(
                            text: "Change Category",
                            onTap: () => openCategorySelectionDialog(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomButtonBlack(
                            text: "Change Sector",
                            onTap: () => openSectorSelectionDialog(context),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(4.0),
                        //   child: CustomButtonBlack(
                        //     width: 28.w,
                        //     text: "save changes",
                        //     onTap: controller.saveChanges,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )
                : const SizedBox(),
      ),
    );
  }
}
