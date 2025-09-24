import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TVerticalImageText extends StatelessWidget {
  const TVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.borderColor,
    this.isNetworkImage = false,
    this.textColor,
    this.backgroundColor,
    this.onTap,
  });
  final String image, title;
  final Color? textColor;
  final bool isNetworkImage;

  final Color? backgroundColor;
  final Color? borderColor;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          right: TSizes.spaceBtWItems / 2.5,
          left: TSizes.spaceBtWItems / 2.5,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor ?? Colors.transparent),
                color: backgroundColor ?? TColors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Image(
                  image:
                      isNetworkImage
                          ? NetworkImage(image)
                          : AssetImage(image) as ImageProvider,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtWItems / 2),
            Wrap(
              children: [
                SizedBox(
                  width: 92,
                  child: Center(
                    child: Text(
                      title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.apply(color: textColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
