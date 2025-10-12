import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/vendor_offers_controller.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_horz.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

/// صفحة عروض التاجر - تعرض جميع المنتجات التي عليها خصم
class VendorOffersPage extends StatelessWidget {
  final String vendorId;

  const VendorOffersPage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(
      VendorOffersController(vendorId: vendorId),
      tag: vendorId,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomAppBar(
          title: 'vendor_offers'.tr,
          centerTitle: true,
          isBackButtonExist: true,
        ),
        body: Column(
          children: [
            // شريط البحث والفلاتر
            _buildSearchBar(controller),

            const SizedBox(height: 16),

            // عدد النتائج
            Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.filteredOffers.length} ${'offers_found'.tr}',
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    // زر الفرز
                    _buildSortButton(controller),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // قائمة المنتجات
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }

                if (controller.filteredOffers.isEmpty) {
                  return _buildEmptyState(controller);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadOffers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.filteredOffers.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredOffers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProductWidgetHorzental(
                          product: product,
                          vendorId: vendorId,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// شريط البحث
  Widget _buildSearchBar(VendorOffersController controller) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.searchOffers(value),
              decoration: InputDecoration(
                hintText: 'search_offers'.tr,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
            ),
          ),
          // زر مسح البحث
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade400),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchOffers('');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// زر الفرز
  Widget _buildSortButton(VendorOffersController controller) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: TColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => controller.sortOffers(value),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'discount_high',
              child: Row(
                children: [
                  const Icon(Icons.arrow_downward, size: 18),
                  const SizedBox(width: 8),
                  Text('highest_discount'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'discount_low',
              child: Row(
                children: [
                  const Icon(Icons.arrow_upward, size: 18),
                  const SizedBox(width: 8),
                  Text('lowest_discount'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'price_high',
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 8),
                  Text('price_high_to_low'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'price_low',
              child: Row(
                children: [
                  const Icon(Icons.money_off, size: 18),
                  const SizedBox(width: 8),
                  Text('price_low_to_high'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'newest',
              child: Row(
                children: [
                  const Icon(Icons.new_releases, size: 18),
                  const SizedBox(width: 8),
                  Text('newest_first'.tr),
                ],
              ),
            ),
          ],
    );
  }

  /// حالة التحميل
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: const TShimmerEffect(width: double.infinity, height: 120),
        );
      },
    );
  }

  /// حالة عدم وجود منتجات
  Widget _buildEmptyState(VendorOffersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.searchController.text.isEmpty
                ? Icons.local_offer_outlined
                : Icons.search_off,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchController.text.isEmpty
                ? 'no_offers_available'.tr
                : 'no_offers_found'.tr,
            style: titilliumBold.copyWith(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchController.text.isEmpty
                ? 'vendor_has_no_offers'.tr
                : 'try_different_search'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
