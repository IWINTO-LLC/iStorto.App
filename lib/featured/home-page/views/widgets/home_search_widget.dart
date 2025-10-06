import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/search/controller/search_controller.dart'
    as search_controller;
import 'package:istoreto/featured/search/views/search_filter_page.dart';
import 'package:istoreto/featured/search/widgets/search_result_card.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/theme/theme.dart';
import 'package:sizer/sizer.dart';

/// ويدجت البحث في الصفحة الرئيسية
class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // التأكد من وجود SearchController
    Get.put(search_controller.SearchController());

    return GetBuilder<search_controller.SearchController>(
      builder: (controller) {
        return _SearchWidgetContent(controller: controller);
      },
    );
  }
}

/// محتوى ويدجت البحث
class _SearchWidgetContent extends StatelessWidget {
  final search_controller.SearchController controller;

  const _SearchWidgetContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20.w,

          child: const Image(image: AssetImage(TImages.istortoLogo)),
        ),
        // Text(
        //   'iStoreto',
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.bold,
        //     color: TColors.textBlack,
        //   ),
        // ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  _performSearch(controller, query);
                }
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
                  controller.quickSearch(value);
                } else {
                  controller.clearResults();
                }
              },
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // أيقونة الفلترة
        GestureDetector(
          onTap: () {
            _showFilterPage(context, controller);
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: TColors.tboxShadow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.filter_list, color: Colors.black, size: 20),
          ),
        ),
      ],
    );
  }

  /// تنفيذ البحث
  void _performSearch(
    search_controller.SearchController controller,
    String query,
  ) {
    controller.performSearch(query: query);
    _showSearchResults(query);
  }

  /// عرض نتائج البحث
  void _showSearchResults(String query) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان النتائج
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نتائج البحث عن: $query',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // عرض النتائج
            Expanded(
              child: GetBuilder<search_controller.SearchController>(
                builder: (controller) {
                  if (controller.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.searchResults.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final item = controller.searchResults[index];
                      return SearchResultCard(
                        item: item,
                        onTap: () {
                          controller.navigateToDetails(item);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// عرض صفحة الفلترة
  void _showFilterPage(
    BuildContext context,
    search_controller.SearchController controller,
  ) {
    Get.to(
      () => SearchFilterPage(
        initialFilters: controller.currentFilters,
        onFiltersApplied: (filters) {
          controller.applyFilters(filters);
          // عرض النتائج دائماً بعد تطبيق الفلاتر
          _showSearchResults(
            controller.currentQuery.isNotEmpty
                ? controller.currentQuery
                : 'all_results'.tr,
          );
        },
      ),
    );
  }
}
