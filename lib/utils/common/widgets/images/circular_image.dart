// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/enums.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    this.fit = BoxFit.cover,
    required this.image,
    this.padding = 1,
    this.overLayColor,
    this.backgroundColor,
    this.imageType,
  });

  final BoxFit? fit;
  final String image;

  final ImageType? imageType;
  final double width, height, padding;
  final Color? overLayColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? TColors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child:
              imageType == ImageType.network
                  ? CachedNetworkImage(
                    fit: fit,
                    color: overLayColor,
                    imageUrl: image,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const TShimmerEffect(width: 80, height: 800),
                        ),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  )
                  : imageType == ImageType.asset
                  ? Image(
                    color: overLayColor,
                    fit: fit,
                    image: AssetImage(image),
                  )
                  : imageType == ImageType.file
                  ? Image.file(File(image), fit: fit)
                  : const SizedBox(),
        ),
      ),
    );
  }
}
