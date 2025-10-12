import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/services/image_upload_service.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/banner/data/banner_repository.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/loader/loaders.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerController extends GetxController {
  static BannerController get instance => Get.find();
  final carousalCurrentIndex = 0.obs;
  final isLoading = false.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<BannerModel> activeBanners = <BannerModel>[].obs;
  final bannersRepo = Get.put(BannerRepository());
  final imageUploadService = Get.find<ImageUploadService>();
  RxString localBannerImageFile = ''.obs;
  String bannerImageHostUrl = '';
  RxString message = ''.obs;
  RxDouble uploadProgress = 0.0.obs;
  RxBool isUploading = false.obs;
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

    // استخدام الدالة الجديدة لجلب جميع بانرات التاجر بغض النظر عن scope
    var snapshot = await bannersRepo.getAllVendorBannersByVendorId(vendorId);
    isloadUserBanner.value = false;
    lastFetchedUserId = vendorId;
    banners.value = snapshot;

    activeBanners.assignAll(banners.where((p0) => p0.active == true));
  }

  // Fetch all banners (for admin)
  Future<void> fetchAllBanners() async {
    try {
      isLoading.value = true;
      final snapshot = await bannersRepo.getAllBanners();
      print(
        "=======Banners Data snapshot ==========${snapshot.toString()}====",
      );
      banners.value = snapshot;
      activeBanners.assignAll(banners.where((p0) => p0.active == true));
    } catch (e) {
      TLoader.erroreSnackBar(message: 'failed_to_load_banners'.tr);
      print("Error fetching all banners: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle banner active status
  Future<void> toggleBannerActive(String bannerId, bool isActive) async {
    try {
      await bannersRepo.toggleBannerActive(bannerId, isActive);
    } catch (e) {
      throw 'Failed to toggle banner status: $e';
    }
  }

  // Convert vendor banner to company banner
  Future<void> convertToCompanyBanner(BannerModel banner) async {
    try {
      await bannersRepo.convertToCompanyBanner(banner);
      await fetchAllBanners(); // Refresh banners list
    } catch (e) {
      throw 'Failed to convert banner: $e';
    }
  }

  // Delete banner (admin)
  Future<void> deleteBannerAdmin(BannerModel banner) async {
    try {
      await bannersRepo.deleteBannerAdmin(banner);
      await fetchAllBanners(); // Refresh banners list
    } catch (e) {
      throw 'Failed to delete banner: $e';
    }
  }

  // Update banner
  Future<void> updateBanner(
    String bannerId, {
    String? title,
    String? description,
    String? targetScreen,
    int? priority,
    bool? active,
    BannerScope? scope,
  }) async {
    try {
      await bannersRepo.updateBannerFields(
        bannerId,
        title: title,
        description: description,
        targetScreen: targetScreen,
        priority: priority,
        active: active,
        scope: scope,
      );
      await fetchAllBanners(); // Refresh banners list
    } catch (e) {
      throw 'Failed to update banner: $e';
    }
  }

  // Add company banner (for admin)
  Future<void> addCompanyBanner(String mode) async {
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
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
          IOSUiSettings(title: 'banner.image'.tr, aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile == null) return;

      File img = File(croppedFile.path);
      localBannerImageFile.value = img.path;

      await showSimpleLoadingDialog<String>(
        context: Get.context!,
        future: () async {
          try {
            isUploading.value = true;
            uploadProgress.value = 0.0;

            message.value = "banner.upload_image_to_server".tr;

            // Upload to Supabase Storage with progress tracking
            final uploadResult = await _uploadBannerImageWithProgress(
              img,
              'company', // Use 'company' as folder identifier
            );

            if (uploadResult['success'] == true) {
              bannerImageHostUrl = uploadResult['url'];
              message.value = "banner.send_data".tr;

              // Get the current authenticated user ID for RLS policy
              final currentUserId =
                  Supabase.instance.client.auth.currentUser?.id;
              if (currentUserId == null) {
                throw Exception('User not authenticated');
              }

              // Create company banner
              var newBanner = BannerModel(
                id: null,
                image: bannerImageHostUrl,
                targetScreen: '/home',
                active: true,
                vendorId: null, // Company banner has no vendorId
                scope: BannerScope.company,
                title: 'Company Banner',
                description: 'Banner created for company',
                priority: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              debugPrint('Creating company banner with data:');
              debugPrint('  Image: ${newBanner.image}');
              debugPrint('  Scope: ${newBanner.scope.name}');
              debugPrint('  VendorId: ${newBanner.vendorId}');

              await bannersRepo.addCompanyBanner(newBanner);

              // Refresh banners list
              await fetchAllBanners();

              TLoader.successSnackBar(
                title: 'banner.banner_added_successfully'.tr,
                message: '',
              );
              message.value = '';

              return "add done";
            } else {
              throw Exception(uploadResult['error'] ?? 'Upload failed');
            }
          } catch (e) {
            message.value = 'Error: $e';
            print("Error adding company banner: $message.value");
            TLoader.erroreSnackBar(
              message: 'banner.failed_to_upload_banner'.tr,
            );
            rethrow;
          } finally {
            isUploading.value = false;
            uploadProgress.value = 0.0;
          }
        },
        // Custom dialog with progress
        dialogBuilder: (context, _) {
          return AlertDialog(
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value:
                              isUploading.value ? uploadProgress.value : null,
                          strokeWidth: 4,
                        ),
                      ),
                      if (isUploading.value)
                        Text(
                          '${(uploadProgress.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(message.value),
                  if (isUploading.value) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: uploadProgress.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        TColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    }
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
          try {
            isUploading.value = true;
            uploadProgress.value = 0.0;

            message.value = "banner.upload_image_to_server".tr;

            // Upload to Supabase Storage with progress tracking
            final uploadResult = await _uploadBannerImageWithProgress(
              img,
              vendorId,
            );

            if (uploadResult['success'] == true) {
              bannerImageHostUrl = uploadResult['url'];
              message.value = "banner.send_data".tr;

              // Get the current authenticated user ID for RLS policy
              final currentUserId =
                  Supabase.instance.client.auth.currentUser?.id;
              if (currentUserId == null) {
                throw Exception('User not authenticated');
              }

              // Try to create vendor banner first, fallback to company banner if needed
              var newBanner = BannerModel(
                id: null, // Let Supabase generate the UUID
                image: bannerImageHostUrl,
                targetScreen: '/home', // Set a default target screen
                active: true,
                vendorId:
                    currentUserId, // Use authenticated user ID for RLS policy
                scope: BannerScope.vendor,
                title: 'New Banner',
                description: 'Banner created via gallery',
                priority: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              // Debug: Print banner data before creation
              debugPrint('Creating banner with data:');
              debugPrint('  ID: ${newBanner.id}');
              debugPrint('  Image: ${newBanner.image}');
              debugPrint('  TargetScreen: ${newBanner.targetScreen}');
              debugPrint('  VendorId: ${newBanner.vendorId}');
              debugPrint('  Scope: ${newBanner.scope.name}');
              debugPrint('  IsValid: ${newBanner.isValid}');
              debugPrint('  Auth UID: $currentUserId');
              debugPrint('  JSON: ${newBanner.toJson()}');

              BannerModel createdBanner;
              try {
                // Try to create vendor banner
                createdBanner = await bannersRepo.createBanner(newBanner);
              } catch (e) {
                debugPrint('Failed to create vendor banner: $e');
                debugPrint('Trying to create company banner as fallback...');

                // Fallback: Create company banner (more permissive policy)
                final companyBanner = newBanner.copyWith(
                  scope: BannerScope.company,
                  vendorId: null,
                );

                debugPrint('Creating company banner with data:');
                debugPrint('  Scope: ${companyBanner.scope.name}');
                debugPrint('  VendorId: ${companyBanner.vendorId}');
                debugPrint('  IsValid: ${companyBanner.isValid}');

                createdBanner = await bannersRepo.createBanner(companyBanner);
              }

              banners.add(createdBanner);
              activeBanners.add(createdBanner);

              TLoader.successSnackBar(
                title: 'banner.banner_added_successfully'.tr,
                message: '',
              );
              message.value = '';

              return "add done";
            } else {
              throw Exception(uploadResult['error'] ?? 'Upload failed');
            }
          } catch (e) {
            message.value = 'Error: $e';
            print(" error with add banners $message.value");
            TLoader.erroreSnackBar(
              message: 'banner.failed_to_upload_banner'.tr,
            );
            rethrow;
          } finally {
            isUploading.value = false;
            uploadProgress.value = 0.0;
          }
        },
        // Custom dialog with progress
        dialogBuilder: (context, _) {
          return AlertDialog(
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value:
                              isUploading.value ? uploadProgress.value : null,
                          strokeWidth: 4,
                        ),
                      ),
                      if (isUploading.value)
                        Text(
                          '${(uploadProgress.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(message.value),
                  if (isUploading.value) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: uploadProgress.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        TColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // Upload banner image to Supabase with progress tracking
  Future<Map<String, dynamic>> _uploadBannerImageWithProgress(
    File imageFile,
    String vendorId,
  ) async {
    try {
      uploadProgress.value = 0.1; // Start progress

      // Validate image type
      if (!imageUploadService.isValidImageType(imageFile)) {
        throw Exception(
          'Invalid image type. Supported formats: JPG, PNG, GIF, WebP',
        );
      }

      uploadProgress.value = 0.2;

      // Get image info
      final imageInfo = await imageUploadService.getImageInfo(imageFile);
      if (imageInfo['isValid'] != true) {
        throw Exception('Invalid image file');
      }

      uploadProgress.value = 0.3;

      // Upload to Supabase Storage
      final result = await imageUploadService.uploadImage(
        imageFile: imageFile,
        folderName: 'banners',
        customFileName:
            'banner_${vendorId}_${DateTime.now().millisecondsSinceEpoch}',
      );

      uploadProgress.value = 0.9;

      if (result['success'] == true) {
        uploadProgress.value = 1.0;
        return {
          'success': true,
          'url': result['url'],
          'path': result['path'],
          'fileName': result['fileName'],
        };
      } else {
        throw Exception(result['error'] ?? 'Upload failed');
      }
    } catch (e) {
      debugPrint('Banner upload error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
