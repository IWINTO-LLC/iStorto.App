import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/helpers/helper_functions.dart';

class TTabbar extends StatelessWidget implements PreferredSizeWidget {
  const TTabbar({Key? key, required this.tabs}) : super(key: key);

  final List<Widget> tabs;
  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 22),
      labelColor: Colors.white,
      indicator: BoxDecoration(
        color: TColors.black,
        // border: Border.all(color: TColors.darkGrey),
        borderRadius: BorderRadius.circular(30),
      ),
      labelStyle: titilliumSemiBold.copyWith(
        color: TColors.white,
        fontSize: 14,
      ),
      unselectedLabelStyle: titilliumSemiBold.copyWith(
        color: TColors.black,
        fontSize: 14,
      ),

      // isScrollable: true,
      // physics: const BouncingScrollPhysics(),
      // indicatorColor: Colors.black,
      // indicatorSize: TabBarIndicatorSize.label,
      // unselectedLabelColor: TColors.red,
      // labelColor: TColors.black,
      // indicator: UnderlineTabIndicator(
      //     borderSide: BorderSide(width: 5.0),
      //     insets: EdgeInsets.symmetric(horizontal: 16.0)),
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0.1);
}
