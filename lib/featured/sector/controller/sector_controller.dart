import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/featured/sector/repository/sector_repository.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/logging/logger.dart';

class SectorController extends GetxController {
  static SectorController get instance => Get.find();
  SectorController(this.vendorId);
  late String vendorId;

  @override
  void onInit() {
    super.onInit();
    fetchSectors(); // جلب البيانات عند البدء
  }

  // Observable lists
  var sectors = <SectorModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Repository
  final SectorRepository _repository = SectorRepository();

  // Cache management
  String? lastFetchedUserId;

  /// إنشاء الأقسام الافتراضية لتاجر جديد
  Future<void> createDefaultSections(String vendorId) async {
    try {
      isLoading.value = true;
      final success = await _repository.createDefaultSections(vendorId);

      if (success) {
        TLoggerHelper.info("Default sections created for vendor: $vendorId");
        await fetchSectors(); // إعادة تحميل الأقسام
      }
    } catch (e) {
      errorMessage.value = "Failed to create default sections: $e";
      TLoggerHelper.error("Error creating default sections: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب أقسام التاجر من قاعدة البيانات
  Future<void> fetchSectors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      var fetchedSectors = await _repository.getVendorSections(vendorId);

      if (fetchedSectors.isEmpty) {
        // محاولة إنشاء الأقسام الافتراضية
        print('📋 No sections found, creating default sections...');
        await _repository.createDefaultSections(vendorId);
        fetchedSectors = await _repository.getVendorSections(vendorId);

        if (fetchedSectors.isEmpty) {
          // استخدام الأقسام الافتراضية من الكود
          sectors.value = initialSector;
          TLoggerHelper.info("Using hardcoded initial sectors");
        } else {
          sectors.value = fetchedSectors;
          TLoggerHelper.info(
            "Fetched ${fetchedSectors.length} default sections",
          );
        }
      } else {
        sectors.value = fetchedSectors;
        TLoggerHelper.info(
          "Fetched ${fetchedSectors.length} sectors from database",
        );
      }

      lastFetchedUserId = vendorId;
    } catch (e) {
      errorMessage.value = "Failed to fetch sectors: $e";
      TLoggerHelper.error("Error fetching sectors: $e");
      sectors.value = initialSector; // Fallback to initial sectors
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث قسم
  Future<void> updateSection(SectorModel sector) async {
    try {
      // Update in database
      final updated = await _repository.updateSection(sector);

      if (updated != null) {
        // Update in local list
        final index = sectors.indexWhere((s) => s.id == sector.id);
        if (index != -1) {
          sectors[index] = updated;
          sectors.refresh();
        }

        TLoggerHelper.info("Section updated successfully: ${sector.id}");
      }
    } catch (e) {
      errorMessage.value = "Failed to update section: $e";
      TLoggerHelper.error("Error updating section: $e");

      // رسالة خطأ فقط
      Get.snackbar(
        "error".tr,
        "فشل في تحديث القسم: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// تحديث اسم القسم فقط
  Future<void> updateSectionDisplayName({
    required String sectionId,
    required String displayName,
    String? arabicName,
  }) async {
    try {
      final success = await _repository.updateSectionDisplayName(
        sectionId: sectionId,
        displayName: displayName,
        arabicName: arabicName,
      );

      if (success) {
        // Update in local list
        final index = sectors.indexWhere((s) => s.id == sectionId);
        if (index != -1) {
          sectors[index] = sectors[index].copyWith(
            englishName: displayName,
            arabicName: arabicName,
          );
          sectors.refresh();
        }

        Get.snackbar(
          "success".tr,
          "تم تحديث اسم القسم بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "فشل في تحديث اسم القسم",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// تحديث طريقة العرض
  Future<void> updateSectionDisplayType({
    required String sectionId,
    required String displayType,
    double? cardWidth,
    double? cardHeight,
    int? itemsPerRow,
  }) async {
    try {
      final success = await _repository.updateSectionDisplayType(
        sectionId: sectionId,
        displayType: displayType,
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        itemsPerRow: itemsPerRow,
      );

      if (success) {
        // Update in local list
        final index = sectors.indexWhere((s) => s.id == sectionId);
        if (index != -1) {
          sectors[index] = sectors[index].copyWith(
            displayType: displayType,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            itemsPerRow: itemsPerRow,
          );
          sectors.refresh();
        }

        Get.snackbar(
          "success".tr,
          "تم تحديث طريقة العرض بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "فشل في تحديث طريقة العرض",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// إضافة قسم جديد
  Future<void> addSection(SectorModel sector) async {
    try {
      isLoading.value = true;
      final created = await _repository.createSection(sector);

      if (created != null) {
        sectors.add(created);
        Get.snackbar(
          "success".tr,
          "تم إضافة القسم بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "فشل في إضافة القسم",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف قسم
  Future<void> deleteSection(String sectionId) async {
    try {
      isLoading.value = true;
      final success = await _repository.deleteSection(sectionId);

      if (success) {
        sectors.removeWhere((s) => s.id == sectionId);
        Get.snackbar(
          "success".tr,
          "تم حذف القسم بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "فشل في حذف القسم",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تبديل حالة القسم
  Future<void> toggleSectionActive(String sectionId, bool isActive) async {
    try {
      final success = await _repository.toggleSectionActive(
        sectionId,
        isActive,
      );

      if (success) {
        final index = sectors.indexWhere((s) => s.id == sectionId);
        if (index != -1) {
          sectors[index] = sectors[index].copyWith(isActive: isActive);
          sectors.refresh();
        }
      }
    } catch (e) {
      print('Error toggling section active: $e');
    }
  }

  /// تحديث ترتيب الأقسام
  Future<void> updateSectionsOrder(List<SectorModel> reorderedSections) async {
    try {
      final success = await _repository.updateSectionsOrder(reorderedSections);

      if (success) {
        sectors.value = reorderedSections;
        Get.snackbar(
          "success".tr,
          "تم تحديث ترتيب الأقسام بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "فشل في تحديث ترتيب الأقسام",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// Get sector by ID
  SectorModel? getSectorById(String sectorId) {
    try {
      return sectors.firstWhere((sector) => sector.id == sectorId);
    } catch (e) {
      TLoggerHelper.warning("Sector not found: $sectorId");
      return null;
    }
  }

  /// Get sector name by ID and language
  String getSectorName(String sectorId, String lang) {
    final sector = getSectorById(sectorId);
    if (sector != null) {
      return sector.englishName;
    }
    return "Default Name";
  }

  /// Clear cache and refresh data
  void clearCache() {
    lastFetchedUserId = null;
    sectors.clear();
    errorMessage.value = '';
  }

  /// Refresh sectors data
  Future<void> refreshSectors() async {
    if (vendorId.isNotEmpty) {
      clearCache();
      await fetchSectors();
    }
  }

  /// Get sectors count
  int get sectorsCount => sectors.length;

  /// Check if sectors are empty
  bool get hasSectors => sectors.isNotEmpty;

  /// Get sectors for dropdown or list
  List<SectorModel> get sectorsList => sectors.toList();
}
