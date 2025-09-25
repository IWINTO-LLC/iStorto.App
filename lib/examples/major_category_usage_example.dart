// lib/examples/major_category_usage_example.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/major_category_controller.dart';
import '../data/models/major_category_model.dart';

class MajorCategoryUsageExample extends StatelessWidget {
  const MajorCategoryUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(MajorCategoryController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Major Categories Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.refreshAll(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search and Filters
            _buildSearchAndFilters(controller),

            // Categories List
            Expanded(
              child:
                  controller.searchQuery.isNotEmpty
                      ? _buildSearchResults(controller)
                      : _buildCategoriesList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCategoryDialog(controller),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(MajorCategoryController controller) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: Icon(Icons.search),
              suffixIcon:
                  controller.searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => controller.clearSearch(),
                      )
                      : null,
            ),
            onChanged: (value) => controller.searchCategories(value),
          ),

          SizedBox(height: 16),

          // Filters
          Row(
            children: [
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: controller.selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 0, child: Text('All')),
                    DropdownMenuItem(value: 1, child: Text('Active')),
                    DropdownMenuItem(value: 2, child: Text('Pending')),
                    DropdownMenuItem(value: 3, child: Text('Inactive')),
                  ],
                  onChanged: (value) => controller.setStatusFilter(value ?? 0),
                ),
              ),

              SizedBox(width: 16),

              // Featured Filter
              FilterChip(
                label: Text('Featured Only'),
                selected: controller.showFeaturedOnly,
                onSelected: (_) => controller.toggleFeaturedFilter(),
              ),

              SizedBox(width: 16),

              // Clear Filters
              TextButton(
                onPressed: () => controller.clearFilters(),
                child: Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(MajorCategoryController controller) {
    if (controller.searchResults.isEmpty) {
      return Center(
        child: Text('No categories found for "${controller.searchQuery}"'),
      );
    }

    return ListView.builder(
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final category = controller.searchResults[index];
        return _buildCategoryTile(category, controller);
      },
    );
  }

  Widget _buildCategoriesList(MajorCategoryController controller) {
    final categories = controller.filteredCategories;

    if (categories.isEmpty) {
      return Center(child: Text('No categories found'));
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryTile(category, controller);
      },
    );
  }

  Widget _buildCategoryTile(
    MajorCategoryModel category,
    MajorCategoryController controller,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              category.image != null ? NetworkImage(category.image!) : null,
          child: category.image == null ? Icon(Icons.category) : null,
        ),
        title: Text(category.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.arabicName != null &&
                category.arabicName != category.name)
              Text(category.name, style: TextStyle(fontSize: 12)),
            Text('Status: ${_getStatusText(category.status)}'),
            if (category.parentId != null) Text('Parent: ${category.parentId}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Featured Toggle
            IconButton(
              icon: Icon(
                category.isFeature ? Icons.star : Icons.star_border,
                color: category.isFeature ? Colors.amber : null,
              ),
              onPressed:
                  () => controller.toggleFeatured(
                    category.id!,
                    !category.isFeature,
                  ),
            ),

            // Status Toggle
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert),
              onSelected:
                  (status) =>
                      controller.updateCategoryStatus(category.id!, status),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(value: 1, child: Text('Set Active')),
                    PopupMenuItem(value: 2, child: Text('Set Pending')),
                    PopupMenuItem(value: 3, child: Text('Set Inactive')),
                  ],
            ),
          ],
        ),
        onTap: () => _showCategoryDetails(category, controller),
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Active';
      case 2:
        return 'Pending';
      case 3:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  void _showCategoryDetails(
    MajorCategoryModel category,
    MajorCategoryController controller,
  ) {
    showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: Text(category.displayName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${category.id}'),
                Text('Name: ${category.name}'),
                if (category.arabicName != null)
                  Text('Arabic Name: ${category.arabicName}'),
                Text('Status: ${_getStatusText(category.status)}'),
                Text('Featured: ${category.isFeature ? 'Yes' : 'No'}'),
                Text('Parent ID: ${category.parentId ?? 'None'}'),
                Text('Created: ${category.createdAt?.toString() ?? 'Unknown'}'),
                Text('Updated: ${category.updatedAt?.toString() ?? 'Unknown'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditCategoryDialog(category, controller);
                },
                child: Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(category, controller);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showCreateCategoryDialog(MajorCategoryController controller) {
    final nameController = TextEditingController();
    final arabicNameController = TextEditingController();
    final imageController = TextEditingController();
    final parentIdController = TextEditingController();
    bool isFeatured = false;
    int status = 2; // Default: Pending

    showDialog(
      context: Get.context!,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Create New Category'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: arabicNameController,
                          decoration: InputDecoration(
                            labelText: 'Arabic Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: imageController,
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: parentIdController,
                          decoration: InputDecoration(
                            labelText: 'Parent ID (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: isFeatured,
                              onChanged:
                                  (value) => setState(
                                    () => isFeatured = value ?? false,
                                  ),
                            ),
                            Text('Featured'),
                          ],
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('Active')),
                            DropdownMenuItem(value: 2, child: Text('Pending')),
                            DropdownMenuItem(value: 3, child: Text('Inactive')),
                          ],
                          onChanged:
                              (value) => setState(() => status = value ?? 2),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty) {
                          Get.snackbar('Error', 'Name is required');
                          return;
                        }

                        final category = MajorCategoryModel(
                          name: nameController.text,
                          arabicName:
                              arabicNameController.text.isEmpty
                                  ? null
                                  : arabicNameController.text,
                          image:
                              imageController.text.isEmpty
                                  ? null
                                  : imageController.text,
                          isFeature: isFeatured,
                          status: status,
                          parentId:
                              parentIdController.text.isEmpty
                                  ? null
                                  : parentIdController.text,
                        );

                        final success = await controller.createCategory(
                          category,
                        );
                        if (success) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Create'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditCategoryDialog(
    MajorCategoryModel category,
    MajorCategoryController controller,
  ) {
    final nameController = TextEditingController(text: category.name);
    final arabicNameController = TextEditingController(
      text: category.arabicName ?? '',
    );
    final imageController = TextEditingController(text: category.image ?? '');
    final parentIdController = TextEditingController(
      text: category.parentId ?? '',
    );
    bool isFeatured = category.isFeature;
    int status = category.status;

    showDialog(
      context: Get.context!,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Edit Category'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: arabicNameController,
                          decoration: InputDecoration(
                            labelText: 'Arabic Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: imageController,
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: parentIdController,
                          decoration: InputDecoration(
                            labelText: 'Parent ID (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: isFeatured,
                              onChanged:
                                  (value) => setState(
                                    () => isFeatured = value ?? false,
                                  ),
                            ),
                            Text('Featured'),
                          ],
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('Active')),
                            DropdownMenuItem(value: 2, child: Text('Pending')),
                            DropdownMenuItem(value: 3, child: Text('Inactive')),
                          ],
                          onChanged:
                              (value) => setState(() => status = value ?? 2),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty) {
                          Get.snackbar('Error', 'Name is required');
                          return;
                        }

                        final updatedCategory = category.copyWith(
                          name: nameController.text,
                          arabicName:
                              arabicNameController.text.isEmpty
                                  ? null
                                  : arabicNameController.text,
                          image:
                              imageController.text.isEmpty
                                  ? null
                                  : imageController.text,
                          isFeature: isFeatured,
                          status: status,
                          parentId:
                              parentIdController.text.isEmpty
                                  ? null
                                  : parentIdController.text,
                        );

                        final success = await controller.updateCategory(
                          updatedCategory,
                        );
                        if (success) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(
    MajorCategoryModel category,
    MajorCategoryController controller,
  ) {
    showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.displayName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await controller.deleteCategory(category.id!);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
