import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/admin_categories_controller.dart';

class SimpleAdminCategoriesPage extends StatelessWidget {
  const SimpleAdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminCategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفئات - Categories Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadCategories(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري التحميل...'),
              ],
            ),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 100,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                Text(
                  'لا توجد فئات',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'اضغط على + لإضافة فئة جديدة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => controller.showAddCategoryDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة فئة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'البحث في الفئات...',
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

            // Categories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.filteredCategories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: category.image?.isNotEmpty == true
                            ? NetworkImage(category.image!)
                            : null,
                        child: category.image?.isEmpty != false
                            ? const Icon(Icons.category)
                            : null,
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (category.arabicName?.isNotEmpty == true)
                            Text(
                              category.arabicName!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: category.status == 1
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category.status == 1 ? 'نشط' : 'غير نشط',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: category.status == 1
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (category.isFeature)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'مميز',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 16),
                                const SizedBox(width: 8),
                                const Text('تعديل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle_feature',
                            child: Row(
                              children: [
                                Icon(
                                  category.isFeature
                                      ? Icons.star_border
                                      : Icons.star,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(category.isFeature
                                    ? 'إزالة من المميز'
                                    : 'جعل مميز'),
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
                                Text(category.status == 1
                                    ? 'إلغاء التفعيل'
                                    : 'تفعيل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text('حذف', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
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
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddCategoryDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
