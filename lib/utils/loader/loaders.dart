import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';

class TLoader {
  static successSnackBar({required title, message = '', duration = 4}) {
    Get.snackbar(
      "success".tr,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      messageText: Text(
        message,
        style: titilliumBold.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      maxWidth: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      borderRadius: 15,
      backgroundColor: Colors.white,
      boxShadows: TColors.tboxShadow,
      borderWidth: 1,
      borderColor: TColors.borderPrimary,
      icon: const Icon(Icons.check, color: Colors.green),
    );
  }

  static progressSnackBar({
    required title,
    message = '',
    duration = const Duration(seconds: 60),
  }) {
    Get.snackbar(
      "progress".tr,
      message,
      isDismissible: false,
      shouldIconPulse: true,
      titleText: Text(
        title,
        style: titilliumSemiBold.copyWith(color: Colors.black),
      ),
      messageText: Text(
        message,
        style: titilliumBold.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      maxWidth: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      progressIndicatorBackgroundColor: TColors.black,
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      borderRadius: 15,
      backgroundColor: TColors.white,
      boxShadows: TColors.tboxShadow,
      borderWidth: 1,
      showProgressIndicator: true,
      borderColor: TColors.black,
      icon: const Icon(Icons.timer, color: Colors.white),
    );
  }

  static stopProgress() {
    Get.closeCurrentSnackbar();
  }

  static warningSnackBar({required title, message = '', duration = 4}) {
    Get.snackbar(
      "warning".tr,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      messageText: Text(
        message,
        style: titilliumBold.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      maxWidth: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      borderRadius: 15,
      backgroundColor: Colors.white,
      boxShadows: TColors.tboxShadow,
      borderWidth: 1,
      borderColor: TColors.borderPrimary,
      icon: const Icon(Icons.warning, color: TColors.warning),
    );
  }

  static erroreSnackBar({message = ''}) {
    Get.snackbar(
      "error".tr,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      messageText: Text(
        message,
        style: titilliumBold.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      maxWidth: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      borderRadius: 15,
      backgroundColor: Colors.white,
      boxShadows: TColors.tboxShadow,
      borderWidth: 1,
      borderColor: TColors.borderPrimary,
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }
}

class LoadingFullscreen {
  static void startLoading() {
    Get.dialog(
      const SimpleDialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        children: <Widget>[Center(child: CircularProgressIndicator.adaptive())],
      ),
    );
  }

  static stopLoading() {
    Get.close(1);
  }
}
