// lib/featured/all-categories/views/all_categories_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/major_category_controller.dart';
import '../../../../../data/models/major_category_model.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/category_list_item.dart';
import '../widgets/category_search_bar.dart';
import '../widgets/category_filter_chips.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final MajorCategoryController controller =
      Get.find<MajorCategoryController>();
  bool isGridView = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load categories if not already loaded
    if (controller.allCategories.isEmpty) {
      controller.loadAllCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('all_categories'.tr),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.refreshAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          CategorySearchBar(
            onSearchChanged: (query) {
              setState(() {
                searchQuery = query;
              });
              controller.searchCategories(query);
            },
            onClearSearch: () {
              setState(() {
                searchQuery = '';
              });
              controller.clearSearch();
            },
          ),

          // Filter Chips
          CategoryFilterChips(
            onStatusFilterChanged: (status) {
              controller.setStatusFilter(status);
            },
            onFeaturedFilterChanged: () {
              controller.toggleFeaturedFilter();
            },
            onClearFilters: () {
              controller.clearFilters();
            },
          ),

          // Categories List/Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories =
                  searchQuery.isNotEmpty
                      ? controller.searchResults
                      : controller.filteredCategories;

              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'no_search_results'.tr
                            : 'no_items_yet'.tr,
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      if (searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'search_hint'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return isGridView
                  ? _buildGridView(categories)
                  : _buildListView(categories);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<MajorCategoryModel> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryGridItem(
          category: category,
          onTap: () => _onCategoryTap(category),
          onToggleFeatured:
              () =>
                  controller.toggleFeatured(category.id!, !category.isFeature),
        );
      },
    );
  }

  Widget _buildListView(List<MajorCategoryModel> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryListItem(
          category: category,
          onTap: () => _onCategoryTap(category),
          onToggleFeatured:
              () =>
                  controller.toggleFeatured(category.id!, !category.isFeature),
          onStatusChanged:
              (status) => controller.updateCategoryStatus(category.id!, status),
        );
      },
    );
  }

  void _onCategoryTap(MajorCategoryModel category) {
    // Show category details or navigate to category products
    _showCategoryDetails(category);
  }

  void _showCategoryDetails(MajorCategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category image
                if (category.image != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        category.image!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.category,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Category name
                Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (category.arabicName != null &&
                    category.arabicName != category.name) ...[
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 16),

                // Category details
                _buildDetailRow('status'.tr, _getStatusText(category.status)),
                _buildDetailRow(
                  'featured'.tr,
                  category.isFeature ? 'yes'.tr : 'no'.tr,
                ),
                if (category.parentId != null)
                  _buildDetailRow('parent_category'.tr, 'has_parent'.tr),
                _buildDetailRow(
                  'created_at'.tr,
                  category.createdAt?.toString().split(' ')[0] ?? 'unknown'.tr,
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to category products
                          _navigateToCategoryProducts(category);
                        },
                        icon: const Icon(Icons.shopping_bag),
                        label: Text('view_products'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToCategoryProducts(category);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('browse'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
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

  void _navigateToCategoryProducts(MajorCategoryModel category) {
    // Navigate to category products page
    Get.snackbar(
      category.displayName,
      'navigating_to_products'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );

    // TODO: Implement navigation to category products page
    // Get.to(() => CategoryProductsPage(category: category));
  }
}
