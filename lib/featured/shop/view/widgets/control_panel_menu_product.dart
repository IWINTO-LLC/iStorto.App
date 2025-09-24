import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/dialog/reusable_dialog.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/edit/edit_product.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/main.dart';

class ControlPanelProduct extends StatelessWidget {
  ControlPanelProduct({
    super.key,
    required this.vendorId,
    required this.product,
    this.withCircle = false,
    required this.editMode,
  });
  final String vendorId;
  final bool editMode;
  final ProductModel product;
  bool withCircle;

  @override
  Widget build(BuildContext context) {
    var savController = SavedController.instance;
    var save = savController.isSaved(product.id).obs;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      child: Obx(() {
        final items = _getMenuItems(context, savController, save);
        return PopupMenuButton<int>(
          icon: Icon(Icons.more_vert, color: TColors.black, size: 25),
          iconSize: 25,
          borderRadius: BorderRadius.circular(15),
          padding: const EdgeInsetsDirectional.all(2),
          itemBuilder:
              (context) => List.generate(items.length, (index) {
                final item = items[index];
                return PopupMenuItem<int>(
                  value: index,
                  child: Row(
                    children: [
                      Icon(item.icon, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(item.title),
                    ],
                  ),
                );
              }),
          onSelected: (index) {
            HapticFeedback.lightImpact();
            items[index].onTap();
          },
        );
      }),
    );
  }

  List<MenuItemData> _getMenuItems(
    BuildContext context,
    SavedController savController,
    RxBool save,
  ) {
    return [
      if (!editMode)
        MenuItemData(
          icon: Icons.favorite,
          title: 'like'.tr,
          onTap: () async {},
        ),
      if (!editMode)
        MenuItemData(
          icon: Icons.bookmark,
          title: 'save'.tr,
          onTap: () async {
            if (save.value) {
              savController.removeProduct(product);
              save.value = !save.value;
            } else {
              savController.saveProduct(product);
              save.value = !save.value;
            }
          },
        ),
      if (editMode)
        MenuItemData(
          icon: Icons.edit,
          title: 'edit_this_item'.tr,
          onTap: () async {
            HapticFeedback.lightImpact;
            EditProductController.instance.init(product);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        EditProduct(product: product, vendorId: vendorId),
              ),
            );
          },
        ),
      if (editMode)
        MenuItemData(
          icon: Icons.delete,
          title: 'delete_this_item'.tr,
          onTap: () async {
            ReusableAlertDialog.show(
              context: context,
              title: 'delete_item'.tr,
              content: 'delete_item_confirm'.tr,
              onConfirm: () async {
                ProductController.instance.markProductAsDeleted(
                  product,
                  product.vendorId!,
                  true,
                );
              },
            );
          },
        ),
      MenuItemData(
        icon: Icons.language,
        title: 'language_toggle'.tr,
        onTap: () async {},
      ),
    ];
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItemData({required this.icon, required this.title, required this.onTap});
}
