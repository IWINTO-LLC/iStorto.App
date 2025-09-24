import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/policy_repository.dart';

class PolicyController extends GetxController {
  final PolicyRepository _policyRepository = PolicyRepository();

  // Controllers for text fields
  final aboutUsTx = TextEditingController();
  final termsTx = TextEditingController();
  final privacyTx = TextEditingController();
  final returnPolicyTx = TextEditingController();
  final certificateTx = TextEditingController();
  final licenseTx = TextEditingController();

  final aboutUsLinkTx = TextEditingController();
  final termsLinkTx = TextEditingController();
  final privacyLinkTx = TextEditingController();
  final returnPolicyLinkTx = TextEditingController();
  final certificateLinkTx = TextEditingController();
  final licenseLinkTx = TextEditingController();

  // New policy form controllers
  final newPolicyTitleTx = TextEditingController();
  final newPolicyContentTx = TextEditingController();
  final newPolicyLinkTx = TextEditingController();

  // Reactive variables
  final aboutUs = ''.obs;
  final terms = ''.obs;
  final privacy = ''.obs;
  final returnPolicy = ''.obs;
  final certificate = ''.obs;
  final license = ''.obs;

  final aboutUsLink = ''.obs;
  final termsLink = ''.obs;
  final privacyLink = ''.obs;
  final returnPolicyLink = ''.obs;
  final certificateLink = ''.obs;
  final licenseLink = ''.obs;

  final newPolicyTitle = ''.obs;
  final newPolicyContent = ''.obs;
  final newPolicyLink = ''.obs;

  // Custom policies
  final customPolicies = <Map<String, dynamic>>[].obs;
  final customPoliciesExpanded = <String, bool>{}.obs;

  // Images and PDFs
  final certificateImages = <String>[].obs;
  final certificatePDF = ''.obs;
  final licenseImages = <String>[].obs;
  final licensePDF = ''.obs;

  // Upload states
  final uploadingImages = <String, bool>{}.obs;
  final uploadedImages = <String, String>{}.obs;

  // UI states
  final showAddPolicyForm = false.obs;
  final isLoading = false.obs;

  // Accordion states
  final accordionStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAccordionStates();
  }

  @override
  void onClose() {
    // Dispose text controllers
    aboutUsTx.dispose();
    termsTx.dispose();
    privacyTx.dispose();
    returnPolicyTx.dispose();
    certificateTx.dispose();
    licenseTx.dispose();
    aboutUsLinkTx.dispose();
    termsLinkTx.dispose();
    privacyLinkTx.dispose();
    returnPolicyLinkTx.dispose();
    certificateLinkTx.dispose();
    licenseLinkTx.dispose();
    newPolicyTitleTx.dispose();
    newPolicyContentTx.dispose();
    newPolicyLinkTx.dispose();
    super.onClose();
  }

  void _initializeAccordionStates() {
    final fields = [
      'aboutUs',
      'terms',
      'privacy',
      'returnPolicy',
      'certificate',
      'license',
    ];
    for (var field in fields) {
      accordionStates[field] = false;
    }
  }

  // Accordion methods
  void toggleAccordion(String fieldKey) {
    accordionStates[fieldKey] = !(accordionStates[fieldKey] ?? false);
  }

  bool getAccordionState(String fieldKey) {
    return accordionStates[fieldKey] ?? false;
  }

  // Custom policy methods
  void toggleAddPolicyForm() {
    showAddPolicyForm.value = !showAddPolicyForm.value;
  }

  void addCustomPolicy() {
    if (newPolicyTitle.value.isEmpty) return;

    final policyData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': newPolicyTitle.value,
      'content': newPolicyContent.value,
      'link': newPolicyLink.value,
      'created_at': DateTime.now().toIso8601String(),
    };

    customPolicies.add(policyData);
    customPoliciesExpanded[policyData['id'] as String] = false;

    // Clear form
    newPolicyTitleTx.clear();
    newPolicyContentTx.clear();
    newPolicyLinkTx.clear();
    newPolicyTitle.value = '';
    newPolicyContent.value = '';
    newPolicyLink.value = '';

    // Close form
    showAddPolicyForm.value = false;
  }

  void deleteCustomPolicy(String policyId) {
    customPolicies.removeWhere((policy) => policy['id'] == policyId);
    customPoliciesExpanded.remove(policyId);
  }

  // Image methods
  Future<void> pickImages(RxList<String> imagesList) async {
    try {
      // TODO: Implement image picker
      // This is a placeholder implementation
      // You would typically use image_picker package here
      print('Image picker not implemented yet');
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void removeImage(RxList<String> imagesList, int index) {
    if (index >= 0 && index < imagesList.length) {
      imagesList.removeAt(index);
    }
  }

  // Save policy to Supabase
  Future<void> savePolicy(String vendorId) async {
    try {
      isLoading.value = true;

      final policyData = {
        'vendor_id': vendorId,
        'about_us': aboutUs.value,
        'terms': terms.value,
        'privacy': privacy.value,
        'return_policy': returnPolicy.value,
        'certificate': certificate.value,
        'license': license.value,
        'about_us_link': aboutUsLink.value,
        'terms_link': termsLink.value,
        'privacy_link': privacyLink.value,
        'return_policy_link': returnPolicyLink.value,
        'certificate_link': certificateLink.value,
        'license_link': licenseLink.value,
        'custom_policies': customPolicies.toList(),
        'certificate_images': certificateImages.toList(),
        'certificate_pdf': certificatePDF.value,
        'license_images': licenseImages.toList(),
        'license_pdf': licensePDF.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Check if policy exists
      final exists = await _policyRepository.policyExists(vendorId);

      if (exists) {
        await _policyRepository.updatePolicy(vendorId, policyData);
      } else {
        policyData['created_at'] = DateTime.now().toIso8601String();
        await _policyRepository.createPolicy(policyData);
      }

      Get.snackbar(
        'نجح',
        'تم حفظ السياسات بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      print('Error saving policy: $e');
      Get.snackbar(
        'خطأ',
        'فشل في حفظ السياسات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load policy from Supabase
  Future<void> loadPolicy(String vendorId) async {
    try {
      isLoading.value = true;

      final policyData = await _policyRepository.getPolicyByVendorId(vendorId);
      if (policyData != null) {
        loadPolicyData(policyData);
      }
    } catch (e) {
      print('Error loading policy: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get policy data for display
  Future<Map<String, dynamic>?> getPolicyData(String vendorId) async {
    try {
      return await _policyRepository.getPolicyByVendorId(vendorId);
    } catch (e) {
      print('Error getting policy data: $e');
      return null;
    }
  }

  void loadPolicyData(Map<String, dynamic> data) {
    // Load basic fields
    aboutUsTx.text = data['about_us'] ?? '';
    termsTx.text = data['terms'] ?? '';
    privacyTx.text = data['privacy'] ?? '';
    returnPolicyTx.text = data['return_policy'] ?? '';
    certificateTx.text = data['certificate'] ?? '';
    licenseTx.text = data['license'] ?? '';

    aboutUsLinkTx.text = data['about_us_link'] ?? '';
    termsLinkTx.text = data['terms_link'] ?? '';
    privacyLinkTx.text = data['privacy_link'] ?? '';
    returnPolicyLinkTx.text = data['return_policy_link'] ?? '';
    certificateLinkTx.text = data['certificate_link'] ?? '';
    licenseLinkTx.text = data['license_link'] ?? '';

    // Update reactive variables
    aboutUs.value = data['about_us'] ?? '';
    terms.value = data['terms'] ?? '';
    privacy.value = data['privacy'] ?? '';
    returnPolicy.value = data['return_policy'] ?? '';
    certificate.value = data['certificate'] ?? '';
    license.value = data['license'] ?? '';

    aboutUsLink.value = data['about_us_link'] ?? '';
    termsLink.value = data['terms_link'] ?? '';
    privacyLink.value = data['privacy_link'] ?? '';
    returnPolicyLink.value = data['return_policy_link'] ?? '';
    certificateLink.value = data['certificate_link'] ?? '';
    licenseLink.value = data['license_link'] ?? '';

    // Load custom policies
    if (data['custom_policies'] != null) {
      customPolicies.value = List<Map<String, dynamic>>.from(
        data['custom_policies'],
      );
      for (var policy in customPolicies) {
        final policyId = policy['id']?.toString();
        if (policyId != null && policyId.isNotEmpty) {
          customPoliciesExpanded[policyId] = false;
        }
      }
    }

    // Load images and PDFs
    if (data['certificate_images'] != null) {
      certificateImages.value = List<String>.from(data['certificate_images']);
    }
    certificatePDF.value = data['certificate_pdf'] ?? '';

    if (data['license_images'] != null) {
      licenseImages.value = List<String>.from(data['license_images']);
    }
    licensePDF.value = data['license_pdf'] ?? '';
  }

  // Clear all data
  void clearAllData() {
    aboutUsTx.clear();
    termsTx.clear();
    privacyTx.clear();
    returnPolicyTx.clear();
    certificateTx.clear();
    licenseTx.clear();
    aboutUsLinkTx.clear();
    termsLinkTx.clear();
    privacyLinkTx.clear();
    returnPolicyLinkTx.clear();
    certificateLinkTx.clear();
    licenseLinkTx.clear();

    aboutUs.value = '';
    terms.value = '';
    privacy.value = '';
    returnPolicy.value = '';
    certificate.value = '';
    license.value = '';
    aboutUsLink.value = '';
    termsLink.value = '';
    privacyLink.value = '';
    returnPolicyLink.value = '';
    certificateLink.value = '';
    licenseLink.value = '';

    customPolicies.clear();
    customPoliciesExpanded.clear();
    certificateImages.clear();
    certificatePDF.value = '';
    licenseImages.clear();
    licensePDF.value = '';
  }
}
