import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/vendor_model.dart';
import '../data/vendor_repository.dart';
import '../../../controllers/auth_controller.dart';

class VendorController extends GetxController {
  static VendorController get instance => Get.find();

  final repository = VendorRepository.instance;
  final isLoading = false.obs;
  final isUpdate = false.obs;
  var isLoadinglogo = false.obs;

  Rx<VendorModel> profileData = VendorModel.empty().obs;
  Rx<VendorModel> vendorData = VendorModel.empty().obs;

  // UI-bound fields
  var enableCOD = false.obs;
  var enableIwintoPayment = false.obs;
  var website = ''.obs;
  var organizationBio = ''.obs;
  var organizationName = ''.obs;
  var storeMessage = ''.obs;
  var organizationDeleted = false.obs;
  var organizationActivated = true.obs;
  late String userId;
  RxBool isVendor = false.obs;
  // Text controllers for form fields
  late TextEditingController organizationBioController;
  late TextEditingController organizationNameController;
  late TextEditingController storeMessageController;

  @override
  void onInit() {
    super.onInit();
    // Initialize text controllers
    organizationBioController = TextEditingController();
    organizationNameController = TextEditingController();
    storeMessageController = TextEditingController();
    debugPrint("VendorController initialized with text controllers");
    fetchUserData();
  }

  String generateWhatsappUrl(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return 'https://wa.me/$clean';
  }

  String generateInstagramUrl(String username) {
    final clean = username.replaceAll('@', '').trim();
    return 'https://www.instagram.com/$clean';
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      profileData.value = VendorModel.empty();
      // Get current user ID from auth
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        final data = await repository.getVendorByUserId(currentUser.id);
        if (data != null) {
          profileData.value = data;
          userId = data.userId ?? '';
          initializeFromProfile(data, userId);
        }
      }
    } catch (e) {
      debugPrint('fetchUserData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVendorData(String vendorId) async {
    try {
      print("fetchVendorData $vendorId");
      isLoading.value = true;
      vendorData.value = VendorModel.empty();
      final vendor = await repository.getVendorById(vendorId);
      if (vendor != null) {
        vendorData.value = vendor;
        if (vendor.userId == profileData.value.userId) {
          isVendor.value = true;
        } else {
          isVendor.value = false;
        }
        userId = vendorId;
        initializeFromProfile(vendor, userId);
      }
    } catch (e) {
      debugPrint('fetchVendorData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<VendorModel> fetchVendorreturnedData(String vendorId) async {
    try {
      final vendor = await repository.getVendorById(vendorId);
      return vendor ?? VendorModel.empty();
    } catch (e) {
      debugPrint('fetchVendorreturnedData error: $e');
      return VendorModel.empty();
    }
  }

  void initializeFromProfile(VendorModel profile, String vendorId) {
    enableCOD.value = profile.enableCod;
    enableIwintoPayment.value = profile.enableIwintoPayment;
    website.value = profile.website;
    organizationBio.value = profile.organizationBio;
    organizationName.value = profile.organizationName;
    storeMessage.value = profile.storeMessage;
    organizationDeleted.value = profile.organizationDeleted;
    organizationActivated.value = profile.organizationActivated;
    userId = profile.userId ?? '';
    storeMessageController.text = profile.storeMessage;

    // Update text controllers - ensure they are initialized
    try {
      organizationBioController.text = profile.organizationBio;
      organizationNameController.text = profile.organizationName;
      storeMessageController.text = profile.storeMessage;
      debugPrint("Text controllers updated successfully");
    } catch (e) {
      debugPrint("Error updating text controllers: $e");
      // Re-initialize controllers if they are null
      organizationBioController = TextEditingController(
        text: profile.organizationBio,
      );
      organizationNameController = TextEditingController(
        text: profile.organizationName,
      );
      storeMessageController = TextEditingController(
        text: profile.storeMessage,
      );
    }
  }

  void clearProfileData() {
    profileData.value = VendorModel.empty();
  }

  @override
  void onClose() {
    try {
      organizationBioController.dispose();
      organizationNameController.dispose();
      storeMessageController.dispose();
    } catch (e) {
      debugPrint("Error disposing text controllers: $e");
    }
    super.onClose();
  }

  Future<void> saveVendorUpdates(String vendorId) async {
    isUpdate.value = true;
    try {
      // Controllers are already initialized in onInit()

      // Debug: Print current values
      debugPrint(
        "Current organizationBio value: ${organizationBioController.text}",
      );
      debugPrint(
        "Current organizationName value: ${organizationNameController.text}",
      );
      debugPrint("Current storeMessage value: ${storeMessageController.text}");

      // إنشاء نسخة محدثة من بيانات المتجر مع القيم المعدلة
      final updatedVendor = profileData.value.copyWith(
        enableCod: enableCOD.value,
        enableIwintoPayment: enableIwintoPayment.value,
        website: website.value.trim(),
        organizationBio: organizationBioController.text.trim(),
        organizationName: organizationNameController.text.trim(),
        storeMessage: storeMessageController.text.trim(),
        organizationDeleted: organizationDeleted.value,
        organizationActivated: organizationActivated.value,
      );

      // Debug: Print the updated vendor
      debugPrint(
        "Updated vendor organizationBio: ${updatedVendor.organizationBio}",
      );
      debugPrint("Updated vendor toJson: ${updatedVendor.toJson()}");

      await repository.updateVendorProfile(vendorId, updatedVendor);
      await fetchVendorData(vendorId);
    } catch (e) {
      debugPrint("saveVendorUpdates error: $e");
    } finally {
      isUpdate.value = false;
    }
  }

  // Location methods can be added here when needed
  // They require additional imports for map functionality
}
