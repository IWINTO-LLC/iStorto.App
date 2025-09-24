// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';

import 'package:istoreto/utils/constants/color.dart';

class TSettingMenuTile extends StatelessWidget {
  const TSettingMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = TColors.black,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title, style: titilliumSemiBold)],
            ),
          ],
        ),
      ),
    );

    // ListTile(
    //     onTap: onTap,
    //     leading: Icon(
    //       icon,
    //       size: 28,
    //       color: iconColor,
    //     ),
    //     title: Text(
    //       title,
    //       style: titilliumSemiBold,
    //     ),
    //     subtitle: Text(subTitle, style: robotoMedium.copyWith(fontSize: 12)),
    //     trailing: trailing),
    // );
  }
}
