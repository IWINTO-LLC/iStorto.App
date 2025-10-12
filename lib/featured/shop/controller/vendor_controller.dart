import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/vendor_model.dart';
import '../data/social-link.dart';
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
  var organizationbrief = ''.obs;
  var organizationName = ''.obs;
  var storeMessage = ''.obs;
  var organizationDeleted = false.obs;
  var organizationActivated = true.obs;
  late String userId;
  RxBool isVendor = false.obs;

  // Statistics
  RxInt productsCount = 0.obs;
  RxInt followersCount = 0.obs;
  RxInt offersCount = 0.obs;

  // Follow status
  RxBool isFollowing = false.obs;
  RxBool isFollowLoading = false.obs;
  // Text controllers for form fields
  late TextEditingController organizationBioController;
  late TextEditingController organizationNameController;
  late TextEditingController storeMessageController;
  late TextEditingController briefController;

  @override
  void onInit() {
    super.onInit();
    // Initialize text controllers
    organizationBioController = TextEditingController();
    organizationNameController = TextEditingController();
    storeMessageController = TextEditingController();
    briefController = TextEditingController();
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

        // جلب الإحصائيات
        await fetchVendorStats(vendorId);
      }
    } catch (e) {
      debugPrint('fetchVendorData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب إحصائيات التاجر
  Future<void> fetchVendorStats(String vendorId) async {
    try {
      // جلب عدد المنتجات
      final stats = await repository.getVendorStats(vendorId);
      productsCount.value = stats['products_count'] ?? 0;
      followersCount.value = stats['followers_count'] ?? 0;
      offersCount.value = stats['offers_count'] ?? 0;

      debugPrint(
        'Vendor Stats: Products=$productsCount, Followers=$followersCount, Offers=$offersCount',
      );

      // التحقق من حالة المتابعة
      await checkFollowStatus(vendorId);
    } catch (e) {
      debugPrint('fetchVendorStats error: $e');
      productsCount.value = 0;
      followersCount.value = 0;
      offersCount.value = 0;
    }
  }

  /// التحقق من حالة المتابعة
  Future<void> checkFollowStatus(String vendorId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null && currentUser.userId.isNotEmpty) {
        isFollowing.value = await repository.isFollowingVendor(
          currentUser.userId,
          vendorId,
        );
        debugPrint('Follow status for vendor $vendorId: $isFollowing');
      }
    } catch (e) {
      debugPrint('checkFollowStatus error: $e');
      isFollowing.value = false;
    }
  }

  /// متابعة/إلغاء متابعة تاجر
  Future<void> toggleFollow(String vendorId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser == null || currentUser.userId.isEmpty) {
        Get.snackbar(
          'error'.tr,
          'please_login_first'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        return;
      }

      isFollowLoading.value = true;

      if (isFollowing.value) {
        // إلغاء المتابعة
        final success = await repository.unfollowVendor(
          currentUser.userId,
          vendorId,
        );

        if (success) {
          isFollowing.value = false;
          followersCount.value--;

          Get.snackbar(
            'success'.tr,
            'unfollowed_successfully'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey.shade100,
            colorText: Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        // متابعة
        final success = await repository.followVendor(
          currentUser.userId,
          vendorId,
        );

        if (success) {
          isFollowing.value = true;
          followersCount.value++;

          Get.snackbar(
            'success'.tr,
            'followed_successfully'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      debugPrint('toggleFollow error: $e');
      Get.snackbar(
        'error'.tr,
        'operation_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isFollowLoading.value = false;
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
    organizationbrief.value = profile.brief;
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
      briefController.text = profile.brief; // Use bio as brief for now
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
      briefController = TextEditingController(text: profile.organizationBio);
    }

    // Debug: Print social links info
    debugPrint("Social links initialized: ${profile.socialLink?.toJson()}");
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
      briefController.dispose();
    } catch (e) {
      debugPrint("Error disposing text controllers: $e");
    }
    super.onClose();
  }

  Future<void> saveVendorUpdates(String vendorId) async {
    isUpdate.value = true;
    try {
      // Ensure both profileData and vendorData have the same social links
      final currentSocialLink =
          profileData.value.socialLink ?? vendorData.value.socialLink;

      // إنشاء نسخة محدثة من بيانات المتجر مع القيم المعدلة
      final updatedVendor = profileData.value.copyWith(
        enableCod: enableCOD.value,
        enableIwintoPayment: enableIwintoPayment.value,
        // NOTE: website is NOT included - it's saved in social_links table
        organizationBio: organizationBioController.text.trim(),
        organizationName: organizationNameController.text.trim(),
        storeMessage: storeMessageController.text.trim(),
        organizationDeleted: organizationDeleted.value,
        organizationActivated: organizationActivated.value,
        socialLink: currentSocialLink, // الحفاظ على روابط السوشال
      );

      // Debug: Print the updated vendor
      debugPrint(
        "Updated vendor organizationBio: ${updatedVendor.organizationBio}",
      );
      debugPrint("Updated vendor toJson: ${updatedVendor.toJson()}");

      await repository.updateVendorProfile(vendorId, updatedVendor);

      // Update social links if they exist - this is the critical part
      if (currentSocialLink != null) {
        debugPrint("📤 Saving social links to database...");
        debugPrint("Social link data: ${currentSocialLink.toJson()}");

        await repository.updateVendorSocialLinks(vendorId, currentSocialLink);

        debugPrint("✅ Social links saved successfully!");
      } else {
        debugPrint("⚠️ No social links to save");
      }

      await fetchVendorData(vendorId);
    } catch (e) {
      debugPrint("❌ saveVendorUpdates error: $e");
      rethrow;
    } finally {
      isUpdate.value = false;
    }
  }

  // حفظ روابط السوشال ميديا
  Future<void> saveSocialLinks(String vendorId, SocialLink socialLink) async {
    try {
      isUpdate.value = true;

      // حفظ روابط السوشال ميديا مباشرة
      await repository.updateVendorSocialLinks(vendorId, socialLink);

      // تحديث البيانات المحلية
      profileData.value = profileData.value.copyWith(socialLink: socialLink);
      vendorData.value = vendorData.value.copyWith(socialLink: socialLink);

      debugPrint("Social links saved successfully");
    } catch (e) {
      debugPrint("Error saving social links: $e");
      rethrow;
    } finally {
      isUpdate.value = false;
    }
  }

  // الحصول على روابط السوشال ميديا
  SocialLink getSocialLinks() {
    return profileData.value.socialLink ?? const SocialLink();
  }

  // تحديث رابط سوشال واحد
  void updateSocialLink(String platform, String value) {
    final currentSocialLink = getSocialLinks();
    SocialLink updatedSocialLink;

    switch (platform) {
      case 'facebook':
        updatedSocialLink = currentSocialLink.copyWith(facebook: value);
        break;
      case 'instagram':
        updatedSocialLink = currentSocialLink.copyWith(instagram: value);
        break;
      case 'whatsapp':
        updatedSocialLink = currentSocialLink.copyWith(whatsapp: value);
        break;
      case 'website':
        updatedSocialLink = currentSocialLink.copyWith(website: value);
        break;
      case 'tiktok':
        updatedSocialLink = currentSocialLink.copyWith(tiktok: value);
        break;
      case 'youtube':
        updatedSocialLink = currentSocialLink.copyWith(youtube: value);
        break;
      case 'x':
        updatedSocialLink = currentSocialLink.copyWith(x: value);
        break;
      case 'linkedin':
        updatedSocialLink = currentSocialLink.copyWith(linkedin: value);
        break;
      case 'location':
        updatedSocialLink = currentSocialLink.copyWith(location: value);
        break;
      default:
        return;
    }

    // تحديث البيانات المحلية
    profileData.value = profileData.value.copyWith(
      socialLink: updatedSocialLink,
    );
    vendorData.value = vendorData.value.copyWith(socialLink: updatedSocialLink);
  }

  // تحديث حالة إظهار رابط سوشال
  void updateSocialLinkVisibility(String platform, bool visible) {
    final currentSocialLink = getSocialLinks();
    SocialLink updatedSocialLink;

    switch (platform) {
      case 'facebook':
        updatedSocialLink = currentSocialLink.copyWith(
          visibleFacebook: visible,
        );
        break;
      case 'instagram':
        updatedSocialLink = currentSocialLink.copyWith(
          visibleInstagram: visible,
        );
        break;
      case 'whatsapp':
        updatedSocialLink = currentSocialLink.copyWith(
          visibleWhatsapp: visible,
        );
        break;
      case 'website':
        updatedSocialLink = currentSocialLink.copyWith(visibleWebsite: visible);
        break;
      case 'tiktok':
        updatedSocialLink = currentSocialLink.copyWith(visibleTiktok: visible);
        break;
      case 'youtube':
        updatedSocialLink = currentSocialLink.copyWith(visibleYoutube: visible);
        break;
      case 'x':
        updatedSocialLink = currentSocialLink.copyWith(visibleX: visible);
        break;
      case 'linkedin':
        updatedSocialLink = currentSocialLink.copyWith(
          visibleLinkedin: visible,
        );
        break;
      case 'phones':
        updatedSocialLink = currentSocialLink.copyWith(visiblePhones: visible);
        break;
      default:
        return;
    }

    // تحديث البيانات المحلية
    profileData.value = profileData.value.copyWith(
      socialLink: updatedSocialLink,
    );
    vendorData.value = vendorData.value.copyWith(socialLink: updatedSocialLink);
  }

  // تحديث قائمة الهواتف
  void updatePhones(List<String> phones) {
    final currentSocialLink = getSocialLinks();
    final updatedSocialLink = currentSocialLink.copyWith(phones: phones);

    // تحديث البيانات المحلية
    profileData.value = profileData.value.copyWith(
      socialLink: updatedSocialLink,
    );
    vendorData.value = vendorData.value.copyWith(socialLink: updatedSocialLink);
  }

  // Location methods can be added here when needed
  // They require additional imports for map functionality
}
