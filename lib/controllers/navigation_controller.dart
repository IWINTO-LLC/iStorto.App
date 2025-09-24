import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Current selected index for bottom navigation
  final RxInt _currentIndex = 0.obs;

  // Getter for current index
  int get currentIndex => _currentIndex.value;

  // Change navigation index
  void changeIndex(int index) {
    _currentIndex.value = index;

    // Navigate to the corresponding page
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/favorites');
        break;
      case 2:
        Get.offNamed('/orders');
        break;
      case 3:
        Get.offNamed('/cart');
        break;
      case 4:
        Get.offNamed('/profile');
        break;
    }
  }

  // Navigation pages
  final List<String> pages = [
    '/home',
    '/favorites',
    '/orders',
    '/cart',
    '/profile',
  ];

  // Navigation titles
  final List<String> titles = [
    'home',
    'favorites',
    'orders',
    'cart',
    'profile',
  ];
}
