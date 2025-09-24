import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/constant.dart';

class SlidingFadeQuantityText extends StatelessWidget {
  final int quantity;

  const SlidingFadeQuantityText({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final isNew = child.key == ValueKey(quantity);

        if (isNew) {
          // الرقم الجديد: Slide للأعلى أو للأسفل
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        } else {
          // الرقم القديم: يختفي بغموض فقط
          return FadeTransition(opacity: animation, child: child);
        }
      },
      child: Text(
        '$quantity',
        key: ValueKey(quantity),
        style: titilliumBold.copyWith(fontSize: 16, fontFamily: numberFonts),
      ),
    );
  }
}
