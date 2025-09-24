import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

class CustomCaChedNetworkImage extends StatelessWidget {
  const CustomCaChedNetworkImage({
    super.key,
    required this.width,
    required this.height,
    required this.url,
    this.enableShadow = true,
    this.enableborder = false,
    this.fit = BoxFit.cover,
    required this.raduis,
  });
  final double width;
  final double height;
  final bool enableShadow;
  final bool enableborder;
  final BorderRadius raduis;
  final String url;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder:
          (context, imageProvider) => Container(
            decoration: BoxDecoration(
              boxShadow: enableShadow ? TColors.tboxShadow : null,
              borderRadius: raduis,
              border:
                  enableborder
                      ? Border.all(color: TColors.borderPrimary)
                      : null,
              color: TColors.light,
              image: DecorationImage(image: imageProvider, fit: fit),
            ),
          ),
      progressIndicatorBuilder:
          (context, url, downloadProgress) =>
              TShimmerEffect(width: width, height: height, raduis: raduis),
      errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
    );
  }
}
