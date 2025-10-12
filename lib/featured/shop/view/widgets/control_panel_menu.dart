import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/album/screens/gallery_tab.dart';
import 'package:istoreto/featured/banner/view/all/all_banners.dart';
import 'package:istoreto/featured/category/view/all_category/all_categories.dart';
import 'package:istoreto/featured/payment/screen/vendor_sales.dart';
import 'package:istoreto/featured/product/views/all_products_list.dart';
import 'package:istoreto/featured/shop/data/menu_model.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/featured/shop/view/policy_page.dart';
import 'package:istoreto/featured/shop/view/store_settings.dart';
import 'package:istoreto/navigation_menu.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:line_icons/line_icons.dart';

class ControlPanelMenu extends StatelessWidget {
  const ControlPanelMenu({
    super.key,
    required this.editMode,
    required this.vendorId,
  });
  final bool editMode;
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    final items = getVisitorMenuItems(context, vendorId);
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // شكل الحواف الدائرية
          ),
        ),
      ),
      child: PopupMenuButton<int>(
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
      ),
    );
  }

  List<MenuItemData> getVisitorMenuItems(
    BuildContext context,
    String vendorId,
  ) {
    return [
      MenuItemData(
        icon: LineIcons.magic,
        title: 'settings'.tr,
        onTap:
            () => Get.to(
              () => VendorSettingsPage(
                vendorId: vendorId,
                fromBage: 'control_panel',
              ),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),
      MenuItemData(
        icon: Icons.list,
        title: "Sales".tr,

        onTap:
            () => Get.to(
              () => VendorSalesScreen(vendorId: vendorId),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),

      MenuItemData(
        icon: Icons.terminal,
        title: 'manage_terms'.tr,

        onTap:
            () => Get.to(
              () => PolicyPage(vendorId: vendorId),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),
      MenuItemData(
        icon: FontAwesomeIcons.fileExcel,
        title: 'excel_import'.tr,
        onTap: () {},
        // () => Get.to(
        //   () => ImportExcelPage(vendorId: vendorId),
        //   duration: Duration(microseconds: 900),
        //   transition: Transition.cupertino,
        // ),
      ),
      MenuItemData(
        icon: Icons.category,
        title: 'shop.categories'.tr,

        onTap:
            () => Get.to(
              () => CategoryMobileScreen(vendorId: vendorId),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),
      MenuItemData(
        icon: CupertinoIcons.infinite,
        title: 'shop.products'.tr,

        onTap:
            () => Get.to(
              () => ProductsList(vendorId: vendorId),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),
      MenuItemData(
        icon: CupertinoIcons.photo_on_rectangle,
        title: 'shop.banners'.tr,

        onTap:
            () => Get.to(
              () => BannersMobileScreen(vendorId: vendorId),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),

      MenuItemData(
        icon: CupertinoIcons.photo_on_rectangle,
        title: 'album'.tr,

        onTap:
            () => Get.to(
              () => AlbumsTabPage(userId: vendorId),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),

      MenuItemData(
        icon: CupertinoIcons.reply,
        title: "exit".tr,

        onTap:
            () => Get.to(
              () => NavigationMenu(),
              duration: Duration(microseconds: 900),
              transition: Transition.cupertino,
            ),
      ),
    ];
  }
}
