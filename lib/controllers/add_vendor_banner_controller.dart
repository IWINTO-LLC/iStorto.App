import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istoreto/controllers/vendor_banners_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/services/supabase_service.dart';
// removed unused import

class AddVendorBannerController extends GetxController {
  final String vendorId;
  final _supabaseService = SupabaseService();
  final _imagePicker = ImagePicker();

  AddVendorBannerController({required this.vendorId});

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  final priorityController = TextEditingController(text: '0');

  // Observable variables
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isActive = true.obs;
  final RxInt priority = 0.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    priorityController.dispose();
    super.onClose();
  }

  // اختيار وقص الصورة
  Future<void> pickAndCropImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 2040,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        await _cropImage(pickedImage);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // قص الصورة بنسبة ثابتة 0.5882
  Future<void> _cropImage(XFile image) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 0.5882),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Banner Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Banner Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImage.value = XFile(croppedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to crop image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // حذف الصورة المحددة
  void removeImage() {
    selectedImage.value = null;
  }

  // تحديث حالة النشاط
  void toggleActive(bool value) {
    isActive.value = value;
  }

  // تحديث الأولوية
  void updatePriority(String value) {
    priority.value = int.tryParse(value) ?? 0;
  }

  // حفظ البانر
  Future<void> saveBanner() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedImage.value == null) {
      Get.snackbar(
        'Error',
        'Please select a banner image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      // رفع الصورة
      uploadProgress.value = 0.3;
      final bytes = await selectedImage.value!.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.value!.name}';
      final path = 'banners/$fileName';

      final uploadResult = await _supabaseService.uploadImageToStorage(
        bytes,
        path,
      );

      if (!uploadResult['success']) {
        throw Exception(uploadResult['message'] ?? 'Failed to upload image');
      }

      uploadProgress.value = 0.7;

      // إنشاء البانر
      final banner = BannerModel(
        image: uploadResult['url'],
        targetScreen: 'home',
        active: isActive.value,
        scope: BannerScope.vendor,
        vendorId: vendorId,
        title: titleController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        priority: priority.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // حفظ في قاعدة البيانات
      // إذا لم يكن VendorBannersController مسجلاً (عند الفتح من خارج صفحة إدارة بانرات التاجر)
      // نقوم بتسجيله مؤقتاً باستخدام نفس vendorId، ثم نحذفه بعد الإضافة.
      VendorBannersController? tempController;
      late VendorBannersController bannersController;
      if (Get.isRegistered<VendorBannersController>()) {
        bannersController = Get.find<VendorBannersController>();
      } else {
        tempController = Get.put(VendorBannersController(vendorId: vendorId));
        bannersController = tempController!;
      }

      await bannersController.addBanner(banner);

      uploadProgress.value = 1.0;

      // في حال أنشأنا كونترولر مؤقتاً، نحذفه بعد الانتهاء
      if (tempController != null) {
        Get.delete<VendorBannersController>(force: true);
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Banner added successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add banner: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // عرض نافذة اختيار مصدر الصورة
  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('admin_select_image_source'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                pickAndCropImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                pickAndCropImage(ImageSource.gallery);
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
}
