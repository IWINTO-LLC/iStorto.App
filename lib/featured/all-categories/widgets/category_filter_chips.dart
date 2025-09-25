// lib/featured/all-categories/widgets/category_filter_chips.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/major_category_controller.dart';

class CategoryFilterChips extends StatelessWidget {
  final Function(int) onStatusFilterChanged;
  final VoidCallback onFeaturedFilterChanged;
  final VoidCallback onClearFilters;

  const CategoryFilterChips({
    super.key,
    required this.onStatusFilterChanged,
    required this.onFeaturedFilterChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MajorCategoryController>();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // All categories chip
            _buildFilterChip(
              label: 'all'.tr,
              isSelected: controller.selectedStatus == 0,
              onSelected: () => onStatusFilterChanged(0),
              color: Colors.blue,
            ),

            const SizedBox(width: 8),

            // Active categories chip
            _buildFilterChip(
              label: 'active'.tr,
              isSelected: controller.selectedStatus == 1,
              onSelected: () => onStatusFilterChanged(1),
              color: Colors.green,
            ),

            const SizedBox(width: 8),

            // Pending categories chip
            _buildFilterChip(
              label: 'pending'.tr,
              isSelected: controller.selectedStatus == 2,
              onSelected: () => onStatusFilterChanged(2),
              color: Colors.orange,
            ),

            const SizedBox(width: 8),

            // Inactive categories chip
            _buildFilterChip(
              label: 'inactive'.tr,
              isSelected: controller.selectedStatus == 3,
              onSelected: () => onStatusFilterChanged(3),
              color: Colors.red,
            ),

            const SizedBox(width: 8),

            // Featured categories chip
            _buildFilterChip(
              label: 'featured'.tr,
              isSelected: controller.showFeaturedOnly,
              onSelected: onFeaturedFilterChanged,
              color: Colors.amber,
              icon: Icons.star,
            ),

            const SizedBox(width: 8),

            // Clear filters chip
            _buildFilterChip(
              label: 'clear_filters'.tr,
              isSelected: false,
              onSelected: onClearFilters,
              color: Colors.grey,
              icon: Icons.clear,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color color,
    IconData? icon,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
