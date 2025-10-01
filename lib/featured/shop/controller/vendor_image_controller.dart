import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'dart:io';

class VendorImageController extends GetxController {
  static VendorImageController get instance => Get.find();

  final ImagePicker _imagePicker = ImagePicker();
  final RxBool _isLoading = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;

  // Edit Vendor Cover Image
  Future<void> editVendorCoverImage(String vendorId) async {
    try {
      // Show image source dialog
      showImageSourceDialog(
        title: 'تعديل صورة الغلاف',
        onCamera: () => _pickFromCamera(vendorId, isCover: true),
        onGallery: () => _pickFromGallery(vendorId, isCover: true),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تعديل صورة الغلاف: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Edit Vendor Logo Image
  Future<void> editVendorLogoImage(String vendorId) async {
    try {
      // Show image source dialog
      showImageSourceDialog(
        title: 'تعديل شعار المتجر',
        onCamera: () => _pickFromCamera(vendorId, isCover: false),
        onGallery: () => _pickFromGallery(vendorId, isCover: false),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تعديل شعار المتجر: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Pick from Camera
  Future<void> _pickFromCamera(String vendorId, {required bool isCover}) async {
    try {
      _isLoading.value = true;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _processImage(File(pickedFile.path), vendorId, isCover: isCover);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في التقاط الصورة: ${e.toString()}',
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
  Future<void> _pickFromGallery(
    String vendorId, {
    required bool isCover,
  }) async {
    try {
      _isLoading.value = true;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _processImage(File(pickedFile.path), vendorId, isCover: isCover);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الصورة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Process Image (Crop and Upload)
  Future<void> _processImage(
    File imageFile,
    String vendorId, {
    required bool isCover,
  }) async {
    try {
      // Crop image
      final croppedFile = await _cropImage(imageFile, isCover: isCover);

      if (croppedFile != null) {
        // Upload to storage
        await _uploadImageToStorage(
          File(croppedFile.path),
          vendorId,
          isCover: isCover,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في معالجة الصورة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Crop Image Helper
  Future<CroppedFile?> _cropImage(
    File imageFile, {
    required bool isCover,
  }) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio:
          isCover
              ? CropAspectRatio(ratioX: 16, ratioY: 9) // Cover image ratio
              : CropAspectRatio(
                ratioX: 1,
                ratioY: 1,
              ), // Logo image ratio (square)
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isCover ? 'قص صورة الغلاف' : 'قص شعار المتجر',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio:
              isCover
                  ? CropAspectRatioPreset.ratio16x9
                  : CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropGridColor: Colors.blue,
          cropGridStrokeWidth: 2,
          hideBottomControls: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: isCover ? 'قص صورة الغلاف' : 'قص شعار المتجر',
          doneButtonTitle: 'تم',
          cancelButtonTitle: 'إلغاء',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          minimumAspectRatio: isCover ? 1.0 : 1.0,
        ),
      ],
    );
  }

  // Upload Image to Storage
  Future<void> _uploadImageToStorage(
    File imageFile,
    String vendorId, {
    required bool isCover,
  }) async {
    try {
      _isLoading.value = true;

      // Upload image to Supabase Storage
      final supabaseService = SupabaseService();
      final imageBytes = await imageFile.readAsBytes();

      final fileName =
          isCover
              ? 'vendor_covers/cover_${vendorId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
              : 'vendor_logos/logo_${vendorId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final uploadResult = await supabaseService.uploadImageToStorage(
        imageBytes,
        fileName,
      );

      final imageUrl = uploadResult['url'] as String? ?? '';

      if (imageUrl.isNotEmpty) {
        // Update vendor data in database
        await _updateVendorImageInDatabase(
          vendorId,
          imageUrl,
          isCover: isCover,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في رفع الصورة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Update Vendor Image in Database
  Future<void> _updateVendorImageInDatabase(
    String vendorId,
    String imageUrl, {
    required bool isCover,
  }) async {
    try {
      final fieldName = isCover ? 'organization_cover' : 'organization_logo';

      // Update vendor data in Supabase
      await SupabaseService.client
          .from('vendors')
          .update({fieldName: imageUrl})
          .eq('user_id', vendorId);

      // Add small delay to show shimmer effect
      await Future.delayed(Duration(milliseconds: 500));

      // Refresh vendor data in controller
      final vendorController = Get.find<VendorController>();
      await vendorController.fetchVendorData(vendorId);

      // Ensure loading is stopped
      _isLoading.value = false;

      Get.snackbar(
        'نجح',
        isCover ? 'تم تحديث صورة الغلاف بنجاح!' : 'تم تحديث شعار المتجر بنجاح!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar(
        'خطأ',
        'فشل في تحديث البيانات: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
    }
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
              title: Text('الكاميرا'),
              onTap: () {
                Get.back();
                onCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
              title: Text('المعرض'),
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
}
