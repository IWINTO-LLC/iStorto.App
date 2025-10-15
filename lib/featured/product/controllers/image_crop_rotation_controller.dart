import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:istoreto/featured/product/controllers/product_controller.dart';

class ImageController extends GetxController {
  var rotationAngle = 0.0.obs;

  void updateRotation(double angle) {
    rotationAngle.value = angle;
  }
}

class CropRotateImage extends StatelessWidget {
  final String imagePath;
  CropRotateImage({super.key, required this.imagePath});

  final ImageController controller = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails details) {
        controller.updateRotation(details.rotation);
      },
      child: Obx(
        () => Transform.rotate(
          angle: controller.rotationAngle.value,
          child: Image.asset(imagePath),
        ),
      ),
    );
  }

  Future<void> cropImage(String imagePath) async {
    if (imagePath == "") return;
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 600, ratioY: 800),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'product_image'.tr,
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'product_image'.tr),
      ],
    );

    if (croppedFile != null) {
      var i = ProductController.instance.selectedImage.indexWhere(
        (img) => img.path == imagePath,
      );
      ProductController.instance.selectedImage.removeWhere(
        (img) => img.path == imagePath,
      );

      ProductController.instance.selectedImage.insert(
        i,
        XFile(croppedFile.path),
      );
      controller.updateRotation(0.0);
    }
  }
}
