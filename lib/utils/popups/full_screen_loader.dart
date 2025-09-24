import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/widgets/loaders/animation_loading.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/helpers/helper_functions.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class TFullScreenLoader {
  static void openloadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder:
          (_) => Container(
            color:
                THelperFunctions.isDarkMode(Get.context!)
                    ? TColors.dark
                    : TColors.light,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 180),
                TAnimationLoaderWidget(text: text, animation: animation),
              ],
            ),
          ),
    );
  }

  static void openloadingDialogText(String text) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder:
          (_) => Container(
            color: TColors.light,
            width: THelperFunctions.screenwidth() / 2,
            height: THelperFunctions.screenHeight() / 2,
            child: Column(
              children: [
                const SizedBox(height: 90),
                const TLoaderWidget(),
                const SizedBox(height: 30),
                Text(text),
              ],
            ),
          ),
    );
  }

  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
