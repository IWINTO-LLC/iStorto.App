import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/admin_categories_controller.dart';
import 'package:istoreto/data/models/major_category_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminCategoriesController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'admin_categories_title'.tr,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadCategories(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_categories_found'.tr,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'add_first_category'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.showAddCategoryDialog(),
                  icon: const Icon(Icons.add),
                  label: Text('add_category'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'admin_search_categories'.tr,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => controller.searchCategories(value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    onSelected: (value) => controller.filterByStatus(value),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'all',
                            child: Text('admin_all_categories'.tr),
                          ),
                          PopupMenuItem(
                            value: 'active',
                            child: Text('admin_active_categories'.tr),
                          ),
                          PopupMenuItem(
                            value: 'pending',
                            child: Text('admin_pending_categories'.tr),
                          ),
                          PopupMenuItem(
                            value: 'inactive',
                            child: Text('admin_inactive_categories'.tr),
                          ),
                        ],
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
              ),
            ),

            // Categories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.filteredCategories[index];
                  return _buildCategoryCard(controller, category);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddCategoryDialog(),
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryCard(
    AdminCategoriesController controller,
    MajorCategoryModel category,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category Image
            _buildCategoryImage(category),
            const SizedBox(width: 16),

            // Category Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(category.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (category.arabicName?.isNotEmpty == true)
                    Text(
                      category.arabicName!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color:
                            category.isFeature
                                ? Colors.amber
                                : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.isFeature
                            ? 'admin_featured'.tr
                            : 'admin_regular'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              category.isFeature
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            PopupMenuButton<String>(
              onSelected:
                  (value) => _handleMenuAction(controller, value, category),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 16),
                          const SizedBox(width: 8),
                          Text('admin_edit'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_feature',
                      child: Row(
                        children: [
                          Icon(
                            category.isFeature ? Icons.star_border : Icons.star,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.isFeature
                                ? 'admin_remove_feature'.tr
                                : 'admin_make_featured'.tr,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(
                            category.status == 1
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.status == 1
                                ? 'admin_deactivate'.tr
                                : 'admin_activate'.tr,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'admin_delete'.tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage(MajorCategoryModel category) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipOval(
        child:
            category.image?.isNotEmpty == true
                ? Image.network(
                  category.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.category, color: Colors.grey),
                    );
                  },
                )
                : Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.category, color: Colors.grey),
                ),
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color color;
    String text;

    switch (status) {
      case 1:
        color = Colors.green;
        text = 'admin_active'.tr;
        break;
      case 2:
        color = Colors.orange;
        text = 'admin_pending'.tr;
        break;
      case 3:
        color = Colors.red;
        text = 'admin_inactive'.tr;
        break;
      default:
        color = Colors.grey;
        text = 'admin_unknown'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleMenuAction(
    AdminCategoriesController controller,
    String action,
    MajorCategoryModel category,
  ) {
    switch (action) {
      case 'edit':
        controller.showEditCategoryDialog(category);
        break;
      case 'toggle_feature':
        controller.toggleFeatureStatus(category);
        break;
      case 'toggle_status':
        controller.toggleStatus(category);
        break;
      case 'delete':
        controller.showDeleteConfirmation(category);
        break;
    }
  }
}
