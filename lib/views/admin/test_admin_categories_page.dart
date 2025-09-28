import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/admin_categories_controller.dart';

class TestAdminCategoriesPage extends StatelessWidget {
  const TestAdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminCategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Admin Categories'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      category.image?.isNotEmpty == true
                          ? NetworkImage(category.image!)
                          : null,
                  child:
                      category.image?.isEmpty != false
                          ? const Icon(Icons.category)
                          : null,
                ),
                title: Text(category.name),
                subtitle: Text(category.arabicName ?? ''),
                trailing: PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(value: 'edit', child: const Text('Edit')),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Text('Delete'),
                        ),
                      ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      controller.showEditCategoryDialog(category);
                    } else if (value == 'delete') {
                      controller.showDeleteConfirmation(category);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
