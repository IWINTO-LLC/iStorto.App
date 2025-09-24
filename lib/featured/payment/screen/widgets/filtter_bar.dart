import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

class FilterToggleBar extends StatelessWidget {
  final RxBool filterByTime;
  final Function(bool) onChanged;

  const FilterToggleBar({
    required this.filterByTime,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      radius: BorderRadius.circular(20),
      backgroundColor: Colors.white,
      height: 35,
      child: Obx(() {
        return ToggleButtons(
          borderRadius: BorderRadius.circular(20),
          isSelected: [filterByTime.value, !filterByTime.value],
          onPressed: (index) => onChanged(index == 0),
          selectedColor: Colors.white,
          fillColor: TColors.black,
          highlightColor: Colors.grey,
          hoverColor: Colors.yellow,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 8, right: 8),
              child: Text(
                'order.time'.tr,
                style: titilliumBold.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 8, right: 8),
              child: Text(
                'order.state'.tr,
                style: titilliumBold.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
