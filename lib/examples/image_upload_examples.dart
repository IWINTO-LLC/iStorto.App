import 'dart:io';
import 'package:get/get.dart';
import 'package:istoreto/services/image_upload_service.dart';

/// أمثلة على استخدام ImageUploadService في مختلف الحالات
class ImageUploadExamples {
  /// مثال 1: رفع صورة فئة
  static Future<void> uploadCategoryImage(File imageFile) async {
    final result = await ImageUploadService.instance.uploadImage(
      imageFile: imageFile,
      folderName: 'categories',
    );

    if (result['success'] == true) {
      print('Category image uploaded: ${result['url']}');
    } else {
      print('Upload failed: ${result['error']}');
    }
  }

  /// مثال 2: رفع صورة منتج
  static Future<void> uploadProductImage(File imageFile) async {
    final result = await ImageUploadService.instance.uploadImage(
      imageFile: imageFile,
      folderName: 'products',
    );

    if (result['success'] == true) {
      print('Product image uploaded: ${result['url']}');
    } else {
      print('Upload failed: ${result['error']}');
    }
  }

  /// مثال 3: رفع صورة الملف الشخصي
  static Future<void> uploadProfileImage(File imageFile) async {
    final result = await ImageUploadService.instance.uploadImage(
      imageFile: imageFile,
      folderName: 'profiles',
    );

    if (result['success'] == true) {
      print('Profile image uploaded: ${result['url']}');
    } else {
      print('Upload failed: ${result['error']}');
    }
  }

  /// مثال 4: رفع صورة مع اسم مخصص
  static Future<void> uploadImageWithCustomName(File imageFile) async {
    final result = await ImageUploadService.instance.uploadImage(
      imageFile: imageFile,
      folderName: 'banners',
      customFileName: 'main_banner.jpg',
    );

    if (result['success'] == true) {
      print('Banner image uploaded: ${result['url']}');
    } else {
      print('Upload failed: ${result['error']}');
    }
  }

  /// مثال 5: رفع صورة بطريقة مبسطة
  static Future<String?> uploadImageSimple(File imageFile) async {
    return await ImageUploadService.instance.uploadImageSimple(
      imageFile: imageFile,
      folderName: 'gallery',
    );
  }

  /// مثال 6: رفع عدة صور دفعة واحدة
  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
  ) async {
    return await ImageUploadService.instance.uploadMultipleImages(
      imageFiles: imageFiles,
      folderName: 'gallery',
    );
  }

  /// مثال 7: حذف صورة
  static Future<bool> deleteImage(String imagePath) async {
    return await ImageUploadService.instance.deleteImage(imagePath);
  }

  /// مثال 8: التحقق من صحة الصورة
  static Future<void> validateImage(File imageFile) async {
    final info = await ImageUploadService.instance.getImageInfo(imageFile);

    if (info['isValid'] == true) {
      print('Image is valid');
      print('Size: ${info['sizeInMB']} MB');
      print('Extension: ${info['extension']}');
    } else {
      print('Invalid image: ${info['error']}');
    }
  }

  /// مثال 9: استخدام في Controller
  static Future<void> useInController(File imageFile) async {
    try {
      // رفع الصورة
      final imageUrl = await ImageUploadService.instance.uploadImageSimple(
        imageFile: imageFile,
        folderName: 'products',
      );

      if (imageUrl != null) {
        // حفظ في قاعدة البيانات
        // await saveToDatabase(imageUrl);
        print('Image saved to database: $imageUrl');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// مثال 10: رفع مع معالجة الأخطاء المتقدمة
  static Future<void> uploadWithAdvancedErrorHandling(File imageFile) async {
    // التحقق من صحة الصورة أولاً
    if (!ImageUploadService.instance.isValidImageType(imageFile)) {
      print('Invalid image type');
      return;
    }

    // الحصول على معلومات الصورة
    final info = await ImageUploadService.instance.getImageInfo(imageFile);
    print('Image info: $info');

    // رفع الصورة
    final result = await ImageUploadService.instance.uploadImage(
      imageFile: imageFile,
      folderName: 'products',
    );

    if (result['success'] == true) {
      print('Upload successful!');
      print('URL: ${result['url']}');
      print('Path: ${result['path']}');
      print('FileName: ${result['fileName']}');
    } else {
      print('Upload failed: ${result['error']}');
    }
  }
}

/// مثال على استخدام ImageUploadService في Controller
class ExampleController extends GetxController {
  final RxString imageUrl = ''.obs;
  final RxBool isUploading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> uploadImage(File imageFile, String folderName) async {
    isUploading.value = true;
    errorMessage.value = '';

    try {
      final result = await ImageUploadService.instance.uploadImage(
        imageFile: imageFile,
        folderName: folderName,
      );

      if (result['success'] == true) {
        imageUrl.value = result['url'];
      } else {
        errorMessage.value = result['error'] ?? 'Upload failed';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isUploading.value = false;
    }
  }
}
