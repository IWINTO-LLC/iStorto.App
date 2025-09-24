import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:sizer/sizer.dart';

class AnimeEmptyLogo extends StatelessWidget {
  const AnimeEmptyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/liquid_loading.gif',
            width: 70.w,
            height: 70.w,
          ),
          Text('noItemsYet'.tr, style: titilliumBold.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}
