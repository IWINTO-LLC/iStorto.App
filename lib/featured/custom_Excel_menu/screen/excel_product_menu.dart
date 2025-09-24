import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/custom_Excel_menu/controller/bulk_excel_product_control.dart';
import 'package:istoreto/featured/custom_Excel_menu/screen/widgets/bulk_excel_menu_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/custom_button.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/loader/loaders.dart';
import 'package:sizer/sizer.dart';

class ProductManageExelTempBulkMenu extends StatelessWidget {
  final controller = Get.put(ProductControllerExcel());
  final List<ProductModel> initialList;

  ProductManageExelTempBulkMenu({
    super.key,
    required this.initialList,
    required this.vendorId,
  });
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    controller.products.value = initialList;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Temp Products'),
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
          child: Column(
            children: [
              // مربع البحث
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged:
                      (query) => controller.searchProducts(query, vendorId),
                  decoration: const InputDecoration(
                    labelText: "ابحث عن المنتجات...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Obx(() => Text("عدد العناصر:  ${controller.products.length}")),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),

                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: controller.isGridView.value ? 2 : 1,
                    //     childAspectRatio: 3
                    //     //childAspectRatio: 3 / 2,
                    //     ),
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
                            BulkEXcelMenuItem(product: product),
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
              ),
            ],
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
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomButtonBlack(
                            width: 21.w,
                            text: "Delete",
                            onTap: () {
                              TLoader.progressSnackBar(title: "deleting now");
                              controller.deleteSelectedProducts(vendorId);
                              TLoader.stopProgress(); // ReusableAlertDialog.
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomButtonBlack(
                            text: "Change Category",
                            onTap:
                                () => openCategorySelectionTempDialog(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomButtonBlack(
                            text: "Change Sector",
                            onTap: () => openSectorSelectionTempDialog(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomButtonBlack(
                            width: 28.w,
                            text: "ACtive",
                            onTap: controller.activeSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : const SizedBox(),
      ),
    );
  }
}
