import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

class MarketWaitingPage extends StatelessWidget {
  const MarketWaitingPage({super.key, required this.vendorId});
  final String vendorId;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TShimmerEffect(
            width: 90.w,
            height: 90.w * (3 / 4),
            raduis: BorderRadius.circular(15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: MasonryGridView.count(
            itemCount: 12,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return TShimmerEffect(
                width: 45.w,
                height: 45.w * (4 / 3) + 100,
                raduis: BorderRadius.circular(15),
              );
            },
          ),
        ),
      ],
    );
  }
}
