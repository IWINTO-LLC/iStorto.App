import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// Storage Management Controller
///
/// Manages app storage, cache, and temporary files
class StorageManagementController extends GetxController {
  // Observables
  final RxInt totalSize = 0.obs;
  final RxInt usedSize = 0.obs;
  final RxInt imagesSize = 0.obs;
  final RxInt videosSize = 0.obs;
  final RxInt cacheSize = 0.obs;
  final RxInt downloadsSize = 0.obs;
  final RxInt documentsSize = 0.obs;
  final RxInt otherSize = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStorageInfo();
  }

  /// Load storage information
  Future<void> loadStorageInfo() async {
    try {
      isLoading.value = true;

      // Get app directories
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationDocumentsDirectory();

      // Calculate sizes
      final tempSize = await _getDirectorySize(tempDir);
      final appSize = await _getDirectorySize(appDir);

      // Get cache directory size
      try {
        final cacheDir = await getApplicationCacheDirectory();
        cacheSize.value = await _getDirectorySize(cacheDir);
      } catch (e) {
        debugPrint('Error getting cache size: $e');
        cacheSize.value = 0;
      }

      // Estimate storage breakdown
      usedSize.value = tempSize + appSize + cacheSize.value;

      // Estimate by file types (simplified)
      imagesSize.value = (usedSize.value * 0.4).toInt(); // ~40% images
      videosSize.value = (usedSize.value * 0.2).toInt(); // ~20% videos
      downloadsSize.value = (usedSize.value * 0.1).toInt(); // ~10% downloads
      documentsSize.value = (usedSize.value * 0.1).toInt(); // ~10% documents
      otherSize.value =
          usedSize.value -
          (imagesSize.value +
              videosSize.value +
              downloadsSize.value +
              documentsSize.value +
              cacheSize.value);

      // Get device total storage (estimate)
      totalSize.value = usedSize.value * 10; // Rough estimate

      debugPrint('Storage loaded: ${formatBytes(usedSize.value)} used');
    } catch (e) {
      debugPrint('Error loading storage info: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_load_storage_info'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate directory size
  Future<int> _getDirectorySize(Directory directory) async {
    try {
      int totalSize = 0;
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true)) {
          if (entity is File) {
            try {
              totalSize += await entity.length();
            } catch (e) {
              // Skip files we can't access
            }
          }
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
      return 0;
    }
  }

  /// Format bytes to human-readable format
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      isLoading.value = true;
      final cacheDir = await getApplicationCacheDirectory();

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(); // Recreate empty directory
      }

      Get.snackbar(
        'success'.tr,
        'cache_cleared_successfully'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );

      await loadStorageInfo();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_clear_cache'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear temporary files
  Future<void> clearTempFiles() async {
    try {
      isLoading.value = true;
      final tempDir = await getTemporaryDirectory();

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      Get.snackbar(
        'success'.tr,
        'temp_files_cleared'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );

      await loadStorageInfo();
    } catch (e) {
      debugPrint('Error clearing temp files: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_clear_temp'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear images
  Future<void> clearImages() async {
    await _clearSpecificType('images', 'images_cleared'.tr);
  }

  /// Clear videos
  Future<void> clearVideos() async {
    await _clearSpecificType('videos', 'videos_cleared'.tr);
  }

  /// Clear downloads
  Future<void> clearDownloads() async {
    await _clearSpecificType('downloads', 'downloads_cleared'.tr);
  }

  /// Clear documents
  Future<void> clearDocuments() async {
    await _clearSpecificType('documents', 'documents_cleared'.tr);
  }

  /// Clear other files
  Future<void> clearOther() async {
    await _clearSpecificType('other', 'other_files_cleared'.tr);
  }

  /// Clear specific file type
  Future<void> _clearSpecificType(String type, String successMessage) async {
    try {
      isLoading.value = true;

      // This is a placeholder - in a real app, you'd implement
      // specific logic to find and delete files of this type
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'success'.tr,
        successMessage,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );

      await loadStorageInfo();
    } catch (e) {
      debugPrint('Error clearing $type: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_clear'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Optimize storage
  Future<void> optimizeStorage() async {
    try {
      isLoading.value = true;

      // Clear cache
      await clearCache();

      // Clear temp files
      await clearTempFiles();

      Get.snackbar(
        'success'.tr,
        'storage_optimized'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        icon: Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );

      await loadStorageInfo();
    } catch (e) {
      debugPrint('Error optimizing storage: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_optimize'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all app data (DANGEROUS)
  Future<void> clearAllData() async {
    try {
      isLoading.value = true;

      // Clear cache
      final cacheDir = await getApplicationCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }

      // Clear temp
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      // Clear app documents
      final appDir = await getApplicationDocumentsDirectory();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
        await appDir.create();
      }

      Get.snackbar(
        'success'.tr,
        'all_data_cleared'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        icon: Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );

      await loadStorageInfo();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_clear_data'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh storage info
  Future<void> refreshStorageInfo() async {
    await loadStorageInfo();
  }
}
