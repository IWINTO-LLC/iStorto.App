import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/cart/view/cart_screen.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/home-page/views/home_page.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/views/favorites_page.dart';
import 'package:istoreto/views/profile_page.dart';
import 'package:line_icons/line_icons.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.isGust});
  final bool? isGust;

  @override
  Widget build(BuildContext context) {
    Get.put(CurrencyController());
    Get.put(ProductCurrencyService());
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
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8,
                  ),
                  child: GNav(
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,

                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    duration: Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: [
                      GButton(icon: LineIcons.home, text: 'Home'),
                      GButton(icon: LineIcons.heart, text: 'Likes'),
                      GButton(icon: LineIcons.shoppingBag, text: 'Cart'),
                      GButton(icon: LineIcons.user, text: 'Profile'),
                      if (AuthController.instance.isVendorAcount.value)
                        GButton(icon: LineIcons.store, text: 'Business'),
                    ],
                    selectedIndex: controller.selectedIndex.value,
                    onTabChange:
                        (index) => controller.selectedIndex.value = index,
                  ),
                ),
              ),
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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
    const HomePage(), // Get page
    const FavoritesPage(), // Likes page
    const CartScreen(), // Search page
    const ProfilePage(),
    if (AuthController.instance.isVendorAcount.value)
      MarketPlaceManagment(
        vendorId: AuthController.instance.currentUser.value!.id,
        editMode: true,
      ), // Profile page
  ];
}
