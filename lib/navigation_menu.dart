import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/cart/view/cart_screen.dart';
import 'package:istoreto/featured/home-page/views/home_page.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/views/favorites_page.dart';
import 'package:istoreto/views/profile_page.dart';
import 'package:line_icons/line_icons.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, this.isGust});
  final bool? isGust;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = true;
  double _lastScrollPosition = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animation
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          body: WillPopScope(
            onWillPop: () async => controller.onWillPop(),
            child: Obx(
              () => _wrapWithScrollController(
                controller.screens[controller.selectedIndex.value],
              ),
            ),
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 80 * _animation.value),
                child: Opacity(
                  opacity: 1.0 - _animation.value,
                  child: Transform.scale(
                    scale: 1.0 - (_animation.value * 0.1),
                    child: Container(
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            duration: Duration(milliseconds: 400),
                            tabBackgroundColor: Colors.grey[100]!,
                            color: Colors.black,
                            tabs: [
                              GButton(icon: LineIcons.home, text: 'Home'),
                              GButton(icon: LineIcons.heart, text: 'Likes'),
                              GButton(
                                icon: LineIcons.shoppingBag,
                                text: 'Cart',
                              ),
                              GButton(icon: LineIcons.user, text: 'Profile'),
                              if (AuthController.instance.isVendorAcount.value)
                                GButton(
                                  icon: LineIcons.store,
                                  text: 'Business',
                                ),
                            ],
                            selectedIndex: controller.selectedIndex.value,
                            onTabChange:
                                (index) =>
                                    controller.selectedIndex.value = index,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _wrapWithScrollController(Widget child) {
    // For HomePage and other pages that might have their own scroll controllers
    // We'll use a different approach - wrap the entire content in a scrollable widget
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          final currentScrollPosition = notification.metrics.pixels;
          final scrollDelta = currentScrollPosition - _lastScrollPosition;

          // Threshold for hiding/showing navigation bar
          const double threshold = 15.0;

          if (scrollDelta < -threshold &&
              _isVisible &&
              currentScrollPosition > 50) {
            // Scrolling up - hide navigation bar (only if scrolled past 50px)
            setState(() {
              _isVisible = false;
            });
            _animationController.forward();
          } else if (scrollDelta > threshold && !_isVisible) {
            // Scrolling down - show navigation bar
            setState(() {
              _isVisible = true;
            });
            _animationController.reverse();
          }

          _lastScrollPosition = currentScrollPosition;
        }
        return false;
      },
      child: child,
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
        vendorId: AuthController.instance.currentUser.value!.vendorId!,
        editMode: true,
      ), // Profile page
  ];
}
