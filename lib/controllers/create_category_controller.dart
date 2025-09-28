import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/data/models/upload_result.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/upload.dart';
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
    message.value = "uploading img";
    if (localImage.value == "") return;
    File img = File(localImage.value);
    if (kDebugMode) {
      print("================= befor ==upload category=======");
      print(img.path);
    }
    // Resolve UploadResult name conflict by using a prefix or hiding one import.
    // Assuming we use 'upload' as a prefix for 'package:istoreto/utils/upload.dart'
    UploadResult uploadResult = await UploadService.instance
        .uploadMediaToServer(img);
    var s = uploadResult.fileUrl;
    imageUrl.value = "$mediaPath$s";
    if (kDebugMode) {
      print("uploading url===${imageUrl.value}");
      message.value = "uploading url====${imageUrl.value} ";
    }
    return;
  }

  RxList<CategoryModel> tempItems = <CategoryModel>[].obs;
  Future<void> createCategory() async {
    message.value = "uploading_photo".tr;
    await uploadImage();
    final newCat = CategoryModel(
      title: name.text.trim(),
      icon: imageUrl.value,

      createdAt: DateTime.now(),

      isActive: true,
    );

    message.value = "sending_data".tr;
    try {
      categoryRepository.addCategory(newCat);
      message.value = "everything_done".tr;
      CategoryController.instance.addItemToLists(newCat);
      tempItems.add(newCat);
      resetFields();
      message.value = "";
    } catch (e) {
      throw 'some thing go wrong while add category';
    }
  }

  void deleteTempItems() => tempItems = <CategoryModel>[].obs;
  void resetFields() {
    selectedParent(CategoryModel.empty());
    isLoading(false);
    isFeatured(false);
    name.clear();
    localImage.value = "";
    imageUrl.value = "";
  }
}
