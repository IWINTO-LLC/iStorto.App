import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TClientShimmer extends StatelessWidget {
  const TClientShimmer({super.key, this.itemCount = 4});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) {
          return Column(
            children: [
              TShimmerEffect(
                width: 80,
                height: 75,
                raduis: BorderRadius.circular(80),
              ),
            ],
          );
        },
        separatorBuilder:
            (_, __) => const SizedBox(width: TSizes.spaceBtWItems),
        itemCount: itemCount,
      ),
    );
  }
}
