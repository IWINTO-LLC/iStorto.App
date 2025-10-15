
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/utils/constants/color.dart';

class TLoaderWidget extends StatelessWidget {
  const TLoaderWidget({this.size = 30, this.color = Colors.black, super.key});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: //discreteCircular
          LoadingAnimationWidget.discreteCircle(
        color: color,
        secondRingColor: TColors.primary,
        thirdRingColor: TColors.borderPrimary,
        size: 10.w,
      ),

      //     LoadingAnimationWidget.flickr(

      //   size: 10.w, leftDotColor: TColors.black, rightDotColor: TColors.primary,
      // )
    );
  }
}
