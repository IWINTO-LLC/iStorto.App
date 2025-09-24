import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:istoreto/featured/home-page/views/home_page.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/cart_page.dart';
import 'package:istoreto/views/favorites_page.dart';
import 'package:istoreto/views/orders_page.dart';
import 'package:istoreto/views/profile_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.isGust});
  final bool? isGust;

  @override
  Widget build(BuildContext context) {
    final iconColor = TColors.dark;
    final selectedIconColor = TColors.primary;
    // Get.put(LaterListController());
    // Get.put(CartController());
    final controller = Get.put(NavigationController());

    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          // floatingActionButton: const TCircularFabWidget(),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          body: WillPopScope(
            onWillPop: () async => controller.onWillPop(),
            child: Obx(
              () => controller.screens[controller.selectedIndex.value],
            ),
          ),

          bottomNavigationBar: Obx(
            () => NavigationBar(
              animationDuration: Duration(milliseconds: 1000),
              elevation: 0,
              height: 80,
              backgroundColor: TColors.white,
              indicatorColor: Colors.transparent,

              // indicatorShape: LinearBorder.bottom(
              //   side: BorderSide(color: TColors.primary),
              //   size: 0.2,
              //   alignment: BorderSide.strokeAlignCenter,
              // ),
              selectedIndex: controller.selectedIndex.value,

              onDestinationSelected:
                  (index) => controller.selectedIndex.value = index,
              destinations: [
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.home,
                    color: selectedIconColor,
                    size: 30,
                  ),
                  icon: Icon(Icons.home_outlined, size: 30, color: iconColor),
                  label: '',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.favorite,
                    color: selectedIconColor,
                    size: 30,
                  ),
                  icon: Icon(
                    Icons.favorite_outline,
                    size: 30,
                    color: iconColor,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.receipt_long,
                    color: selectedIconColor,
                    size: 30,
                  ),
                  icon: Icon(
                    Icons.receipt_long_outlined,
                    size: 30,
                    color: iconColor,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.shopping_bag,
                    color: selectedIconColor,
                    size: 30,
                  ),
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: iconColor,
                    size: 30,
                  ),
                  label: '', //myCart'.tr,
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.person_2,
                    color: selectedIconColor,
                    size: 26,
                  ),
                  icon: Icon(Icons.person_outline, size: 30, color: iconColor),
                  label: '', //'Profile'.tr,
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.store,
                    color: selectedIconColor,
                    size: 26,
                  ),
                  icon: Icon(Icons.store_outlined, size: 30, color: iconColor),
                  label: '', //'Profile'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();
  final Rx<int> selectedIndex = 0.obs;
  DateTime? _lastBackPressed;

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  bool onWillPop() {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);
    final isWarning =
        _lastBackPressed == null ||
        now.difference(_lastBackPressed!) > maxDuration;

    if (isWarning) {
      _lastBackPressed = now;
      Get.snackbar(
        '',
        'double_tap_to_exit'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        maxWidth: 200,

        isDismissible: false,
        shouldIconPulse: false,
        icon: null,
      );
      return false;
    }
    return true;
  }

  final screens = [
    const HomePage(),
    const FavoritesPage(),
    const OrdersPage(),
    const CartPage(),
    const ProfilePage(),
    const ProfilePage(),
  ];
}
