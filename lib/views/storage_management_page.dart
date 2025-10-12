import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/storage_management_controller.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/appbar.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

/// Storage Management Page
///
/// Features:
/// - View storage usage by category
/// - Clear cache
/// - Delete temporary files
/// - Manage downloads
/// - Clear app data
class StorageManagementPage extends StatelessWidget {
  const StorageManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StorageManagementController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'storage_management'.tr,

        isBackButtonExist: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshStorageInfo(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Storage Card
                _buildTotalStorageCard(controller),

                const SizedBox(height: 24),

                // Storage Breakdown
                Text(
                  'storage_breakdown'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingShimmer();
                  }
                  return Column(
                    children: [
                      _buildStorageItem(
                        controller: controller,
                        icon: Icons.image,
                        title: 'images'.tr,
                        size: controller.imagesSize.value,
                        color: Colors.black,
                        onClear: () => controller.clearImages(),
                      ),
                      _buildStorageItem(
                        controller: controller,
                        icon: Icons.video_library,
                        title: 'videos'.tr,
                        size: controller.videosSize.value,
                        color: Colors.purple,
                        onClear: () => controller.clearVideos(),
                      ),
                      _buildStorageItem(
                        controller: controller,
                        icon: Icons.cached,
                        title: 'cache'.tr,
                        size: controller.cacheSize.value,
                        color: Colors.orange,
                        onClear: () => controller.clearCache(),
                      ),
                      _buildStorageItem(
                        controller: controller,
                        icon: Icons.download,
                        title: 'downloads'.tr,
                        size: controller.downloadsSize.value,
                        color: Colors.green,
                        onClear: () => controller.clearDownloads(),
                      ),
                      _buildStorageItem(
                        controller: controller,
                        icon: Icons.description,
                        title: 'documents'.tr,
                        size: controller.documentsSize.value,
                        color: Colors.red,
                        onClear: () => controller.clearDocuments(),
                      ),
                      _buildStorageItem(
                        controller: controller,
                        icon: Icons.folder,
                        title: 'other_files'.tr,
                        size: controller.otherSize.value,
                        color: Colors.grey,
                        onClear: () => controller.clearOther(),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'quick_actions'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                _buildActionButton(
                  icon: Icons.cleaning_services,
                  title: 'clear_all_cache'.tr,
                  subtitle: 'free_up_space_quickly'.tr,
                  //  color: Colors.orange,
                  onTap: () => _showClearCacheDialog(controller),
                ),

                _buildActionButton(
                  icon: Icons.delete_sweep,
                  title: 'clear_temp_files'.tr,
                  subtitle: 'remove_temporary_files'.tr,
                  //  color: Colors.blue,
                  onTap: () => _showClearTempDialog(controller),
                ),

                _buildActionButton(
                  icon: Icons.refresh,
                  title: 'optimize_storage'.tr,
                  subtitle: 'compress_and_optimize'.tr,
                  //color: Colors.green,
                  onTap: () => _showOptimizeDialog(controller),
                ),

                // const SizedBox(height: 24),

                // // Danger Zone
                // Text(
                //   'danger_zone'.tr,
                //   style: titilliumBold.copyWith(
                //     fontSize: 18,
                //     color: Colors.red,
                //   ),
                // ),
                const SizedBox(height: 12),

                _buildActionButton(
                  icon: Icons.delete_forever,
                  title: 'clear_all_data'.tr,
                  subtitle: 'delete_all_app_data'.tr,
                  //   color: Colors.red,
                  onTap: () => _showClearAllDataDialog(controller),
                  isDanger: true,
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalStorageCard(StorageManagementController controller) {
    return Obx(() {
      final totalSize = controller.totalSize.value;
      final usedSize = controller.usedSize.value;
      final percentage = totalSize > 0 ? (usedSize / totalSize * 100) : 0.0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total_storage'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.storage, color: Colors.black, size: 28),
              ],
            ),
            const SizedBox(height: 20),

            // Storage Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 80
                      ? Colors.red
                      : percentage > 50
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Storage Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'used'.tr,
                      style: titilliumRegular.copyWith(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatBytes(usedSize),
                      style: titilliumBold.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'available'.tr,
                      style: titilliumRegular.copyWith(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatBytes(totalSize - usedSize),
                      style: titilliumBold.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '${percentage.toStringAsFixed(1)}% ${'used'.tr}',
              style: titilliumRegular.copyWith(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStorageItem({
    required StorageManagementController controller,
    required IconData icon,
    required String title,
    required int size,
    required Color color,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),

          const SizedBox(width: 16),

          // Title and Size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titilliumBold.copyWith(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatBytes(size),
                  style: titilliumRegular.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Clear Button
          if (size > 0)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'clear'.tr,
                style: titilliumBold.copyWith(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,

    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDanger ? Colors.red.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        title: Text(
          title,
          style: titilliumBold.copyWith(
            fontSize: 16,
            color: isDanger ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: titilliumRegular.copyWith(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        6,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(StorageManagementController controller) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Text('clear_cache'.tr),
          ],
        ),
        content: Text('clear_cache_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }

  void _showClearTempDialog(StorageManagementController controller) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Text('clear_temp_files'.tr),
          ],
        ),
        content: Text('clear_temp_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.clearTempFiles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }

  void _showOptimizeDialog(StorageManagementController controller) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.refresh, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Text('optimize_storage'.tr),
          ],
        ),
        content: Text('optimize_storage_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.optimizeStorage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('optimize'.tr),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog(StorageManagementController controller) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Text('clear_all_data'.tr, style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('clear_all_data_warning'.tr),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'this_action_cannot_be_undone'.tr,
                      style: titilliumBold.copyWith(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete_all'.tr),
          ),
        ],
      ),
    );
  }
}
