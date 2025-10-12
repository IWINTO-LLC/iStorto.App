import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/cart/view/cart_screen.dart';
import 'package:istoreto/featured/cart/view/new_cart_screen.dart';
import 'package:istoreto/featured/home-page/views/home_page.dart';
import 'package:istoreto/featured/product/views/favorite_products_list.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/views/profile_page.dart';
import 'package:line_icons/line_icons.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, this.isGust});
  final bool? isGust;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    // التأكد من ظهور شريط الحالة
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
      child: Scaffold(
        body: WillPopScope(
          onWillPop: showExitDialog,
          child: Obx(() => controller.screens[controller.selectedIndex.value]),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withValues(alpha: .1),
              ),
            ],
          ),
          child: Stack(
            children: [
              SafeArea(
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
                      GButton(icon: LineIcons.home, text: 'home'.tr),
                      GButton(icon: LineIcons.heart, text: 'favorites'.tr),
                      GButton(icon: LineIcons.shoppingCart, text: 'cart'.tr),
                      GButton(icon: LineIcons.user, text: 'profile'.tr),
                      if (AuthController.instance.isVendorAcount.value)
                        GButton(icon: LineIcons.store, text: 'store'.tr),
                    ],
                    selectedIndex: controller.selectedIndex.value,
                    onTabChange:
                        (index) => controller.selectedIndex.value = index,
                  ),
                ),
              ),
            ],
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
  Timer? _exitMessageTimer;
  final RxBool _showExitMessage = false.obs;

  bool handleBackPress() {
    if (_showExitMessage.value) {
      return true; // الخروج من التطبيق
    }

    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 1)) {
      _lastBackPressed = now;
      _showExitMessage.value = true;
      _showExitMessageTimer();
      return false; // عدم الخروج
    }

    return true; // الخروج من التطبيق
  }

  void _showExitMessageTimer() {
    _exitMessageTimer?.cancel();
    _exitMessageTimer = Timer(const Duration(seconds: 2), () {
      _showExitMessage.value = false;
    });
  }

  @override
  void onClose() {
    _exitMessageTimer?.cancel();
    super.onClose();
  }

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

  List<Widget> get screens => [
    const HomePage(), // Home page
    const FavoriteProductsPage(), // Likes page
    const NewCartScreen(), // Cart page
    const ProfilePage(), // Profile page
    if (AuthController.instance.isVendorAcount.value)
      MarketPlaceView(
        vendorId: AuthController.instance.currentUser.value!.vendorId!,
        editMode: true,
      ), // Business page
  ];
}

Future<bool> showExitDialog() async {
  if (NavigationController.instance.selectedIndex.value != 0) {
    NavigationController.instance.selectedIndex.value = 0;
    return false;
  } else {
    return NavigationController.instance.handleBackPress();
  }
}
