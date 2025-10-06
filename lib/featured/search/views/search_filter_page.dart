import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/search/data/search_model.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

/// صفحة فلاتر البحث الكاملة
class SearchFilterPage extends StatelessWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onFiltersApplied;

  const SearchFilterPage({
    super.key,
    required this.initialFilters,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    // إنشاء متحكم محلي للفلاتر
    final filterController = Get.put(FilterController(initialFilters));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'search_filters'.tr,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              filterController.resetFilters();
            },
            child: Text(
              'reset_filters'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _FilterPageContent(
        controller: filterController,
        onFiltersApplied: onFiltersApplied,
      ),
    );
  }
}

/// محتوى صفحة الفلاتر
class _FilterPageContent extends StatelessWidget {
  final FilterController controller;
  final Function(SearchFilters) onFiltersApplied;

  const _FilterPageContent({
    required this.controller,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // محتوى الفلاتر
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // فلتر نوع العنصر
                Obx(
                  () => _buildFilterSection(
                    'item_type'.tr,
                    [
                      'all'.tr,
                      'products'.tr,
                      'vendors'.tr,
                      'categories_filter'.tr,
                    ],
                    controller.currentFilters.itemType,
                    controller.updateItemType,
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtWsections),

                // فلتر السعر
                _buildPriceFilter(),
                const SizedBox(height: TSizes.spaceBtWsections),

                // فلتر التقييم
                Obx(
                  () => _buildFilterSection(
                    'rating'.tr,
                    [
                      'all'.tr,
                      '4 ${'stars_and_more'.tr}',
                      '3 ${'stars_and_more'.tr}',
                      '2 ${'stars_and_more'.tr}',
                    ],
                    controller.ratingText,
                    (value) {
                      int? rating;
                      final starsText = 'stars_and_more'.tr;
                      if (value == '4 $starsText') {
                        rating = 4;
                      } else if (value == '3 $starsText') {
                        rating = 3;
                      } else if (value == '2 $starsText') {
                        rating = 2;
                      } else {
                        rating = null;
                      }
                      controller.updateMinRating(rating);
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtWsections),

                // فلاتر إضافية
                _buildAdditionalFilters(),
                const SizedBox(height: TSizes.spaceBtWsections),
              ],
            ),
          ),
        ),

        // أزرار الإجراءات
        Container(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.resetFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'reset_filters'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onFiltersApplied(controller.currentFilters);
                      Get.back();
                      Get.snackbar(
                        'filters_applied'.tr,
                        'filters_applied_message'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'apply_filters'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قسم فلتر
  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected =
                    selectedValue == option ||
                    (selectedValue == null && option == 'all'.tr);

                return GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : TColors.textBlack,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// بناء فلتر السعر
  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'price_range'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'from'.tr,
                  hintText: 'minimum_price'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  controller.updateMinPrice(price);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'to'.tr,
                  hintText: 'maximum_price'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  controller.updateMaxPrice(price);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// بناء الفلاتر الإضافية
  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'additional_filters'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),

        // فلتر التحقق
        Obx(
          () => _buildSwitchFilter(
            'verified_vendors_only'.tr,
            controller.currentFilters.isVerified ?? false,
            (value) => controller.updateIsVerified(value),
          ),
        ),
        const SizedBox(height: 12),

        // فلتر المميز
        Obx(
          () => _buildSwitchFilter(
            'featured_products_only'.tr,
            controller.currentFilters.isFeatured ?? false,
            (value) => controller.updateIsFeatured(value),
          ),
        ),
      ],
    );
  }

  /// بناء فلتر المفتاح
  Widget _buildSwitchFilter(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: TColors.textBlack)),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.black),
      ],
    );
  }
}

/// متحكم فلاتر البحث
class FilterController extends GetxController {
  final Rx<SearchFilters> _currentFilters = SearchFilters().obs;

  FilterController(SearchFilters initialFilters) {
    _currentFilters.value = initialFilters;
  }

  SearchFilters get currentFilters => _currentFilters.value;

  void updateItemType(String? value) {
    _currentFilters.value = _currentFilters.value.copyWith(
      itemType: value == 'all'.tr ? null : value,
    );
  }

  void updateMinPrice(double? price) {
    _currentFilters.value = _currentFilters.value.copyWith(minPrice: price);
  }

  void updateMaxPrice(double? price) {
    _currentFilters.value = _currentFilters.value.copyWith(maxPrice: price);
  }

  void updateMinRating(int? rating) {
    _currentFilters.value = _currentFilters.value.copyWith(minRating: rating);
  }

  void updateIsVerified(bool? verified) {
    _currentFilters.value = _currentFilters.value.copyWith(
      isVerified: verified,
    );
  }

  void updateIsFeatured(bool? featured) {
    _currentFilters.value = _currentFilters.value.copyWith(
      isFeatured: featured,
    );
  }

  void resetFilters() {
    _currentFilters.value = SearchFilters();
  }

  // Getters للمعروض
  String? get itemType => _currentFilters.value.itemType;

  String get ratingText {
    final rating = _currentFilters.value.minRating;
    if (rating == null) return 'all'.tr;
    return '$rating ${'stars_and_more'.tr}';
  }
}
