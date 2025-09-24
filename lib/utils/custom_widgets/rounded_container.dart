import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/color.dart';

class TRoundedContainer extends StatelessWidget {
  const TRoundedContainer({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.child,
    this.showBorder = false,
    this.borderColor = TColors.borderPrimary,
    this.padding,
    this.margin,
    this.enableShadow = false,
    this.backgroundColor = TColors.white,
  });

  final double? width;
  final double? height;
  final BorderRadius? radius;
  final Widget? child;
  final bool enableShadow;
  final bool showBorder;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        boxShadow: enableShadow ? TColors.tboxShadow : null,
        borderRadius: radius,
        border: showBorder ? Border.all(color: borderColor) : null,
        color: backgroundColor,
      ),
      child: child,
    );
  }
}
