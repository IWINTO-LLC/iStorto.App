import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/enums.dart';

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    super.key,
    this.width = 80,
    this.height = 80,
    required this.imageUrl,
    this.applyImageRaduis = true,
    this.border,
    this.backgroundColor = TColors.light,
    this.fit = BoxFit.cover,
    this.padding,
    required this.imageType,
    this.onPressed,
    required this.borderRaduis,
  });
  final double? width, height;
  final String imageUrl;
  final bool applyImageRaduis;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final ImageType imageType;
  final VoidCallback? onPressed;
  final BorderRadius borderRaduis;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: borderRaduis,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child:
                imageType == ImageType.network
                    ? CachedNetworkImage(
                      fit: fit,
                      imageUrl: imageUrl,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => ClipRRect(
                            borderRadius: borderRaduis,
                            child: TShimmerEffect(
                              width: width!,
                              height: height!,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    )
                    : imageType == ImageType.asset
                    ? Image(fit: fit, image: AssetImage(imageUrl))
                    : imageType == ImageType.file
                    ? Image.file(File(imageUrl), fit: fit)
                    : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
