import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class ConfirmationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final String? description;
  final Function onYesPressed;
  final bool isLogOut;
  final bool refund;
  final Color? color;
  final TextEditingController? note;
  const ConfirmationDialog({
    super.key,
    required this.icon,
    this.title,
    this.description,
    required this.onYesPressed,
    this.isLogOut = false,
    this.refund = false,
    this.note,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.sm),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.paddingSizeDefault),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(TSizes.paddingSizeDefault),
                child: Image.asset(icon, width: 50, height: 50),
              ),
              title != null
                  ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.paddingSizeDefault,
                    ),
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: TSizes.md,
                        color: color ?? Colors.red,
                      ),
                    ),
                  )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.all(TSizes.paddingSizeDefault),
                child: Column(
                  children: [
                    Text(
                      description ?? '',
                      style: titilliumBold.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    refund
                        ? TextFormField(
                          controller: note,
                          decoration: InputDecoration(
                            hintText: 'dialog.note'.tr,
                          ),
                          textAlign: TextAlign.center,
                        )
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.paddingSizeDefault),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('dialog.no'.tr),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.paddingSizeDefault),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: ElevatedButton(
                        child: Text('dialog.yes'.tr),
                        onPressed: () {
                          onYesPressed();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
