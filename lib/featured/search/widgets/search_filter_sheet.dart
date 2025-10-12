import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/search/data/search_model.dart';
import 'package:istoreto/utils/constants/color.dart';

/// ورقة فلاتر البحث
class SearchFilterSheet extends StatelessWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onFiltersApplied;

  const SearchFilterSheet({
    super.key,
    required this.initialFilters,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    // إنشاء متحكم محلي للفلاتر
    final filterController = Get.put(FilterController(initialFilters));

    return _FilterSheetContent(
      controller: filterController,
      onFiltersApplied: onFiltersApplied,
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
      itemType: value == 'الكل' ? null : value,
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

  void updateIsVerified(bool? value) {
    _currentFilters.value = _currentFilters.value.copyWith(isVerified: value);
  }

  void updateIsFeatured(bool? value) {
    _currentFilters.value = _currentFilters.value.copyWith(isFeatured: value);
  }

  void resetFilters() {
    _currentFilters.value = SearchFilters();
  }

  String? get ratingText {
    if (_currentFilters.value.minRating == null) return null;

    switch (_currentFilters.value.minRating) {
      case 4:
        return '4 نجوم وأكثر';
      case 3:
        return '3 نجوم وأكثر';
      case 2:
        return '2 نجوم وأكثر';
      default:
        return null;
    }
  }
}

/// محتوى ورقة الفلاتر
class _FilterSheetContent extends StatelessWidget {
  final FilterController controller;
  final Function(SearchFilters) onFiltersApplied;

  const _FilterSheetContent({
    required this.controller,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.8,
        minHeight: Get.height * 0.5,
      ),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الفلترة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فلترة البحث',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // محتوى الفلترة القابل للتمرير
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // فلتر نوع العنصر
                  Obx(
                    () => _buildFilterSection(
                      'نوع العنصر',
                      ['الكل', 'المنتجات', 'التجار', 'الفئات'],
                      controller.currentFilters.itemType,
                      controller.updateItemType,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // فلتر السعر
                  Obx(() => _buildPriceFilter()),

                  const SizedBox(height: 20),

                  // فلتر التقييم
                  Obx(
                    () => _buildFilterSection(
                      'التقييم',
                      ['الكل', '4 نجوم وأكثر', '3 نجوم وأكثر', '2 نجوم وأكثر'],
                      controller.ratingText,
                      (value) {
                        int? rating;
                        switch (value) {
                          case '4 نجوم وأكثر':
                            rating = 4;
                            break;
                          case '3 نجوم وأكثر':
                            rating = 3;
                            break;
                          case '2 نجوم وأكثر':
                            rating = 2;
                            break;
                          default:
                            rating = null;
                        }
                        controller.updateMinRating(rating);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // فلاتر إضافية
                  Obx(() => _buildAdditionalFilters()),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // أزرار الإجراء
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.resetFilters();
                  },
                  child: const Text('إعادة تعيين'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onFiltersApplied(controller.currentFilters);
                    Get.back();
                    Get.snackbar(
                      'تم تطبيق الفلترة',
                      'تم تطبيق الفلاتر المحددة',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('تطبيق الفلترة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء قسم الفلترة
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                final isSelected =
                    selectedValue == option ||
                    (selectedValue == null && option == options.first);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onChanged(option);
                    }
                  },
                  selectedColor: TColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: TColors.primary,
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
        const Text(
          'السعر',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'الحد الأدنى',
                  hintText:
                      controller.currentFilters.minPrice?.toString() ?? '0',
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
                  labelText: 'الحد الأقصى',
                  hintText:
                      controller.currentFilters.maxPrice?.toString() ?? '1000',
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
        const Text(
          'خيارات إضافية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // فلتر التحقق
        CheckboxListTile(
          title: const Text('التجار المحققين فقط'),
          value: controller.currentFilters.isVerified ?? false,
          onChanged: (value) {
            controller.updateIsVerified(value);
          },
          contentPadding: EdgeInsets.zero,
        ),

        // فلتر المميز
        CheckboxListTile(
          title: const Text('المنتجات المميزة فقط'),
          value: controller.currentFilters.isFeatured ?? false,
          onChanged: (value) {
            controller.updateIsFeatured(value);
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
