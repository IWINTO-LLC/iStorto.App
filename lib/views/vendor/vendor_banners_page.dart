import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/vendor_banners_controller.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/vendor/add_vendor_banner_page.dart';

class VendorBannersPage extends StatelessWidget {
  final String vendorId;

  const VendorBannersPage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with vendorId
    final controller = Get.put(VendorBannersController(vendorId: vendorId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'vendor_banners_title'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.loadBanners(),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SafeArea(
          child: Column(
            children: [
              // Filter and Stats Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Stats Row
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.campaign,
                              title: 'vendor_total_banners'.tr,
                              value: controller.totalBanners.value.toString(),
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.visibility,
                              title: 'vendor_active_banners'.tr,
                              value: controller.activeBanners.value.toString(),
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              hintText: 'vendor_search_banners'.tr,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged:
                                (value) => controller.searchBanners(value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        PopupMenuButton<String>(
                          onSelected:
                              (value) => controller.filterByStatus(value),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'all',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.filter_list,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('vendor_all_banners'.tr),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'active',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('vendor_active_only'.tr),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'inactive',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.cancel,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('vendor_inactive_only'.tr),
                                    ],
                                  ),
                                ),
                              ],
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.filter_list,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Banners List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredBanners.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildBannersList(controller);
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(
            () => AddVendorBannerPage(vendorId: vendorId),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 300),
          );
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'vendor_add_banner'.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 20),
          Text(
            'vendor_no_banners'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'vendor_no_banners_subtitle'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(
                  () => AddVendorBannerPage(vendorId: vendorId),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 300),
                );
              },
              icon: const Icon(Icons.add),
              label: Text('vendor_add_first_banner'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersList(VendorBannersController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredBanners.length,
      itemBuilder: (context, index) {
        final banner = controller.filteredBanners[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  banner.image.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          banner.image,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.campaign,
                                color: Colors.black,
                              ),
                        ),
                      )
                      : const Icon(Icons.campaign, color: Colors.black),
            ),
            title: Text(
              banner.title ?? 'No Title',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (banner.description != null &&
                    banner.description!.isNotEmpty)
                  Text(
                    banner.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        banner.active
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    banner.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color: banner.active ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle') {
                  controller.toggleBannerStatus(banner);
                } else if (value == 'delete') {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Delete Banner'),
                      content: const Text(
                        'Are you sure you want to delete this banner?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.deleteBanner(banner);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            banner.active ? Icons.pause : Icons.play_arrow,
                            size: 20,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(banner.active ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
              child: const Icon(Icons.more_vert, color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}
