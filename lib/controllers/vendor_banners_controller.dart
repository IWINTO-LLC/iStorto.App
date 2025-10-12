import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/banner/data/banner_repository.dart';

class VendorBannersController extends GetxController {
  final String vendorId;
  final BannerRepository _repository = BannerRepository.instance;

  VendorBannersController({required this.vendorId});

  // Observable variables
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<BannerModel> filteredBanners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentFilter = 'all'.obs;
  final searchController = TextEditingController();

  // Stats
  final RxInt totalBanners = 0.obs;
  final RxInt activeBanners = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load vendor banners
  Future<void> loadBanners() async {
    try {
      isLoading.value = true;

      // جلب جميع البانرات التي لها vendor_id مساوي لـ vendorId بغض النظر عن scope
      final loadedBanners = await _repository.getAllVendorBannersByVendorId(
        vendorId,
      );

      banners.value = loadedBanners;
      filteredBanners.value = loadedBanners;

      // Update stats
      _updateStats();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load banners: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update statistics
  void _updateStats() {
    totalBanners.value = banners.length;
    activeBanners.value = banners.where((b) => b.active).length;
  }

  // Filter banners by status
  void filterByStatus(String status) {
    currentFilter.value = status;

    switch (status) {
      case 'active':
        filteredBanners.value = banners.where((b) => b.active).toList();
        break;
      case 'inactive':
        filteredBanners.value = banners.where((b) => !b.active).toList();
        break;
      default:
        filteredBanners.value = banners;
    }
  }

  // Search banners
  void searchBanners(String query) {
    if (query.isEmpty) {
      filterByStatus(currentFilter.value);
    } else {
      filteredBanners.value =
          banners.where((banner) {
            final titleMatch =
                banner.title?.toLowerCase().contains(query.toLowerCase()) ??
                false;
            final descMatch =
                banner.description?.toLowerCase().contains(
                  query.toLowerCase(),
                ) ??
                false;
            return titleMatch || descMatch;
          }).toList();
    }
  }

  // Toggle banner active status
  Future<void> toggleBannerStatus(BannerModel banner) async {
    try {
      final newStatus = !banner.active;
      await _repository.toggleBannerActive(banner.id!, newStatus);

      // Update local list
      final index = banners.indexWhere((b) => b.id == banner.id);
      if (index != -1) {
        banners[index] = banner.copyWith(active: newStatus);
        filterByStatus(currentFilter.value);
        _updateStats();
      }

      Get.snackbar(
        'Success',
        newStatus ? 'Banner activated' : 'Banner deactivated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update banner status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete banner
  Future<void> deleteBanner(BannerModel banner) async {
    try {
      await _repository.deleteBanner(banner.id!);

      // Remove from local list
      banners.removeWhere((b) => b.id == banner.id);
      filterByStatus(currentFilter.value);
      _updateStats();

      Get.snackbar(
        'Success',
        'Banner deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete banner: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add new banner
  Future<void> addBanner(BannerModel banner) async {
    try {
      final createdBanner = await _repository.createBanner(banner);

      // Add to local list
      banners.insert(0, createdBanner);
      filterByStatus(currentFilter.value);
      _updateStats();
    } catch (e) {
      throw 'Failed to add banner: ${e.toString()}';
    }
  }
}
