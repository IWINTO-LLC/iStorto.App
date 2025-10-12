import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

class CustomFloatActionButton extends StatelessWidget {
  CustomFloatActionButton({
    super.key,
    required this.onTap,
    this.icon = CupertinoIcons.add,
    this.isIcon = true,
    this.widget,
    this.heroTag,
  });
  final VoidCallback onTap;
  final IconData icon;
  final bool isIcon;
  final Widget? widget;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag, // إضافة heroTag فريد لتجنب التضارب
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.transparent,
      //focusColor: TColors.primary,
      onPressed: onTap,

      child: Center(
        child: TRoundedContainer(
          enableShadow: true,
          width: 35,
          height: 35,
          showBorder: true,
          borderWidth: .5,
          borderColor: TColors.borderPrimary.withValues(alpha: .5),
          radius: BorderRadius.circular(300),
          child: isIcon ? Icon(icon, size: 20, color: TColors.black) : widget,
        ),
      ),
    );
  }
}
