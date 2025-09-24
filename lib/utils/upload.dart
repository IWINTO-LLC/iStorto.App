// lib/core/services/upload_service.dart
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:dio/src/form_data.dart' as dio;
import 'package:dio/src/multipart_file.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/data/models/upload_result.dart';

class UploadService extends GetxService {
  static UploadService get instance => Get.find();

  final Dio _dio = Dio();
  final RxDouble _uploadProgress = 0.0.obs;
  final RxBool _isUploading = false.obs;

  // Getters
  double get uploadProgress => _uploadProgress.value;
  bool get isUploading => _isUploading.value;

  // Observable getters for UI
  RxDouble get uploadProgressObs => _uploadProgress;
  RxBool get isUploadingObs => _isUploading;

  Future<UploadResult> uploadMediaToServer(
    File file, {
    Function(double progress)? onProgress,
  }) async {
    log('attempting to upload media to server ...');

    // Update uploading state
    _isUploading.value = true;
    _uploadProgress.value = 0.0;

    String uploadUrl = '${_getApiUrl()}/upload';
    const String bearerToken = 'fd8c30fb-c66a-43b2-bf42-f5f250804904';

    dio.FormData formData = dio.FormData.fromMap({
      "file": await dio.MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });

    try {
      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
        onSendProgress: (int sent, int total) {
          double fileProgress = sent / total;
          log(
            "File upload progress: ${(fileProgress * 100).toStringAsFixed(2)}%",
          );

          // Update progress
          _uploadProgress.value = fileProgress;

          if (onProgress != null) {
            onProgress(fileProgress);
          }
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        log('jsonResponse : ${jsonResponse.toString()}');

        List<String> tags = List<String>.from(jsonResponse['tags'] ?? []);
        String fileUrl = jsonResponse['original_file'];

        log('returning fileUrl: $fileUrl, tags: $tags');

        // Reset states
        _isUploading.value = false;
        _uploadProgress.value = 0.0;

        // Show success message
        Get.snackbar(
          'upload.upload_completed'.tr,
          '',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return UploadResult(fileUrl: fileUrl, tags: tags);
      } else {
        log('Failed to upload file: ${response.statusCode}');
        log('Error message from server: ${response.data}');

        // Reset states on error
        _isUploading.value = false;
        _uploadProgress.value = 0.0;

        throw Exception(
          'Failed to upload file: ${response.statusCode}, Error: ${response.data}',
        );
      }
    } catch (e) {
      // Reset states on error
      _isUploading.value = false;
      _uploadProgress.value = 0.0;

      // Show error message
      Get.snackbar(
        'upload.error'.tr,
        'upload.failed_to_upload_file'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      log('Error occurred: $e');
      throw Exception('Error occurred: $e');
    }
  }

  String _getApiUrl() {
    // Get API URL from your config
    return 'https://your-api-url.com'; // Replace with your actual API URL
  }

  // Method to upload multiple files
  Future<List<UploadResult>> uploadMultipleFiles(List<File> files) async {
    List<UploadResult> results = [];

    for (int i = 0; i < files.length; i++) {
      try {
        UploadResult result = await uploadMediaToServer(
          files[i],
          onProgress: (progress) {
            // Calculate overall progress for multiple files
            double overallProgress = (i + progress) / files.length;
            _uploadProgress.value = overallProgress;
          },
        );
        results.add(result);
      } catch (e) {
        log('Failed to upload file ${i + 1}: $e');
        // Continue with other files
      }
    }

    return results;
  }

  // Method to cancel upload
  void cancelUpload() {
    _dio.close();
    _isUploading.value = false;
    _uploadProgress.value = 0.0;

    // Show cancellation message
    Get.snackbar(
      'upload.upload_cancelled'.tr,
      '',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
