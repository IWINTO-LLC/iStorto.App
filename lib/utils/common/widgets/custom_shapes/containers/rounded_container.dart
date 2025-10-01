// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/color.dart';

class TRoundedContainer extends StatelessWidget {
  const TRoundedContainer({
    Key? key,
    this.width,
    this.height,
    this.radius,
    this.child,
    this.showBorder = false,
    this.borderColor = const Color(0xFFEEEEEE),
    this.padding,
    this.margin,
    this.enableShadow = false,
    this.backgroundColor = TColors.white,
    this.borderWidth,
  }) : super(key: key);

  final double? width;
  final double? height;
  final BorderRadius? radius;
  final Widget? child;
  final bool enableShadow;
  final bool showBorder;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderWidth;
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
        border:
            showBorder
                ? Border.all(color: borderColor, width: borderWidth ?? 0.5)
                : null,
        color: backgroundColor,
      ),
      child: child,
    );
  }
}
