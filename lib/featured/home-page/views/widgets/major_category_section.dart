// lib/featured/home-page/views/widgets/major_category_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/home-page/views/widgets/category_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/category_vendors_page.dart';
import 'package:istoreto/featured/home-page/views/widgets/small-widgets/category_squer_item.dart';
import 'package:istoreto/featured/home-page/views/widgets/small-widgets/view_all.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/catrgory_shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';

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
              ViewAll(onTap: () => Get.to(() => const CategorySection())),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading) {
            return const TCategoryShummer(itemCount: 8);
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
                return CategorySquerItem(
                  name: category.name,
                  image: category.image ?? "",
                  onTap:
                      () =>
                          Get.to(() => CategoryVendorsPage(category: category)),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
// Get.to(() => CategoryVendorsPage(category: category)),