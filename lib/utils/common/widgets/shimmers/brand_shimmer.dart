import 'package:istoreto/utils/common/widgets/layout/grid_layout.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';

class TBrandShummer extends StatelessWidget {
  const TBrandShummer({super.key, this.itemCount = 6});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return TGridLayout(
      itemCount: itemCount,
      itemBuilder: (_, __) => const TShimmerEffect(width: 300, height: 80),
    );
  }
}
