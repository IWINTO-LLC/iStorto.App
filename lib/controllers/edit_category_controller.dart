import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/data/models/upload_result.dart';
import 'package:istoreto/featured/category/view/create_category/widget/image_uploader.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/upload.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';
import '../utils/loader/loaders.dart';

class EditCategoryController extends GetxController {
  static EditCategoryController get instance => Get.find();

  final isLoading = false.obs;
  final categoryRepository = CategoryRepository.instance;
  final selectedParent = CategoryModel.empty().obs;
  RxString imageUrl = ''.obs;
  RxString localImage = ''.obs;
  RxString message = ''.obs;
  final isFeatured = true.obs;
  final name = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String oldImg = "";
  void init(CategoryModel category) {
    name.text = category.title;
    oldImg = category.icon!;
    imageUrl.value = category.icon!;
  }

  Future<void> pickImage() async {
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
      File img = File(croppedFile!.path);

      localImage.value = img.path;
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

  Future<void> updateCategory(CategoryModel category) async {
    try {
      message.value = "uploading_photo".tr;
      // first upload category to server
      if (localImage.isNotEmpty) await uploadImage();

      message.value = "sending_data".tr;
      // second create category model
      final updatedCategory = category.copyWith(
        name: name.text.trim(),
        icon: imageUrl.value,
        isActive: isFeatured.value,
        updatedAt: DateTime.now(),
      );

      // third send category values
      await categoryRepository.updateCategory(updatedCategory);

      CategoryController.instance.updateItemFromLists(updatedCategory);
      resetFields();
      message.value = "";

      TLoader.successSnackBar(
        title: "success".tr,
        message: "everything_done".tr,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error updating category: $e");
      }
      TLoader.warningSnackBar(title: "error".tr, message: e.toString());
      message.value = "";
    }
  }

  Future<dynamic> updateCategoryImage(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder:
          (_) => SizedBox(
            height: 800,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: DottedBorder(
                      dashPattern: const [4, 5],
                      borderType: BorderType.RRect,
                      color: TColors.darkerGray,
                      radius: const Radius.circular(10),
                      child: Obx(
                        () => TImageUploader(
                          circuler: false,
                          imageType:
                              localImage.isNotEmpty
                                  ? ImageType.file
                                  : ImageType.asset,
                          width: 80,
                          height: 80,
                          image:
                              localImage.isNotEmpty
                                  ? localImage.value
                                  : TImages.imagePlaceholder,
                          onIconButtonPressed: () => pickImage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void resetFields() {
    selectedParent(CategoryModel.empty());
    isLoading(false);
    isFeatured(false);
    name.clear();
    imageUrl.value = "";
  }

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      LoadingFullscreen.startLoading();

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId == null || userId.isEmpty) {
        throw 'Unable to find user information. try again later';
      }

      await categoryRepository.deleteCategory(category.id!);
      CategoryController.instance.removeItemFromLists(category);

      TLoader.successSnackBar(
        title: "success".tr,
        message: "category_deleted_successfully".tr,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting category: $e");
      }
      TLoader.warningSnackBar(title: "error".tr, message: e.toString());
    } finally {
      LoadingFullscreen.stopLoading();
    }
  }
}
