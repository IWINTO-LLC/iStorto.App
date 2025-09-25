// lib/featured/all-categories/widgets/category_search_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const CategorySearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'search_categories'.tr,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[500]),
            onPressed: onClearSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
