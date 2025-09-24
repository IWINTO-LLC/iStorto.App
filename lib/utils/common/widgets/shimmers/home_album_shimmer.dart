import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';

import 'package:istoreto/utils/helpers/helper_functions.dart';

class THomeAlbumShimmer extends StatelessWidget {
  const THomeAlbumShimmer({super.key, this.itemCount = 4});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder:
          (_, __) => TRoundedContainer(
            width: THelperFunctions.screenwidth() - 100,
            child: TShimmerEffect(
              width: THelperFunctions.screenwidth() - TSizes.defaultSpace * 2,
              height: THelperFunctions.screenwidth() / 1.7,
            ),
          ),
    );
  }
}
