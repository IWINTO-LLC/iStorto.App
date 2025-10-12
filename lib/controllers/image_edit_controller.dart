import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'dart:io';

class ImageEditController extends GetxController {
  static ImageEditController get instance => Get.find();

  final ImagePicker _imagePicker = ImagePicker();
  final Rx<File?> _profileImage = Rx<File?>(null);
  final Rx<File?> _coverImage = Rx<File?>(null);

  // متغيرات منفصلة للتحميل والتقدم
  final RxBool _isLoadingProfile = false.obs;
  final RxBool _isLoadingCover = false.obs;
  final RxDouble _profileUploadProgress = 0.0.obs;
  final RxDouble _coverUploadProgress = 0.0.obs;

  // Getters
  File? get profileImage => _profileImage.value;
  File? get coverImage => _coverImage.value;
  bool get isLoadingProfile => _isLoadingProfile.value;
  bool get isLoadingCover => _isLoadingCover.value;
  double get profileUploadProgress => _profileUploadProgress.value;
  double get coverUploadProgress => _coverUploadProgress.value;

  // للتوافق مع الكود القديم
  @Deprecated('Use isLoadingProfile or isLoadingCover')
  bool get isLoading => _isLoadingProfile.value || _isLoadingCover.value;

  // Crop Image Helper
  Future<CroppedFile?> _cropImage(
    File imageFile, {
    CropStyle? cropStyle,
    CropAspectRatio? aspectRatio,
  }) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle:
              cropStyle == CropStyle.circle
                  ? 'Crop Profile Image'
                  : 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio:
              cropStyle == CropStyle.circle
                  ? CropAspectRatioPreset.square
                  : (aspectRatio != null
                      ? CropAspectRatioPreset.ratio4x3
                      : CropAspectRatioPreset.original),
          lockAspectRatio: cropStyle == CropStyle.circle || aspectRatio != null,
          cropGridColor:
              cropStyle == CropStyle.circle ? Colors.blue : Colors.grey,
          cropGridStrokeWidth: cropStyle == CropStyle.circle ? 3 : 2,
          hideBottomControls: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title:
              cropStyle == CropStyle.circle
                  ? 'Crop Profile Image'
                  : 'Crop Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled:
              cropStyle == CropStyle.circle || aspectRatio != null,
          resetAspectRatioEnabled: false,
          minimumAspectRatio: cropStyle == CropStyle.circle ? 1.0 : 0.5,
        ),
      ],
    );
  }

  // Show Image Source Dialog
  void showImageSourceDialog({
    required String title,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                onCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                onGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Pick from Camera
  Future<void> pickFromCamera({required bool isProfile}) async {
    try {
      // تم نقل loading logic إلى save methods

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final croppedFile = await _cropImage(
          File(pickedFile.path),
          cropStyle: isProfile ? CropStyle.circle : null,
          aspectRatio:
              isProfile
                  ? CropAspectRatio(ratioX: 1, ratioY: 1)
                  : CropAspectRatio(ratioX: 4, ratioY: 3),
        );

        if (croppedFile != null) {
          if (isProfile) {
            _profileImage.value = File(croppedFile.path);
          } else {
            _coverImage.value = File(croppedFile.path);
          }

          Get.snackbar(
            'Success',
            '${isProfile ? 'Profile' : 'Cover'} image updated successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      // Loading handled in save methods
    }
  }

  // Pick from Gallery
  Future<void> pickFromGallery({required bool isProfile}) async {
    try {
      // تم نقل loading logic إلى save methods

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final croppedFile = await _cropImage(
          File(pickedFile.path),
          cropStyle: isProfile ? CropStyle.circle : null,
          aspectRatio:
              isProfile
                  ? CropAspectRatio(ratioX: 1, ratioY: 1)
                  : CropAspectRatio(ratioX: 4, ratioY: 3),
        );

        if (croppedFile != null) {
          if (isProfile) {
            _profileImage.value = File(croppedFile.path);
          } else {
            _coverImage.value = File(croppedFile.path);
          }

          Get.snackbar(
            'Success',
            '${isProfile ? 'Profile' : 'Cover'} image updated successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      // Loading handled in save methods
    }
  }

  // Clear Images
  void clearProfileImage() {
    _profileImage.value = null;
  }

  void clearCoverImage() {
    _coverImage.value = null;
  }

  // Save profile image to database
  Future<void> saveProfileImageToDatabase(File imageFile) async {
    try {
      _isLoadingProfile.value = true;
      _profileUploadProgress.value = 0.1; // 10% - بدء العملية

      // Upload image to Supabase Storage
      _profileUploadProgress.value = 0.2; // 20% - تحضير الملف
      final supabaseService = SupabaseService();
      final imageBytes = await imageFile.readAsBytes();

      _profileUploadProgress.value = 0.3; // 30% - بدء الرفع
      final uploadResult = await supabaseService.uploadImageToStorage(
        imageBytes,
        'profile_images/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      _profileUploadProgress.value = 0.8; // 80% - اكتمل الرفع
      final imageUrl = uploadResult['url'] as String? ?? '';

      if (imageUrl.isNotEmpty) {
        _profileUploadProgress.value =
            0.9; // 90% - بدء التحديث في قاعدة البيانات

        // Update user profile with new image URL
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;

        if (currentUser != null) {
          // Update user profile with new image URL
          await SupabaseService.client
              .from('user_profiles')
              .update({'profile_image': imageUrl})
              .eq('user_id', currentUser.id);

          // Refresh user data
          await authController.updateProfileImage(imageUrl);

          _profileUploadProgress.value = 1.0; // 100% - اكتمل كل شيء

          Get.snackbar(
            'success'.tr,
            'profile_image_updated_successfully'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to save profile image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoadingProfile.value = false;
      _profileUploadProgress.value = 0.0;
    }
  }

  // Save cover image to database
  Future<void> saveCoverImageToDatabase(File imageFile) async {
    try {
      _isLoadingCover.value = true;
      _coverUploadProgress.value = 0.1; // 10% - بدء العملية

      // Upload image to Supabase Storage
      _coverUploadProgress.value = 0.2; // 20% - تحضير الملف
      final supabaseService = SupabaseService();
      final imageBytes = await imageFile.readAsBytes();

      _coverUploadProgress.value = 0.3; // 30% - بدء الرفع
      final uploadResult = await supabaseService.uploadImageToStorage(
        imageBytes,
        'cover_images/cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      _coverUploadProgress.value = 0.8; // 80% - اكتمل الرفع
      final imageUrl = uploadResult['url'] as String? ?? '';

      if (imageUrl.isNotEmpty) {
        _coverUploadProgress.value = 0.9; // 90% - بدء التحديث في قاعدة البيانات

        // Update user profile with new cover image URL
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;

        if (currentUser != null) {
          // Update cover image in user_profiles table
          await SupabaseService.client
              .from('user_profiles')
              .update({'cover': imageUrl})
              .eq('user_id', currentUser.id);

          // Update local user data
          authController.currentUser.value = currentUser.copyWith(
            cover: imageUrl,
          );

          // If user is a vendor, also update vendors table
          if (currentUser.accountType == 1 && currentUser.vendorId != null) {
            await SupabaseService.client
                .from('vendors')
                .update({'organization_cover': imageUrl})
                .eq('id', currentUser.vendorId!);

            // Refresh vendor data
            final vendorController = VendorController.instance;
            await vendorController.fetchVendorData(currentUser.vendorId!);
          }

          _coverUploadProgress.value = 1.0; // 100% - اكتمل كل شيء

          Get.snackbar(
            'success'.tr,
            'cover_image_updated_successfully'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to save cover image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoadingCover.value = false;
      _coverUploadProgress.value = 0.0;
    }
  }

  // Reset All
  void resetAll() {
    _profileImage.value = null;
    _coverImage.value = null;
    _isLoadingProfile.value = false;
    _isLoadingCover.value = false;
    _profileUploadProgress.value = 0.0;
    _coverUploadProgress.value = 0.0;
  }
}
