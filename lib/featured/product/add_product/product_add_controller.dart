import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/section_model.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:istoreto/utils/upload.dart';

class ProductAddController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final minQuantityController = TextEditingController(text: '1');

  Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  Rx<SectionModel?> selectedSection = Rx<SectionModel?>(null);

  RxList<File> pickedImages = <File>[].obs;
  RxBool isLoading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  // استدعاء اختيار الصور
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      for (var image in images) {
        pickedImages.add(File(image.path));
      }
    }
  }

  // اقتصاص صورة
  Future<void> cropImage(int index) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: pickedImages[index].path,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4), // 600x800
      maxWidth: 600,
      maxHeight: 800,
      compressQuality: 85,
    );
    if (cropped != null) {
      pickedImages[index] = File(cropped.path);
      pickedImages.refresh();
    }
  }

  // حذف صورة
  void removeImage(int index) {
    pickedImages.removeAt(index);
  }

  // رفع الصور باستخدام uploadMediaToServer
  Future<List<String>> uploadImages() async {
    List<String> imageUrls = [];

    for (int i = 0; i < pickedImages.length; i++) {
      try {
        uploadProgress.value = (i / pickedImages.length);

        var result = await UploadService.instance.uploadMediaToServer(
          pickedImages[i],
          onProgress: (progress) {
            // يمكن إضافة progress bar لكل صورة
            uploadProgress.value = progress;
          },
        );

        imageUrls.add(result.fileUrl);
      } catch (e) {
        Get.snackbar(
          'خطأ في رفع الصورة',
          'فشل في رفع الصورة رقم ${i + 1}: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
        throw e;
      }
    }

    uploadProgress.value = 1.0;
    return imageUrls;
  }

  // حفظ المنتج
  Future<void> saveProduct() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال عنوان المنتج');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال سعر المنتج');
      return;
    }

    if (selectedCategory.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار فئة للمنتج');
      return;
    }

    if (pickedImages.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إضافة صورة واحدة على الأقل');
      return;
    }

    isLoading.value = true;
    try {
      // رفع الصور إلى الخادم
      List<String> imageUrls = await uploadImages();

      // إنشاء المنتج
      final product = ProductModel(
        id: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text) ?? 0.0,
        vendorId:
            VendorController.instance.vendorData.value.userId, // عدل حسب السياق
        images: imageUrls,
        category: selectedCategory.value,
        minQuantity: int.tryParse(minQuantityController.text) ?? 1,
        thumbnail: imageUrls.isNotEmpty ? imageUrls.first : null,
        productType: 'physical', // أو 'digital' حسب نوع المنتج
        isDeleted: false,
        isFeature: false,
      );

      await ProductRepository.instance.createProduct(product);

      // إعادة تعيين الحقول
      resetForm();

      Get.snackbar(
        'نجح',
        'تم إضافة المنتج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // إعادة تعيين النموذج
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    minQuantityController.text = '1';
    pickedImages.clear();
    selectedCategory.value = null;
    selectedSection.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    minQuantityController.dispose();
    super.onClose();
  }
}
