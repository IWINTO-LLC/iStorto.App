import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class BuildBottomMenuItem extends StatelessWidget {
  const BuildBottomMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.leading,
  });
  final Widget icon;
  final String text;
  final Widget? leading;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 89.3.w,
      decoration: BoxDecoration(
        color: TColors.instaGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 100.w,
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                color: TColors.instaGrey,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    icon,
                    const SizedBox(width: 16),
                    Text(text),
                    Spacer(),
                    leading ?? SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
