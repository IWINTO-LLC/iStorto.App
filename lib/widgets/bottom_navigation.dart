import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:  0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  navigationController,
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  'home',
                ),
                _buildNavItem(
                  context,
                  navigationController,
                  1,
                  Icons.favorite_outline,
                  Icons.favorite,
                  'favorites',
                ),
                _buildNavItem(
                  context,
                  navigationController,
                  2,
                  Icons.receipt_long_outlined,
                  Icons.receipt_long,
                  'orders',
                ),
                _buildNavItem(
                  context,
                  navigationController,
                  3,
                  Icons.shopping_bag_outlined,
                  Icons.shopping_bag,
                  'cart',
                ),
                _buildNavItem(
                  context,
                  navigationController,
                  4,
                  Icons.person_outline,
                  Icons.person,
                  'profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationController controller,
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String title,
  ) {
    final isSelected = controller.currentIndex == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title.tr,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
