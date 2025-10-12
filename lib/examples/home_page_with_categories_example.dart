// lib/examples/home_page_with_categories_example.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/home-page/views/widgets/category_section.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import '../featured/home-page/views/widgets/major_category_section.dart';
import '../controllers/major_category_controller.dart';

class HomePageWithCategoriesExample extends StatelessWidget {
  const HomePageWithCategoriesExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(MajorCategoryController());

    return Scaffold(
      appBar: AppBar(
        title: Text('iStoreto'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Navigate to search page
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'welcome'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'your_store_tagline'.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Major Categories Section
            const MajorCategorySection(),

            const SizedBox(height: TSizes.spaceBtWsections),

            // Featured Products Section (placeholder)
            _buildFeaturedProductsSection(),

            const SizedBox(height: TSizes.spaceBtWsections),

            // Popular Products Section (placeholder)
            _buildPopularProductsSection(),

            const SizedBox(height: TSizes.spaceBtWsections),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'featured_products'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to featured products page
                },
                child: Text('see_all'.tr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'featured_products_placeholder'.tr,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProductsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'popular_products'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to popular products page
                },
                child: Text('see_all'.tr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'popular_products_placeholder'.tr,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
