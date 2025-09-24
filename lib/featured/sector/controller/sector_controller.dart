import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/featured/sector/model/sector_repository.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/loader/loaders.dart';
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

  // Controller state
  final repository = Get.put(SectorRepository());

  // Cache management
  String? lastFetchedUserId;

  /// Initialize sectors collection for a vendor
  Future<void> initialSectors(String vendorId) async {
    try {
      isLoading.value = true;
      await repository.initializeSectorCollection(vendorId);
      TLoggerHelper.info(
        "Sectors collection initialized for vendor: $vendorId",
      );
    } catch (e) {
      errorMessage.value = "Failed to initialize sectors: $e";
      TLoggerHelper.error("Error initializing sectors: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch sectors for a vendor with caching
  Future<void> fetchSectors() async {
    // if (lastFetchedUserId == vendorId && sectors.isNotEmpty) {
    //   TLoggerHelper.info("Sectors already fetched for vendor: $vendorId");
    //   return;
    // }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      var fetchedSectors = await repository.getAllSectors(vendorId);

      if (fetchedSectors.isEmpty) {
        sectors.value = initialSector;
        TLoggerHelper.info("No sectors found, using initial sectors");
      } else {
        sectors.value = fetchedSectors;
        TLoggerHelper.info("Fetched ${fetchedSectors.length} sectors");
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

  /// Update sector name using copyWith for immutability
  Future<void> updateSectorName(SectorModel sector) async {
    try {
      TLoader.progressSnackBar(title: "تحديث", message: "جاري تحديث القطاع...");

      // Update in repository
      // await repository.updateSectorByName(sector);

      // Update in local list using copyWith
      final index = sectors.indexWhere((s) => s.id == sector.id);
      if (index != -1) {
        sectors[index] = sector.copyWith(); // Create a new instance
        sectors.refresh(); // Trigger UI update using GetX
      }

      TLoader.stopProgress();

      // استخدام GetX snackbar بدلاً من TLoader
      Get.snackbar(
        "نجح",
        "تم تحديث القطاع بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      TLoggerHelper.info("Sector updated successfully: ${sector.id}");
    } catch (e) {
      TLoader.stopProgress();
      errorMessage.value = "Failed to update sector: $e";

      // استخدام GetX snackbar للخطأ
      Get.snackbar(
        "خطأ",
        "فشل في تحديث القطاع: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      TLoggerHelper.error("Error updating sector: $e");
    }
  }

  /// Add new sector to Firestore
  Future<void> addSector(SectorModel sector) async {}

  /// Delete sector from Firestore
  Future<void> deleteSector(String sectorId) async {
    // try {
    //   isLoading.value = true;

    //   // Delete from Firestore
    //   await firestore
    //       .collection('users')
    //       .doc(vendorId)
    //       .collection('organization')
    //       .doc('1')
    //       .collection('sectors')
    //       .doc(sectorId)
    //       .delete();

    //   // Remove from local list
    //   sectors.removeWhere((sector) => sector.id == sectorId);

    //   TLoader.successSnackBar(title: "نجح", message: "تم حذف القطاع بنجاح");

    //   TLoggerHelper.info("Sector deleted successfully: $sectorId");
    // } catch (e) {
    //   errorMessage.value = "Failed to delete sector: $e";
    //   TLoader.warningSnackBar(title: "خطأ", message: "فشل في حذف القطاع: $e");
    //   TLoggerHelper.error("Error deleting sector: $e");
    // } finally {
    //   isLoading.value = false;
    // }
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
