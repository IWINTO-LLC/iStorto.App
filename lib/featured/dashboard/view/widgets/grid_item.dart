import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TGridItem extends StatelessWidget {
  final String image;
  final String? title;
  final bool isProfile;
  final Function? onTap;
  const TGridItem({
    super.key,
    required this.image,
    required this.title,
    this.isProfile = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: TColors.light,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              spreadRadius: 0.5,
              blurRadius: 0.3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 35, height: 35, child: Image.asset(image)),
            const SizedBox(height: TSizes.radiusSmall),
            Expanded(
              child: Center(
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoSmallTitleRegular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
