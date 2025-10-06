import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/data/models/major_category_model.dart';
import 'package:istoreto/data/models/vendor_category_model.dart';
import 'package:istoreto/data/repositories/vendor_category_repository.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';

/// صفحة عرض التجار لفئة معينة
/// Category Vendors Page
class CategoryVendorsPage extends StatelessWidget {
  final MajorCategoryModel category;

  const CategoryVendorsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: category.displayName, centerTitle: true),
      body: Container(
        color: Colors.grey.shade50,
        child: SafeArea(child: _CategoryVendorsContent(category: category)),
      ),
    );
  }
}

/// محتوى صفحة التجار
/// Category Vendors Content
class _CategoryVendorsContent extends StatelessWidget {
  final MajorCategoryModel category;

  const _CategoryVendorsContent({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Category Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child:
                    category.image != null && category.image!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            category.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.store,
                                color: TColors.primary,
                                size: 40,
                              );
                            },
                          ),
                        )
                        : Icon(Icons.store, color: TColors.primary, size: 40),
              ),
              const SizedBox(height: 16),
              // Category Name
              Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'vendors_in_category'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Vendors List
        Expanded(child: _VendorsList(category: category)),
      ],
    );
  }
}

/// قائمة التجار
/// Vendors List
class _VendorsList extends StatelessWidget {
  final MajorCategoryModel category;

  const _VendorsList({required this.category});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VendorCategoryModel>>(
      future: _getVendorsForCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'error_loading_vendors'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Refresh the page
                    Get.off(() => CategoryVendorsPage(category: category));
                  },
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        final vendors = snapshot.data ?? [];

        if (vendors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_vendors_in_category'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'no_vendors_in_category_subtitle'.tr,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            final vendorCategory = vendors[index];
            return _VendorCard(vendorCategory: vendorCategory);
          },
        );
      },
    );
  }

  /// الحصول على التجار لفئة معينة
  /// Get vendors for a specific category
  Future<List<VendorCategoryModel>> _getVendorsForCategory() async {
    try {
      // Since we removed the connection to major categories,
      // we'll search for vendor categories by title matching the major category name
      final repository = Get.put(VendorCategoryRepository());

      // Search for vendor categories that have the same title as the major category
      return await repository.searchVendorCategories(
        '', // Empty vendorId to search all vendors
        category.displayName, // Search by major category name
      );
    } catch (e) {
      print('Error loading vendors for category ${category.id}: $e');
      throw Exception('Failed to load vendors: ${e.toString()}');
    }
  }
}

/// بطاقة التاجر
/// Vendor Card
class _VendorCard extends StatelessWidget {
  final VendorCategoryModel vendorCategory;

  const _VendorCard({required this.vendorCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onVendorTap(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vendor Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Icon(Icons.store, color: TColors.primary, size: 30),
                ),
              ),

              const SizedBox(width: 16),

              // Vendor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Title
                    Text(
                      vendorCategory.title.isNotEmpty
                          ? vendorCategory.title
                          : 'Unknown Category',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Vendor ID (for identification)
                    Text(
                      'Vendor ID: ${vendorCategory.vendorId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Specialization Level
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'specialization_level'.tr +
                              ': ${vendorCategory.specializationLevel}/5',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Priority and Status
                    Row(
                      children: [
                        if (vendorCategory.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'primary'.tr,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (vendorCategory.isPrimary) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                vendorCategory.isActive
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vendorCategory.isActive
                                ? 'active'.tr
                                : 'inactive'.tr,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  vendorCategory.isActive
                                      ? Colors.blue
                                      : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// عند النقر على التاجر
  /// On vendor tap
  void _onVendorTap() {
    Get.snackbar(
      vendorCategory.title.isNotEmpty ? vendorCategory.title : 'Category',
      'vendor_selected'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.primary,
      colorText: Colors.white,
    );

    // يمكن إضافة التنقل إلى صفحة التاجر هنا
    // You can add navigation to vendor page here
    // Get.to(() => VendorDetailsPage(vendorCategory: vendorCategory));
  }
}
