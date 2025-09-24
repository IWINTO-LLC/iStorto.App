import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class THorizentalProductShummer extends StatelessWidget {
  const THorizentalProductShummer({super.key, this.itemCount = 4});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      scrollDirection: Axis.horizontal,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        return const SizedBox(
          width: 120,
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TShimmerEffect(width: 120, height: 180),
              SizedBox(width: TSizes.spaceBtWItems),

              Row(
                children: [
                  TShimmerEffect(width: 110, height: 15),
                  SizedBox(height: TSizes.spaceBtWItems),
                  TShimmerEffect(width: 140, height: 15),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
