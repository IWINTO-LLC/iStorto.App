import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool showResetIcon;
  final Widget? reset;
  final bool showLogo;
  final IconData icon;
  final Color? iconColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.iconColor = Colors.black,
    this.icon = Icons.arrow_back,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.showActionButton = true,
    this.fontSize,
    this.showResetIcon = false,
    this.reset,
    this.showLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50.0),
      child: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            title ?? '',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: TSizes.paddingSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        centerTitle: true,
        excludeHeaderSemantics: true,
        titleSpacing: 0,
        elevation: 1,
        clipBehavior: Clip.none,
        shadowColor: Theme.of(context).primaryColor.withValues(alpha: .1),
        leadingWidth: isBackButtonExist ? 50 : 120,
        leading:
            isBackButtonExist
                ? Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: IconButton(
                    icon: Icon(icon, size: 25, color: iconColor),
                    onPressed:
                        () =>
                            onBackPressed != null
                                ? onBackPressed!()
                                : Navigator.pop(context),
                  ),
                )
                : showLogo
                ? Padding(
                  padding: const EdgeInsets.only(
                    left: TSizes.paddingSizeDefault,
                  ),
                  child: SizedBox(child: Image.asset(TImages.shop)),
                )
                : const SizedBox(),
      ),
    );
  }

  @override
  Size get preferredSize => Size(MediaQuery.of(Get.context!).size.width, 70);
}
