import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TLargListTilehummer extends StatelessWidget {
  const TLargListTilehummer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              TShimmerEffect(
                width: 200,
                height: 120,
                raduis: BorderRadius.circular(20),
              ),
              const Spacer(),
              const Column(
                children: [
                  TShimmerEffect(width: 50, height: 30),
                  SizedBox(width: TSizes.spaceBtWItems / 2),
                  TShimmerEffect(width: 80, height: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
