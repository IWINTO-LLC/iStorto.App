import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/shop/controllers/vendor_categories_controller.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorCategoriesManagementPage extends StatelessWidget {
  final String vendorId;

  const VendorCategoriesManagementPage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorCategoriesController());

    // تحميل فئات التاجر عند البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVendorCategories(vendorId);
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'vendor_categories_management'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadVendorCategories(vendorId),
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
                  'no_vendor_categories_found'.tr,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'add_first_vendor_category'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.showAddCategoryDialog(vendorId),
                  icon: const Icon(Icons.add),
                  label: Text('add_vendor_category'.tr),
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
                        hintText: 'vendor_search_categories'.tr,
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
                            child: Obx(
                              () => Row(
                                children: [
                                  Icon(
                                    controller.currentFilter.value == 'all'
                                        ? Icons.check
                                        : Icons.filter_list,
                                    size: 20,
                                    color:
                                        controller.currentFilter.value == 'all'
                                            ? Colors.green
                                            : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'vendor_all_categories'.tr,
                                    style: TextStyle(
                                      color:
                                          controller.currentFilter.value ==
                                                  'all'
                                              ? Colors.green
                                              : null,
                                      fontWeight:
                                          controller.currentFilter.value ==
                                                  'all'
                                              ? FontWeight.bold
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'active',
                            child: Obx(
                              () => Row(
                                children: [
                                  Icon(
                                    controller.currentFilter.value == 'active'
                                        ? Icons.check
                                        : Icons.check_circle,
                                    size: 20,
                                    color:
                                        controller.currentFilter.value ==
                                                'active'
                                            ? Colors.green
                                            : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'vendor_active_categories'.tr,
                                    style: TextStyle(
                                      color:
                                          controller.currentFilter.value ==
                                                  'active'
                                              ? Colors.green
                                              : null,
                                      fontWeight:
                                          controller.currentFilter.value ==
                                                  'active'
                                              ? FontWeight.bold
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'inactive',
                            child: Obx(
                              () => Row(
                                children: [
                                  Icon(
                                    controller.currentFilter.value == 'inactive'
                                        ? Icons.check
                                        : Icons.cancel,
                                    size: 20,
                                    color:
                                        controller.currentFilter.value ==
                                                'inactive'
                                            ? Colors.green
                                            : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'vendor_inactive_categories'.tr,
                                    style: TextStyle(
                                      color:
                                          controller.currentFilter.value ==
                                                  'inactive'
                                              ? Colors.green
                                              : null,
                                      fontWeight:
                                          controller.currentFilter.value ==
                                                  'inactive'
                                              ? FontWeight.bold
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      controller.filteredCategories.length +
                      1, // +1 for spacing
                  itemBuilder: (context, index) {
                    // إضافة فراغ 100 بكسل بعد آخر عنصر
                    if (index == controller.filteredCategories.length) {
                      return const SizedBox(height: 100);
                    }

                    final category = controller.filteredCategories[index];
                    return _buildCategoryCard(controller, category);
                  },
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddCategoryDialog(vendorId),
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryCard(
    VendorCategoriesController controller,
    dynamic category,
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
                          _getTitle(category),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(_getIsActive(category)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_getDescription(category) != null &&
                      _getDescription(category)!.isNotEmpty)
                    Text(
                      _getDescription(category)!,
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
                            _getIsPrimary(category)
                                ? Colors.amber
                                : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getIsPrimary(category)
                            ? 'vendor_primary'.tr
                            : 'vendor_secondary'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              _getIsPrimary(category)
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${'vendor_priority'.tr}: ${_getPriority(category)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
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
                          Text('vendor_edit'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_primary',
                      child: Row(
                        children: [
                          Icon(
                            _getIsPrimary(category)
                                ? Icons.star_border
                                : Icons.star,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getIsPrimary(category)
                                ? 'vendor_remove_primary'.tr
                                : 'vendor_make_primary'.tr,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(
                            _getIsActive(category)
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getIsActive(category)
                                ? 'vendor_deactivate'.tr
                                : 'vendor_activate'.tr,
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
                            'vendor_delete'.tr,
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

  Widget _buildCategoryImage(dynamic category) {
    return TRoundedContainer(
      width: 90,
      height: 90,
      showBorder: true,
      radius: BorderRadius.circular(25),
      borderWidth: 3,
      borderColor: TColors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child:
            _getImage(category) != null && _getImage(category)!.isNotEmpty
                ? CustomCaChedNetworkImage(
                  width: 88,
                  height: 88,
                  raduis: BorderRadius.circular(25),
                  url: _getImage(category)!,
                )
                : Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.category, color: Colors.grey),
                ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    Color color = isActive ? Colors.green : Colors.red;
    String text = isActive ? 'vendor_active'.tr : 'vendor_inactive'.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
    VendorCategoriesController controller,
    String action,
    dynamic category,
  ) {
    switch (action) {
      case 'edit':
        controller.showEditCategoryDialog(category, vendorId);
        break;
      case 'toggle_primary':
        controller.togglePrimaryStatus(category, vendorId);
        break;
      case 'toggle_status':
        controller.toggleStatus(category, vendorId);
        break;
      case 'delete':
        controller.showDeleteConfirmation(category, vendorId);
        break;
    }
  }

  // Helpers to normalize models
  String _getTitle(dynamic c) {
    try {
      final t = (c as dynamic).title;
      if (t is String && t.isNotEmpty) return t;
    } catch (_) {}
    try {
      final dn = (c as dynamic).displayName;
      if (dn is String && dn.isNotEmpty) return dn;
    } catch (_) {}
    try {
      final n = (c as dynamic).name;
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
    return '';
  }

  String? _getDescription(dynamic c) {
    try {
      final d = (c as dynamic).customDescription;
      if (d is String && d.isNotEmpty) return d;
    } catch (_) {}
    try {
      final d = (c as dynamic).description;
      if (d is String && d.isNotEmpty) return d;
    } catch (_) {}
    return null;
  }

  bool _getIsActive(dynamic c) {
    try {
      final a = (c as dynamic).isActive;
      if (a is bool) return a;
    } catch (_) {}
    try {
      final s = (c as dynamic).status;
      if (s is int) return s == 1;
    } catch (_) {}
    return true;
  }

  bool _getIsPrimary(dynamic c) {
    try {
      final p = (c as dynamic).isPrimary;
      if (p is bool) return p;
    } catch (_) {}
    return false;
  }

  int _getPriority(dynamic c) {
    try {
      final p = (c as dynamic).priority;
      if (p is int) return p;
    } catch (_) {}
    try {
      final s = (c as dynamic).sortOrder;
      if (s is int) return s;
    } catch (_) {}
    return 0;
  }

  String? _getImage(dynamic c) {
    try {
      final i = (c as dynamic).icon;
      if (i is String && i.isNotEmpty) return i;
    } catch (_) {}
    try {
      final i = (c as dynamic).image;
      if (i is String && i.isNotEmpty) return i;
    } catch (_) {}
    return null;
  }
}
