import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'dart:io';

class ImageEditController extends GetxController {
  static ImageEditController get instance => Get.find();

  final ImagePicker _imagePicker = ImagePicker();
  final Rx<File?> _profileImage = Rx<File?>(null);
  final Rx<File?> _coverImage = Rx<File?>(null);
  final RxBool _isLoading = false.obs;

  // Getters
  File? get profileImage => _profileImage.value;
  File? get coverImage => _coverImage.value;
  bool get isLoading => _isLoading.value;

  // Edit Profile Image
  Future<void> editProfileImage() async {
    try {
      _isLoading.value = true;

      // Pick image from gallery
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Crop image to circle (1:1 ratio for perfect circle)
        final croppedFile = await _cropImage(
          File(pickedFile.path),
          cropStyle: CropStyle.circle,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        );

        if (croppedFile != null) {
          _profileImage.value = File(croppedFile.path);
          // حفظ الصورة في قاعدة البيانات
          await saveProfileImageToDatabase(File(croppedFile.path));
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Edit Cover Image
  Future<void> editCoverImage() async {
    try {
      _isLoading.value = true;

      // Pick image from gallery
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Crop image to 4:3 ratio
        final croppedFile = await _cropImage(
          File(pickedFile.path),
          aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
        );

        if (croppedFile != null) {
          _coverImage.value = File(croppedFile.path);
          // حفظ الصورة في قاعدة البيانات
          await saveCoverImageToDatabase(File(croppedFile.path));
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update cover image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

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
          toolbarColor: Colors.blue,
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
      _isLoading.value = true;

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
      _isLoading.value = false;
    }
  }

  // Pick from Gallery
  Future<void> pickFromGallery({required bool isProfile}) async {
    try {
      _isLoading.value = true;

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
      _isLoading.value = false;
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
      _isLoading.value = true;

      // Upload image to Supabase Storage
      final supabaseService = SupabaseService();
      final imageBytes = await imageFile.readAsBytes();
      final uploadResult = await supabaseService.uploadImageToStorage(
        imageBytes,
        'profile_images/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final imageUrl = uploadResult['url'] as String? ?? '';

      if (imageUrl.isNotEmpty) {
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

          Get.snackbar(
            'Success',
            'Profile image updated successfully!',
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
        'Failed to save profile image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Save cover image to database
  Future<void> saveCoverImageToDatabase(File imageFile) async {
    try {
      _isLoading.value = true;

      // Upload image to Supabase Storage
      final supabaseService = SupabaseService();
      final imageBytes = await imageFile.readAsBytes();
      final uploadResult = await supabaseService.uploadImageToStorage(
        imageBytes,
        'cover_images/cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final imageUrl = uploadResult['url'] as String? ?? '';

      if (imageUrl.isNotEmpty) {
        // Update vendor profile with new cover image URL
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;

        if (currentUser != null && currentUser.accountType == 1) {
          // Update vendor cover image
          await SupabaseService.client
              .from('vendors')
              .update({'organization_cover': imageUrl})
              .eq('user_id', currentUser.id);

          Get.snackbar(
            'Success',
            'Cover image updated successfully!',
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
        'Failed to save cover image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset All
  void resetAll() {
    _profileImage.value = null;
    _coverImage.value = null;
    _isLoading.value = false;
  }
}
