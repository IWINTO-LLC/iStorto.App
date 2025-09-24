import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/menu_model.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/featured/shop/view/seller.info.dart';
import 'package:istoreto/utils/common/styles/styles.dart';

class ControlPanelMenuVisitor extends StatelessWidget {
  const ControlPanelMenuVisitor({
    super.key,
    required this.editMode,
    required this.vendorId,
  });
  final bool editMode;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // شكل الحواف الدائرية
          ),
        ),
      ),
      child: Obx(() {
        final items = getVisitorMenuItems(context, vendorId);
        return PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          iconSize: 25,
          borderRadius: BorderRadius.circular(50),
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
                      Text(
                        item.title,
                        style: titilliumBold.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
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

  List<MenuItemData> getVisitorMenuItems(
    BuildContext context,
    String vendorId,
  ) {
    return [
      if (editMode)
        MenuItemData(
          icon: Icons.settings,
          title: 'shop.edit'.tr,
          onTap:
              () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MarketPlaceManagment(
                        vendorId: vendorId,
                        editMode: true,
                      ),
                ),
                (route) => false,
              ),
        ),
      MenuItemData(
        icon: Icons.share_outlined,
        title: 'common.share'.tr,
        onTap: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          await ShareServices.shareVendor(
            VendorController.instance.vendorData.value,
          );
          Navigator.pop(context);
        },
      ),

      MenuItemData(
        icon: Icons.translate,
        title:
            TranslateController.instance.enableTranslateProductDetails.value
                        .toString() ==
                    'true'
                ? 'translate.exitTranslate'.tr
                : 'translate.contentTranslate'.tr,

        onTap: () {
          TranslateController.instance.enableTranslateProductDetails.value =
              !TranslateController.instance.enableTranslateProductDetails.value;
        },
      ),

      //SavedProductsPage
      MenuItemData(
        icon: Icons.storefront,
        title: 'shop.aboutUs'.tr,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PolicyDisplayPage(vendorId: vendorId),
              ),
            ),
      ),
    ];
  }
}
