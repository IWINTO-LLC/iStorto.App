// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TProductTitleText extends StatelessWidget {
  const TProductTitleText({
    super.key,
    required this.title,
    this.smalSize = false,
    this.maxLines = 2,
    this.txtAlign = TextAlign.left,
  });
  final String title;
  final bool smalSize;
  final int maxLines;
  final TextAlign? txtAlign;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall!
          .copyWith(fontFamily: 'Tajawal-Medium', fontSize: 16),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: txtAlign,
    );
  }
}
