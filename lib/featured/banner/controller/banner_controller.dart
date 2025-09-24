import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/upload.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/banner/data/banner_repository.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class BannerController extends GetxController {
  static BannerController get instance => Get.find();
  final carousalCurrentIndex = 0.obs;
  final isLoading = false.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<BannerModel> activeBanners = <BannerModel>[].obs;
  final bannersRepo = Get.put(BannerRepository());
  RxString localBannerImageFile = ''.obs;
  String bannerImageHostUrl = '';
  RxString message = ''.obs;
  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  RxBool isloadUserBanner = false.obs;
  String? lastFetchedUserId;

  void fetchUserBanners(String vendorId) async {
    isloadUserBanner.value = true;

    if (lastFetchedUserId == vendorId && banners.isNotEmpty) {
      print("📌 البيانات مخزنة بالفعل، لا حاجة لإعادة الجلب!");
      isloadUserBanner(false);
      return;
    }

    if (lastFetchedUserId != vendorId) {
      banners.clear();
      activeBanners.clear();
    }
    var snapshot = await bannersRepo.getVendorBannersById(vendorId);
    isloadUserBanner.value = false;
    lastFetchedUserId = vendorId;
    banners.value = snapshot;

    activeBanners.assignAll(banners.where((p0) => p0.active == true));
  }

  addBannersModel(BuildContext context, String vendorId) {
    showModalBottomSheet(
      context: context,
      //backgroundColor: Colors.transparent,
      // isScrollControlled: true,
      //   showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          width: 100.w,
          height: 20.h,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(83.0),
            child: Row(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () => addBanner('camera', vendorId),
                  child: const Center(
                    child: Icon(CupertinoIcons.photo_camera, size: 50),
                  ),
                ),
                GestureDetector(
                  onTap: () => addBanner('gallery', vendorId),
                  child: Center(
                    child: TRoundedContainer(
                      width: 60,
                      height: 60,
                      backgroundColor: TColors.grey,
                      showBorder: true,
                      radius: BorderRadius.circular(50),
                      child: const Center(
                        child: Icon(CupertinoIcons.photo_fill, size: 30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  var loading = false.obs;

  void fetchBanners(String vendorId) async {
    loading.value = true;
    var snapshot = await bannersRepo.getVendorBannersById(vendorId);
    banners.value = snapshot;
    activeBanners.assignAll(banners.where((p0) => p0.active == true));
    loading.value = false;
  }

  Future<void> deleteBanner(BannerModel item, String vendorId) async {
    try {
      LoadingFullscreen.startLoading();
      await bannersRepo.deleteBanner(item.id ?? '');
      banners.remove(item);
      activeBanners.remove(item);
      TLoader.successSnackBar(
        title: 'banner.banner_deleted_successfully'.tr,
        message: '',
      );
    } catch (e) {
      TLoader.erroreSnackBar(message: 'banner.failed_to_delete_banner'.tr);
    } finally {
      LoadingFullscreen.stopLoading();
    }
  }

  Future<void> updateStatus(BannerModel item, String vendorId) async {
    showSimpleLoadingDialog<String>(
      context: Get.context!,
      future: () async {
        message.value = "banner.update_status".tr;
        await bannersRepo.updateBanner(item);
        fetchBanners(vendorId);
        message.value = "";
        return "done";
      },
      // Custom dialog
      dialogBuilder: (context, _) {
        return AlertDialog(
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message.value),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addBanner(String mode, String vendorId) async {
    var pickedFile = (await ImagePicker().pickImage(
      source: mode == 'gallery' ? ImageSource.gallery : ImageSource.camera,
    ));

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: const CropAspectRatio(ratioX: 364, ratioY: 214),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'banner.image'.tr,
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio:
                CropAspectRatioPreset.original, // Ensures a 1:1 crop
            lockAspectRatio: true, // Prevents resizing
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'banner.image'.tr,

            aspectRatioLockEnabled: true, // Locks aspect ratio
          ),
        ],
      );
      File img = File(croppedFile!.path);

      localBannerImageFile.value = img.path;

      await showSimpleLoadingDialog<String>(
        context: Get.context!,
        future: () async {
          message.value = "banner.upload_image_to_server".tr;
          var uploadResult = await UploadService.instance.uploadMediaToServer(
            img,
          );
          var s = uploadResult.fileUrl;
          bannerImageHostUrl = "$mediaPath$s";
          message.value = "banner.send_data".tr;
          var newBanner = BannerModel(
            id: '',
            image: bannerImageHostUrl,
            targetScreen: '',
            active: true,
            vendorId: vendorId,
            scope: BannerScope.vendor,
          );
          final createdBanner = await bannersRepo.createBanner(newBanner);
          banners.add(createdBanner);
          activeBanners.add(createdBanner);
          TLoader.successSnackBar(
            title: 'banner.banner_added_successfully'.tr,
            message: '',
          );
          message.value = '';

          return "add done";
        },
        // Custom dialog
        dialogBuilder: (context, _) {
          return AlertDialog(
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message.value),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
