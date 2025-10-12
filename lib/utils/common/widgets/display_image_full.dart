import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sizer/sizer.dart';

/// Controller for managing the full-size image display state
class DisplayImageFullController extends GetxController {
  final TransformationController transformationController =
      TransformationController();
  final Rx<TapDownDetails?> doubleTapDetails = Rx<TapDownDetails?>(null);
  String imageUrl = '';

  @override
  void onInit() {
    super.onInit();
    // Reset zoom to default when controller is initialized
    transformationController.value = Matrix4.identity();
    doubleTapDetails.value = null;
  }

  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }

  /// Handle double tap to zoom in/out
  void handleDoubleTap() {
    final position = doubleTapDetails.value?.localPosition;
    if (position == null) return;

    final currentScale = transformationController.value.getMaxScaleOnAxis();

    if (currentScale > 1.0) {
      // Reset zoom to original size
      transformationController.value = Matrix4.identity();
    } else {
      // Zoom in, centered around the double-tap location
      final zoomedMatrix =
          Matrix4.identity()
            ..translate(-position.dx * 2, -position.dy * 2)
            ..scale(3.0);
      transformationController.value = zoomedMatrix;
    }
  }

  /// Set double tap details
  void setDoubleTapDetails(TapDownDetails details) {
    doubleTapDetails.value = details;
  }

  /// Navigate back
  void goBack() {
    Navigator.pop(Get.context!);
  }

  /// Save image to gallery
  Future<void> saveImageToGallery() async {
    try {
      // Request storage permissions for different Android versions
      bool hasPermission = false;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33+)
        if (await Permission.photos.request().isGranted) {
          hasPermission = true;
        }
        // For older Android versions
        else if (await Permission.storage.request().isGranted) {
          hasPermission = true;
        }
        // For Android 11+ (API 30+)
        else if (await Permission.manageExternalStorage.request().isGranted) {
          hasPermission = true;
        }
      } else if (Platform.isIOS) {
        // For iOS
        if (await Permission.photos.request().isGranted) {
          hasPermission = true;
        }
      }

      if (!hasPermission) {
        Get.snackbar(
          'common.error'.tr,
          'image_save_permission_required'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          borderRadius: 12,
        );
        return;
      }

      // Show loading message
      Get.snackbar(
        '',
        'image_save_saving_image'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        borderRadius: 12,
        showProgressIndicator: true,
        progressIndicatorBackgroundColor: Colors.white,
        progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(
          Colors.black,
        ),
        isDismissible: false,
      );

      // Download image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('image_save_download_error'.tr);
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');

      // Write image to file
      await file.writeAsBytes(response.bodyBytes);

      // Save to gallery using PhotoManager
      final result = await PhotoManager.editor.saveImage(
        response.bodyBytes,
        filename: fileName,
        title: 'Winto Image',
      );

      if (result != null) {
        Get.snackbar(
          'common_success'.tr,
          'image_save_image_saved_success'.tr,

          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          borderRadius: 12,
        );
      } else {
        throw Exception('image_save_save_failed'.tr);
      }
    } catch (e) {
      Get.snackbar(
        'common_error'.tr,
        'image_save_save_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        borderRadius: 12,
      );
    }
  }

  /// Show save image menu
  void showSaveImageMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.black87,
      items: [
        PopupMenuItem<String>(
          value: 'save',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'image_save.save_image'.tr,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'save') {
        saveImageToGallery();
      }
    });
  }
}

/// Full-size network image display widget using GetX
class NetworkImageFullScreen extends StatelessWidget {
  final String imageUrl;

  const NetworkImageFullScreen(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    // احذف الكنترولر القديم (إن وجد) ثم أنشئ واحد جديد بنفس tag
    Get.delete<DisplayImageFullController>(tag: imageUrl);
    final DisplayImageFullController controller = Get.put(
      DisplayImageFullController(),
      tag: imageUrl,
    );

    // تعيين imageUrl للكنترولر
    controller.imageUrl = imageUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: controller.goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white, size: 24),
            onPressed: () => controller.saveImageToGallery(),
            tooltip: 'image_save_save_image'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: controller.goBack,
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: controller.goBack, // Close on tap outside image
          child: GestureDetector(
            onDoubleTapDown: (details) {
              controller.setDoubleTapDetails(details);
            },
            onDoubleTap: controller.handleDoubleTap,
            onLongPress:
                () =>
                    controller.showSaveImageMenu(context), // إضافة الضغط الطويل
            onTap: () {}, // Prevent tap from bubbling up to parent
            child: InteractiveViewer(
              transformationController: controller.transformationController,
              clipBehavior: Clip.none,
              minScale: 1.0,
              maxScale: 4.0, // Adjust max zoom as needed
              panEnabled: true, // Allow panning when zoomed in
              scaleEnabled: true, // Allow pinch-to-zoom
              child: SizedBox(
                width: 100.w,
                height: 100.h,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                            strokeWidth: 2.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fadeInDuration: const Duration(milliseconds: 500),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
