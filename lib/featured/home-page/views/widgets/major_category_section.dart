// lib/featured/home-page/views/widgets/major_category_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/home-page/views/widgets/category_section.dart';

import '../../../../../controllers/major_category_controller.dart';
import '../../../../../data/models/major_category_model.dart';

class MajorCategorySection extends StatelessWidget {
  const MajorCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(MajorCategoryController());

    // Load active categories for all users
    controller.loadActiveCategories();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'categories'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const CategorySection()),
                child: Row(
                  children: [
                    Text(
                      'see_all'.tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading) {
            return SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show all active categories for all users
          final categories = controller.activeCategories.take(8).toList();

          if (categories.isEmpty) {
            return SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'no_items_yet'.tr,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            );
          }

          return SizedBox(
            height: 140, // Increased height to accommodate status chips
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryItem(category, context);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryItem(MajorCategoryModel category, BuildContext context) {
    // Add null safety checks
    if (category.name.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 90, // Slightly wider for better text display
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _onCategoryTap(category),
            child: Container(
              width: 70, // Slightly larger for better visibility
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  category.image != null && category.image!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.network(
                          category.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCategoryIcon(category);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildCategoryIcon(category);
                          },
                        ),
                      )
                      : _buildCategoryIcon(category),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.displayName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Only show status for non-active categories
          if (category.status != 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(category.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(category.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(category.status),
                style: TextStyle(
                  fontSize: 9,
                  color: _getStatusColor(category.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(MajorCategoryModel category) {
    final categoryName = category.name.isNotEmpty ? category.name : 'Unknown';
    final controller = Get.find<MajorCategoryController>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            controller.getCategoryColor(categoryName),
            controller.getCategoryColor(categoryName).withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        controller.getCategoryIcon(categoryName),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // Active
        return Colors.green;
      case 2: // Pending
        return Colors.orange;
      case 3: // Inactive
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'active'.tr;
      case 2:
        return 'pending'.tr;
      case 3:
        return 'inactive'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  void _onCategoryTap(MajorCategoryModel category) {
    // Navigate to category products page or show category details
    Get.snackbar(
      category.displayName,
      'category_selected'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );

    // You can add navigation to category products page here
    // Get.to(() => CategoryProductsPage(category: category));
  }
}
