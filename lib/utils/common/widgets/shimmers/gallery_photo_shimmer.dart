import 'package:flutter/material.dart';

import 'package:istoreto/utils/common/widgets/layout/grid_layout.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:sizer/sizer.dart';

class TGalleryPhotoShimmer extends StatelessWidget {
  const TGalleryPhotoShimmer({super.key, this.itemCount = 4});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return TGridLayout(
      maxAxisExtent: 240,
      itemCount: itemCount,
      crossColumn: 1,
      itemBuilder:
          (_, __) => SizedBox(
            //width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TShimmerEffect(
                  width: 100.w - TSizes.defaultSpace * 2,
                  height: 100.w / 1.7,
                ),
              ],
            ),
          ),
    );
  }
}
