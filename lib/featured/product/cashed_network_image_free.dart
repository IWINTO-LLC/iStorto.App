import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

class FreeCaChedNetworkImage extends StatelessWidget {
  const FreeCaChedNetworkImage({
    super.key,
    // required this.width,
    // required this.height,
    required this.url,
    this.enableShadow = true,
    this.enableborder = false,
    this.fit = BoxFit.fill,
    required this.raduis,
  });
  // final double width;
  // final double height;
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
          (context, url, downloadProgress) => TShimmerEffect(
            width: 200,
            height: 300,
            baseColor: TColors.light,
            raduis: raduis,
          ),
      errorWidget:
          (context, url, error) => Padding(
            padding: EdgeInsets.all(15.w),
            child: const Image(image: AssetImage("assets/images/logo_500.png")),
          ),
    );
  }
}
