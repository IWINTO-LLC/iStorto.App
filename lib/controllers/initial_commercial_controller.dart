import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/views/commercial_account_congratulations_page.dart';
import 'package:istoreto/data/models/major_category_model.dart';
import 'package:istoreto/data/repositories/major_category_repository.dart';
import 'package:uuid/uuid.dart';

class InitialCommercialController extends GetxController {
  // Form controllers
  final organizationNameController = TextEditingController();
  final slugnController = TextEditingController();
  final organizationBioController = TextEditingController();

  // Page controller
  final pageController = PageController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;
  final organizationLogo = <XFile>[].obs;
  final organizationCover = <XFile>[].obs;

  // Services
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  // Category selection
  RxList<MajorCategoryModel> availableCategories = <MajorCategoryModel>[].obs;
  RxList<String> selectedCategories = <String>[].obs;
  RxBool isLoadingCategories = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize any required data
    loadAvailableCategories();
  }

  @override
  void onClose() {
    // Dispose controllers
    organizationNameController.dispose();
    slugnController.dispose();
    organizationBioController.dispose();
    pageController.dispose();
    super.onClose();
  }

  // Navigation methods
  void nextStep() {
    if (currentStep.value == 0) {
      if (formKey.currentState!.validate()) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    currentStep.value = index;
  }

  // Image selection methods
  Future<void> selectLogoFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        organizationLogo.clear();
        organizationLogo.add(image);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectLogoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 for circle
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Edit Logo Image',
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Edit Logo Image',
              cropStyle: CropStyle.circle,
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: true,
            ),
          ],
        );

        if (croppedFile != null) {
          File img = File(croppedFile.path);
          organizationLogo.clear();
          organizationLogo.add(XFile(img.path));
        } else {
          // User cancelled cropping, use original image
          organizationLogo.clear();
          organizationLogo.add(image);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select logo: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectCoverFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (image != null) {
        organizationCover.clear();
        organizationCover.add(image);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectCoverFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3), // 4:3 for cover
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Edit Cover Image',
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.ratio4x3,
              lockAspectRatio: true,
              cropStyle: CropStyle.rectangle,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Edit Cover Image',
              cropStyle: CropStyle.rectangle,
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: true,
            ),
          ],
        );

        if (croppedFile != null) {
          File img = File(croppedFile.path);
          organizationCover.clear();
          organizationCover.add(XFile(img.path));
        } else {
          // User cancelled cropping, use original image
          organizationCover.clear();
          organizationCover.add(image);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select cover: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeLogo() {
    organizationLogo.clear();
  }

  void removeCover() {
    organizationCover.clear();
  }

  void showLogoSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('select_image'.tr + ' ${'logo'.tr}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                selectLogoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                selectLogoFromGallery();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        ],
      ),
    );
  }

  void showCoverSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('select_image'.tr + ' ${'cover'.tr}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                selectCoverFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                selectCoverFromGallery();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        ],
      ),
    );
  }

  // Validation methods
  String? validateOrganizationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'organization_name_required'.tr;
    }
    return null;
  }

  String? validateSlug(String? value) {
    if (value == null || value.isEmpty) {
      return 'organization_slug_required'.tr;
    }
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
      return 'slug_format_error'.tr;
    }
    return null;
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImageToStorage(XFile image, String folder) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final path = '$folder/$fileName';

      final result = await _supabaseService.uploadImageToStorage(bytes, path);

      if (result['success']) {
        return result['url'];
      } else {
        throw Exception(result['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Save commercial account
  Future<void> saveCommercialAccount() async {
    if (isLoading.value) return;

    isLoading.value = true;
    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Upload images first
      String? logoUrl;
      String? coverUrl;

      if (organizationLogo.isNotEmpty) {
        uploadProgress.value = 0.3;
        logoUrl = await uploadImageToStorage(
          organizationLogo.first,
          'vendor-logos',
        );
        uploadProgress.value = 0.6;
      }

      if (organizationCover.isNotEmpty) {
        uploadProgress.value = 0.7;
        coverUrl = await uploadImageToStorage(
          organizationCover.first,
          'vendor-covers',
        );
        uploadProgress.value = 0.9;
      }

      // Create vendor model with uploaded image URLs
      final vendorModel = VendorModel(
        id: Uuid().v4(),
        userId: currentUser.id,
        organizationName: organizationNameController.text.trim(),
        slugn: slugnController.text.trim(),
        organizationBio: organizationBioController.text.trim(),
        organizationLogo: logoUrl ?? '',
        organizationCover: coverUrl ?? '',
        organizationActivated: true,
        defaultCurrency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      final result = await _supabaseService.createVendor(vendorModel.toJson());

      if (result['success']) {
        // Update user profile account type
        await _supabaseService.updateUserAccountType(currentUser.id, 1);

        uploadProgress.value = 1.0;

        Get.snackbar(
          'Success',
          'Commercial account created successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Save selected major categories
        await _saveSelectedMajorCategories(vendorModel.id!);

        // Navigate to congratulations page
        Get.offAll(
          () => CommercialAccountCongratulationsPage(
            vendorId: vendorModel.id ?? '',
            organizationName: vendorModel.organizationName,
          ),
        );
      } else {
        throw Exception(
          result['message'] ?? 'Failed to create commercial account',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Getters for UI
  bool get canGoPrevious => currentStep.value > 0;
  String get nextButtonText =>
      currentStep.value == 2 ? 'create_commercial_account_btn'.tr : 'next'.tr;
  bool get isLastStep => currentStep.value == 2;

  // Review data getters
  String get organizationName => organizationNameController.text;
  String get slug => slugnController.text;
  String get organizationBio =>
      organizationBioController.text.isEmpty
          ? 'not_provided'.tr
          : organizationBioController.text;
  String get logoStatus =>
      organizationLogo.isEmpty ? 'not_selected'.tr : 'selected'.tr;
  String get coverStatus =>
      organizationCover.isEmpty ? 'not_selected'.tr : 'selected'.tr;

  // Category selection methods
  Future<void> loadAvailableCategories() async {
    try {
      isLoadingCategories.value = true;
      final categories = await MajorCategoryRepository.getAllCategories();
      availableCategories.value = categories;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void toggleCategorySelection(String categoryId) {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
    } else {
      selectedCategories.add(categoryId);
    }
  }

  bool isCategorySelected(String categoryId) {
    return selectedCategories.contains(categoryId);
  }

  String get selectedCategoriesText {
    if (selectedCategories.isEmpty) {
      return 'no_categories_selected'.tr;
    }
    return '${selectedCategories.length} ${'categories_selected'.tr}';
  }

  // Save selected major categories to vendor profile
  Future<void> _saveSelectedMajorCategories(String vendorId) async {
    try {
      if (selectedCategories.isEmpty) return;

      // Update vendor with selected major categories
      // We'll store the selected category IDs as a comma-separated string in a field
      final selectedCategoriesString = selectedCategories.join(',');

      await _supabaseService.updateVendorCategories(
        vendorId,
        selectedCategoriesString,
      );
    } catch (e) {
      print('Error saving selected categories: $e');
      // Don't throw error here to avoid breaking the flow
    }
  }
}
