import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/helpers/helper_functions.dart';

class TSettingTile extends StatelessWidget {
  const TSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    //final controller = UserController.instance;
    return SizedBox(
      height: 130,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: const [
          StaticsItem(
            icon: CupertinoIcons.chat_bubble,
            text: 'build',
            number: '12',
          ),
        ],
      ),
    );
  }
}

class StaticsItem extends StatelessWidget {
  const StaticsItem({
    super.key,
    required this.text,
    required this.number,
    required this.icon,
  });
  final String text;
  final String number;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: TRoundedContainer(
        enableShadow: true,
        backgroundColor:
            THelperFunctions.isDarkMode(context) ? TColors.dark : TColors.light,
        width: 110,
        radius: BorderRadius.circular(20),
        //showBorder: true,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(icon, size: 40, color: TColors.primary)),
              Text(number),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall!.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
