import 'package:flutter/material.dart';
import 'package:istoreto/navigation_menu.dart';

import 'package:istoreto/utils/constants/sizes.dart';
import 'package:get/get.dart';

import 'package:sizer/sizer.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    Key? key,
    required this.subTitle,
    required this.title,
    required this.image,
    required this.onPressed,
  }) : super(key: key);
  final String image, title, subTitle;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
          (route) => false,
        );
        return true;
      },
      child: Directionality(
        textDirection:
            Get.locale?.languageCode == 'en'
                ? TextDirection.ltr
                : TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 100.h / 5,
                  left: TSizes.defaultSpace,
                  right: TSizes.defaultSpace,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: AssetImage(image), width: 60.w),
                      const SizedBox(height: TSizes.spaceBtWsections),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TSizes.spaceBtWItems),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TSizes.spaceBtWsections),
                      SizedBox(
                        width: 60.w,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          child: const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
