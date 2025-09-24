import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/constant.dart';

class SlidingQuantityText extends StatelessWidget {
  final int quantity;

  const SlidingQuantityText({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: Offset(0, quantity > 0 ? 1 : -1),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      child: Text(
        '$quantity',
        key: ValueKey(quantity),
        style: titilliumBold.copyWith(fontSize: 16, fontFamily: numberFonts),
      ),
    );
  }
}
