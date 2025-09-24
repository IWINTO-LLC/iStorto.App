import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:istoreto/utils/device/device_utility.dart';

class ReusableAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    if (TDeviceUtils.isIos()) {
      // iOS-style dialog
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('general.cancel'.tr),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(
                  'general.confirm'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.copyWith(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Android-style dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: Text('general.cancel'.tr),

                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'general.confirm'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.copyWith(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
