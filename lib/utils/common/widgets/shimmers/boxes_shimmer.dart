import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TBoxesShummer extends StatelessWidget {
  const TBoxesShummer({super.key, this.itemCount = 6});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: TShimmerEffect(width: 150, height: 110)),
            SizedBox(width: TSizes.spaceBtWItems),
            Expanded(child: TShimmerEffect(width: 150, height: 110)),
            SizedBox(width: TSizes.spaceBtWItems),
            Expanded(child: TShimmerEffect(width: 150, height: 110)),
          ],
        ),
      ],
    );
  }
}
