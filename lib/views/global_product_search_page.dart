import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/global_product_search_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/appbar.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/views/vendor/product_details_page.dart';

/// Global Product Search Page
///
/// Features:
/// - Search all products from all vendors
/// - Filter by vendors
/// - Sort by date, price (high to low, low to high)
/// - Modern black & white design
/// - Responsive layout
class GlobalProductSearchPage extends StatelessWidget {
  const GlobalProductSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GlobalProductSearchController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TAppBar(
        title: Text(
          'search_all_products'.tr,
          style: titilliumBold.copyWith(fontSize: 20, color: Colors.black),
        ),
        showBackArrow: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(controller),

            // Filter & Sort Row
            _buildFilterSortBar(controller),

            // Active Filters Display
            Obx(() {
              if (controller.hasActiveFilters) {
                return _buildActiveFilters(controller);
              }
              return const SizedBox.shrink();
            }),

            // Results Count
            Obx(() {
              if (!controller.isLoading.value &&
                  controller.searchResults.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${'found'.tr} ${controller.searchResults.length} ${'products'.tr}',
                      style: titilliumRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Products List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerList();
                }

                if (controller.searchResults.isEmpty) {
                  return _buildEmptyState(controller);
                }

                return _buildProductsList(controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(GlobalProductSearchController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.searchProducts(value),
        style: titilliumRegular.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'search_by_name_description'.tr,
          hintStyle: titilliumRegular.copyWith(
            fontSize: 16,
            color: Colors.grey[400],
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black, size: 24),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, color: Colors.black, size: 20),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchProducts('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSortBar(GlobalProductSearchController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter Button
          Expanded(child: _buildFilterButton(controller)),
          const SizedBox(width: 12),
          // Sort Button
          Expanded(child: _buildSortButton(controller)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(GlobalProductSearchController controller) {
    return Obx(() {
      final hasFilter = controller.selectedVendorId.value != null;
      return OutlinedButton.icon(
        onPressed: () => _showVendorFilter(controller),
        style: OutlinedButton.styleFrom(
          foregroundColor: hasFilter ? Colors.white : Colors.black,
          backgroundColor: hasFilter ? Colors.black : Colors.white,
          side: BorderSide(color: hasFilter ? Colors.black : Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: Icon(
          Icons.store,
          color: hasFilter ? Colors.white : Colors.black,
          size: 20,
        ),
        label: Text(
          'filter_by_vendor'.tr,
          style: titilliumBold.copyWith(
            fontSize: 14,
            color: hasFilter ? Colors.white : Colors.black,
          ),
        ),
      );
    });
  }

  Widget _buildSortButton(GlobalProductSearchController controller) {
    return Obx(() {
      final hasSort = controller.currentSortOption.value != 'none';
      return OutlinedButton.icon(
        onPressed: () => _showSortOptions(controller),
        style: OutlinedButton.styleFrom(
          foregroundColor: hasSort ? Colors.white : Colors.black,
          backgroundColor: hasSort ? Colors.black : Colors.white,
          side: BorderSide(color: hasSort ? Colors.black : Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: Icon(
          Icons.sort,
          color: hasSort ? Colors.white : Colors.black,
          size: 20,
        ),
        label: Text(
          'sort'.tr,
          style: titilliumBold.copyWith(
            fontSize: 14,
            color: hasSort ? Colors.white : Colors.black,
          ),
        ),
      );
    });
  }

  Widget _buildActiveFilters(GlobalProductSearchController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Vendor Filter Chip
          if (controller.selectedVendorId.value != null)
            Obx(() {
              final vendorName = controller.selectedVendorName.value;
              return Chip(
                label: Text(
                  vendorName,
                  style: titilliumRegular.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.black,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
                onDeleted: () => controller.clearVendorFilter(),
              );
            }),

          // Sort Filter Chip
          if (controller.currentSortOption.value != 'none')
            Obx(() {
              String sortLabel = '';
              switch (controller.currentSortOption.value) {
                case 'date_newest':
                  sortLabel = 'newest_first'.tr;
                  break;
                case 'date_oldest':
                  sortLabel = 'oldest_first'.tr;
                  break;
                case 'price_high':
                  sortLabel = 'price_high_to_low'.tr;
                  break;
                case 'price_low':
                  sortLabel = 'price_low_to_high'.tr;
                  break;
              }
              return Chip(
                label: Text(
                  sortLabel,
                  style: titilliumRegular.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.black,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
                onDeleted: () => controller.clearSort(),
              );
            }),

          // Clear All Button
          TextButton.icon(
            onPressed: () => controller.clearAllFilters(),
            icon: const Icon(Icons.clear_all, size: 16, color: Colors.red),
            label: Text(
              'clear_all'.tr,
              style: titilliumBold.copyWith(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(GlobalProductSearchController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final product = controller.searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(
            () => ProductDetailsPage(product: product),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.images.first,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const TShimmerEffect(width: 100, height: 100),
                  errorWidget:
                      (context, url, error) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.description?.isNotEmpty == true)
                      Text(
                        product.description ?? '',
                        style: titilliumRegular.copyWith(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.price}',
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.currency ?? 'USD',
                          style: titilliumRegular.copyWith(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(GlobalProductSearchController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.searchController.text.isEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchController.text.isEmpty
                ? 'start_searching'.tr
                : 'no_products_found'.tr,
            style: titilliumBold.copyWith(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchController.text.isEmpty
                ? 'search_hint'.tr
                : 'try_different_keywords'.tr,
            style: titilliumRegular.copyWith(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const TShimmerEffect(
                width: 100,
                height: 100,
                raduis: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerEffect(
                      width: double.infinity,
                      height: 16,
                      raduis: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    TShimmerEffect(
                      width: 200,
                      height: 14,
                      raduis: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    TShimmerEffect(
                      width: 100,
                      height: 20,
                      raduis: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVendorFilter(GlobalProductSearchController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'filter_by_vendor'.tr,
                      style: titilliumBold.copyWith(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Vendors List
              Flexible(
                child: Obx(() {
                  if (controller.vendors.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'no_vendors_available'.tr,
                          style: titilliumRegular.copyWith(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = controller.vendors[index];

                      return Obx(() {
                        final isSelected =
                            controller.selectedVendorId.value == vendor.id;

                        return ListTile(
                          onTap: () {
                            controller.filterByVendor(
                              vendor.id,
                              vendor.organizationName,
                            );
                            Get.back();
                          },
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                          title: Text(
                            vendor.organizationName,
                            style: titilliumBold.copyWith(
                              fontSize: 15,
                              color:
                                  isSelected ? Colors.black : Colors.grey[700],
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(Icons.check, color: Colors.black)
                                  : null,
                        );
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSortOptions(GlobalProductSearchController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'sort_by'.tr,
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Sort Options
            Obx(
              () => Column(
                children: [
                  _buildSortOption(
                    controller,
                    'date_newest',
                    'newest_first'.tr,
                    Icons.calendar_today,
                  ),
                  _buildSortOption(
                    controller,
                    'date_oldest',
                    'oldest_first'.tr,
                    Icons.history,
                  ),
                  _buildSortOption(
                    controller,
                    'price_high',
                    'price_high_to_low'.tr,
                    Icons.arrow_downward,
                  ),
                  _buildSortOption(
                    controller,
                    'price_low',
                    'price_low_to_high'.tr,
                    Icons.arrow_upward,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    GlobalProductSearchController controller,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.currentSortOption.value == value;
    return ListTile(
      onTap: () {
        controller.sortProducts(value);
        Get.back();
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.black : Colors.grey,
      ),
      title: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.black : Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: titilliumBold.copyWith(
              fontSize: 15,
              color: isSelected ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.black) : null,
    );
  }
}
