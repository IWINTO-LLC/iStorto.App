import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:istoreto/featured/home-page/views/home_page.dart';
import 'package:istoreto/views/cart_page.dart';
import 'package:istoreto/views/favorites_page.dart';
import 'package:istoreto/views/profile_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.isGust});
  final bool? isGust;

  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    duration: Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: [
                      GButton(icon: FontAwesomeIcons.house, text: 'Home'),
                      GButton(icon: FontAwesomeIcons.heart, text: 'Likes'),
                      GButton(icon: Icons.shopping_bag_outlined, text: 'Cart'),
                      GButton(icon: FontAwesomeIcons.user, text: 'Profile'),
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
    const HomePage(), // Get page
    const FavoritesPage(), // Likes page
    const CartPage(), // Search page
    const ProfilePage(), // Profile page
  ];
}
