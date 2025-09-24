import 'package:istoreto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TGridLayout extends StatelessWidget {
  const TGridLayout({
    Key? key,
    this.crossColumn = 2,
    required this.itemCount,
    this.maxAxisExtent = 320,
    required this.itemBuilder,
  }) : super(key: key);
  final int itemCount;
  final int crossColumn;
  final double? maxAxisExtent;
  final Widget Function(BuildContext, int) itemBuilder;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossColumn,
        mainAxisSpacing: TSizes.gridViewSpacing,
        crossAxisSpacing: TSizes.gridViewSpacing,
        mainAxisExtent: maxAxisExtent,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
