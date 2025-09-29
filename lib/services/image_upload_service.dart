import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/services/supabase_service.dart';

/// خدمة مستقلة لرفع الصور إلى Supabase Storage
/// يمكن استخدامها في جميع أنحاء التطبيق
class ImageUploadService {
  static ImageUploadService get instance => Get.find();

  final SupabaseService _supabaseService = SupabaseService();

  /// رفع صورة إلى Supabase Storage
  ///
  /// [imageFile] - ملف الصورة
  /// [folderName] - اسم المجلد (مثل: categories, products, profiles, etc.)
  /// [customFileName] - اسم مخصص للصورة (اختياري)
  ///
  /// Returns: Map يحتوي على success, url, error
  Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String folderName,
    String? customFileName,
  }) async {
    try {
      if (kDebugMode) {
        print("================= Uploading image to Supabase =======");
        print("Image path: ${imageFile.path}");
        print("Folder: $folderName");
      }

      // التحقق من وجود الملف
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // قراءة bytes الصورة
      final bytes = await imageFile.readAsBytes();

      // التحقق من حجم الصورة (اختياري - 10MB حد أقصى)
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('Image size too large. Maximum 10MB allowed.');
      }

      // توليد اسم فريد للصورة
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          customFileName ?? '${folderName}_${timestamp}.$extension';
      final path = '$folderName/$fileName';

      // رفع الصورة إلى Supabase Storage
      final result = await _supabaseService.uploadImageToStorage(bytes, path);

      if (result['success'] == true) {
        final imageUrl = result['url'] ?? '';
        if (kDebugMode) {
          print("Upload successful! URL: $imageUrl");
        }

        return {
          'success': true,
          'url': imageUrl,
          'path': path,
          'fileName': fileName,
        };
      } else {
        throw Exception(result['error'] ?? 'Upload failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Upload error: $e");
      }

      return {
        'success': false,
        'error': e.toString(),
        'url': null,
        'path': null,
        'fileName': null,
      };
    }
  }

  /// رفع صورة مع معالجة تلقائية للأخطاء
  ///
  /// [imageFile] - ملف الصورة
  /// [folderName] - اسم المجلد
  /// [customFileName] - اسم مخصص للصورة (اختياري)
  ///
  /// Returns: String URL الصورة أو null في حالة الفشل
  Future<String?> uploadImageSimple({
    required File imageFile,
    required String folderName,
    String? customFileName,
  }) async {
    final result = await uploadImage(
      imageFile: imageFile,
      folderName: folderName,
      customFileName: customFileName,
    );

    return result['success'] == true ? result['url'] : null;
  }

  /// رفع عدة صور دفعة واحدة
  ///
  /// [imageFiles] - قائمة ملفات الصور
  /// [folderName] - اسم المجلد
  ///
  /// Returns: List من URLs الصور
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String folderName,
  }) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final result = await uploadImage(
        imageFile: imageFiles[i],
        folderName: folderName,
        customFileName:
            '${folderName}_${DateTime.now().millisecondsSinceEpoch}_$i',
      );

      if (result['success'] == true) {
        uploadedUrls.add(result['url']);
      }
    }

    return uploadedUrls;
  }

  /// حذف صورة من Supabase Storage
  ///
  /// [imagePath] - مسار الصورة في Storage
  ///
  /// Returns: true إذا تم الحذف بنجاح
  Future<bool> deleteImage(String imagePath) async {
    try {
      await SupabaseService.client.storage.from('images').remove([imagePath]);

      if (kDebugMode) {
        print("Image deleted successfully: $imagePath");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Delete image error: $e");
      }
      return false;
    }
  }

  /// التحقق من صحة نوع الصورة
  ///
  /// [imageFile] - ملف الصورة
  ///
  /// Returns: true إذا كان نوع الصورة مدعوم
  bool isValidImageType(File imageFile) {
    final extension = imageFile.path.split('.').last.toLowerCase();
    const supportedTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return supportedTypes.contains(extension);
  }

  /// الحصول على معلومات الصورة
  ///
  /// [imageFile] - ملف الصورة
  ///
  /// Returns: Map يحتوي على معلومات الصورة
  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.path.split('.').last.toLowerCase();

      return {
        'size': bytes.length,
        'sizeInMB': (bytes.length / (1024 * 1024)).toStringAsFixed(2),
        'extension': extension,
        'isValid': isValidImageType(imageFile),
        'path': imageFile.path,
      };
    } catch (e) {
      return {'error': e.toString(), 'isValid': false};
    }
  }
}
