import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/services/image_upload_service.dart';
import 'package:uuid/uuid.dart';

import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CreateCategoryController extends GetxController {
  static CreateCategoryController get instance => Get.find();

  final isLoading = false.obs;
  final categoryRepository = CategoryRepository.instance;
  final selectedParent = CategoryModel.empty().obs;
  RxString imageUrl = ''.obs;
  RxString localImage = ''.obs;
  RxString message = ''.obs;
  final isFeatured = false.obs;
  final isUploading = false.obs;

  final name = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> pickImage() async {
    try {
      var pickedFile = (await ImagePicker().pickImage(
        source: ImageSource.gallery,
      ));

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatio: CropAspectRatio(ratioX: 600, ratioY: 600),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Edit Category Image',
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.black,
              initAspectRatio:
                  CropAspectRatioPreset.original, // Ensures a 1:1 crop
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Edit Category Image',
              cropStyle: CropStyle.circle,
              // Locks aspect ratio
            ),
          ],
        );

        if (croppedFile != null) {
          File img = File(croppedFile.path);
          localImage.value = img.path;
        } else {
          // User cancelled cropping, use original image
          localImage.value = pickedFile.path;
        }
      }
    } catch (e) {
      print('Error picking/cropping image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadImage() async {
    try {
      if (localImage.value.isEmpty) {
        throw 'لا توجد صورة محلية للرفع';
      }

      File img = File(localImage.value);

      if (!await img.exists()) {
        throw 'ملف الصورة غير موجود';
      }

      // استخدام ImageUploadService
      final result = await ImageUploadService.instance.uploadImage(
        imageFile: img,
        folderName: 'categories',
      );

      if (result['success'] == true) {
        imageUrl.value = result['url'] ?? '';
        if (kDebugMode) {
          print("Upload successful! URL: ${imageUrl.value}");
        }
      } else {
        throw Exception(result['error'] ?? 'Upload failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Upload error: $e");
      }
      imageUrl.value = '';
      rethrow; // إعادة رمي الخطأ للتعامل معه في createCategory
    }
  }

  RxList<CategoryModel> tempItems = <CategoryModel>[].obs;
  Future<void> createCategory(String vendorId) async {
    try {
      isUploading.value = true;

      // التحقق من صحة البيانات
      if (name.text.trim().isEmpty) {
        throw 'category_name_required'.tr;
      }

      if (localImage.value.isEmpty) {
        throw 'category_image_required'.tr;
      }

      // بدء عملية رفع الصورة
      message.value = "جاري رفع الصورة...";
      await uploadImage();

      // التحقق من نجاح رفع الصورة
      if (imageUrl.value.isEmpty) {
        throw 'فشل في رفع الصورة';
      }

      // إنشاء كائن الفئة الجديدة
      message.value = "جاري إعداد البيانات...";
      final newCat = CategoryModel(
        title: name.text.trim(),
        icon: imageUrl.value,
        vendorId: vendorId,
        createdAt: DateTime.now(),
        id: Uuid().v4(),
        isActive: true,
      );

      // إرسال البيانات إلى قاعدة البيانات
      message.value = "جاري إرسال البيانات...";
      final createdCategory = await categoryRepository.addCategory(newCat);

      // إضافة الفئة إلى القوائم المحلية
      message.value = "جاري تحديث القوائم...";
      CategoryController.instance.addItemToLists(createdCategory);
      tempItems.add(createdCategory);

      // إكمال العملية
      message.value = "تم إنشاء الفئة بنجاح!";
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // تأخير قصير لإظهار رسالة النجاح

      resetFields();
      message.value = "";
    } catch (e) {
      message.value = "حدث خطأ أثناء إنشاء الفئة: $e";
      isUploading.value = false;
      throw 'some thing go wrong while add category: $e';
    } finally {
      isUploading.value = false;
    }
  }

  void deleteTempItems() => tempItems = <CategoryModel>[].obs;
  void resetFields() {
    selectedParent(CategoryModel.empty());
    isLoading(false);
    isFeatured(false);
    isUploading(false);
    name.clear();
    localImage.value = "";
    imageUrl.value = "";
    message.value = "";
  }
}
