// lib/featured/home-page/views/widgets/major_category_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/examples/test_categories_widget.dart';
import 'package:istoreto/examples/test_categories_widget_v2.dart';

import '../../../../../controllers/major_category_controller.dart';
import '../../../../../data/models/major_category_model.dart';

class MajorCategorySection extends StatelessWidget {
  const MajorCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(MajorCategoryController());

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
                onTap: () => Get.to(() => const TestCategoriesWidgetV2()),
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

          final categories =
              controller.featuredCategories.isNotEmpty
                  ? controller.featuredCategories.take(4).toList()
                  : controller.rootCategories.take(4).toList();

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
            height: 120,
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
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _onCategoryTap(category),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  category.image != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(category.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getStatusColor(category.status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getStatusText(category.status),
              style: TextStyle(
                fontSize: 10,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(categoryName),
            _getCategoryColor(categoryName).withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        _getCategoryIcon(categoryName),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Icons.checkroom;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Icons.shopping_bag;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Icons.shopping_basket;
    } else if (name.contains('accessories') || name.contains('watch')) {
      return Icons.watch;
    } else if (name.contains('electronics') || name.contains('phone')) {
      return Icons.phone_android;
    } else if (name.contains('home') || name.contains('furniture')) {
      return Icons.home;
    } else if (name.contains('beauty') || name.contains('cosmetics')) {
      return Icons.face;
    } else if (name.contains('sports') || name.contains('fitness')) {
      return Icons.sports;
    } else if (name.contains('books') || name.contains('education')) {
      return Icons.book;
    } else if (name.contains('toys') || name.contains('games')) {
      return Icons.toys;
    } else {
      return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Colors.pink;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Colors.brown;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Colors.purple;
    } else if (name.contains('accessories') || name.contains('watch')) {
      return Colors.blue;
    } else if (name.contains('electronics') || name.contains('phone')) {
      return Colors.blueGrey;
    } else if (name.contains('home') || name.contains('furniture')) {
      return Colors.green;
    } else if (name.contains('beauty') || name.contains('cosmetics')) {
      return Colors.pinkAccent;
    } else if (name.contains('sports') || name.contains('fitness')) {
      return Colors.orange;
    } else if (name.contains('books') || name.contains('education')) {
      return Colors.indigo;
    } else if (name.contains('toys') || name.contains('games')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
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
