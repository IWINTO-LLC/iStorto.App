import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/search/controller/search_controller.dart'
    as search_controller;

/// ويدجت تاريخ البحث
class SearchHistoryWidget extends StatelessWidget {
  final Function(String) onSearchQuerySelected;

  const SearchHistoryWidget({super.key, required this.onSearchQuerySelected});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<search_controller.SearchController>(
      builder: (controller) {
        if (controller.searchHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان تاريخ البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'البحث السابق',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearSearchHistory();
                    },
                    child: const Text(
                      'مسح الكل',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة تاريخ البحث
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.searchHistory.length,
              itemBuilder: (context, index) {
                final query = controller.searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      // إزالة هذا البحث من التاريخ
                      controller.searchHistory.remove(query);
                    },
                  ),
                  onTap: () {
                    onSearchQuerySelected(query);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
