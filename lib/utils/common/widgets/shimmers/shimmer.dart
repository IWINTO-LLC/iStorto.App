import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:shimmer/shimmer.dart';

class TShimmerEffect extends StatelessWidget {
  const TShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.raduis,
    this.baseColor,
    this.color,
  });

  final double width, height;
  final BorderRadius? raduis;
  final Color? color;
  final Color? baseColor;
  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);

    return Shimmer.fromColors(
      baseColor: baseColor ?? TColors.lightgrey,
      highlightColor: TColors.lightgrey,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (TColors.white),
          borderRadius: raduis,
        ),
      ),
    );
  }
}

class TShimmerEffectdark extends StatelessWidget {
  const TShimmerEffectdark({
    super.key,
    required this.width,
    required this.height,
    this.raduis = 15,
    this.color,
  });

  final double width, height, raduis;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[200]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (TColors.white),
          borderRadius: BorderRadius.circular(raduis),
        ),
      ),
    );
  }
}
