import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TVerticalProductShummer extends StatelessWidget {
  const TVerticalProductShummer({super.key, this.itemCount = 4});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      scrollDirection: Axis.horizontal,
      itemBuilder:
          (_, __) => SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TShimmerEffect(
                  width: 120,
                  height: 180,
                  raduis: BorderRadius.circular(0),
                ),
                const SizedBox(height: TSizes.spaceBtWItems),

                ///text
                const TShimmerEffect(width: 160, height: 15),
                const SizedBox(height: TSizes.spaceBtWItems / 2),
                const TShimmerEffect(width: 110, height: 15),
              ],
            ),
          ),
    );
  }
}
