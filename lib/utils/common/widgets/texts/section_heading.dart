// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/constant.dart';

class TSectionHeading extends StatelessWidget {
  const TSectionHeading({
    Key? key,
    this.textColor,
    required this.title,
    this.showActionButton = false,
    this.buttonTitle = 'View all',
    this.onPress,
  }) : super(key: key);
  final Color? textColor;
  final bool showActionButton;
  final String title, buttonTitle;
  final void Function()? onPress;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: titilliumSemiBold.copyWith(
            fontSize: 20,
            //fontFamily: isLocaleEn(context) ? englishFonts : arabicFonts,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showActionButton)
          TextButton(
            onPressed: onPress,
            child: Text(
              buttonTitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
