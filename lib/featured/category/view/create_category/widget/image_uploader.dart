import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/icons/circuler_icon.dart';
import 'package:istoreto/utils/common/widgets/images/circular_image.dart';
import 'package:istoreto/utils/common/widgets/images/rounded_image.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TImageUploader extends StatelessWidget {
  const TImageUploader({
    super.key,
    this.circuler = false,
    this.image,
    this.imageType,
    this.icon = Icons.edit,
    this.top,
    this.bottom = 0,
    this.left = 0,
    this.right,
    this.width = 100,
    this.height = 100,
    this.onIconButtonPressed,
  });
  final bool circuler;
  final String? image;
  final ImageType? imageType;
  //final Unit8List? memoryImage;
  final IconData icon;
  final double? top;
  final double? bottom;
  final double left;
  final double? right;
  final double width;
  final double height;
  final void Function()? onIconButtonPressed;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        circuler
            ? TCircularImage(
              image: image!,
              width: width,
              height: height,
              imageType: imageType,
              backgroundColor: TColors.primaryBackground,
            )
            : TRoundedImage(
              imageUrl: image!,
              borderRaduis: BorderRadius.circular(10),
              width: width,
              height: height,
              imageType: imageType!,
              backgroundColor: TColors.primaryBackground,
            ),
        Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: TCircularIcon(
            width: 35,
            height: 35,
            icon: icon,
            size: TSizes.md,
            color: TColors.black,
            onPressed: onIconButtonPressed,
          ),
        ),
      ],
    );
  }
}
