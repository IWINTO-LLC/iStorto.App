import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

class AlbumLoadingGrid extends StatelessWidget {
  const AlbumLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 6, // عدد العناصر الوهمية أثناء التحميل
      itemBuilder: (context, index) {
        return const _ShimmerAlbumCard();
      },
    );
  }
}

class _ShimmerAlbumCard extends StatelessWidget {
  const _ShimmerAlbumCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const TShimmerEffect(
          width: double.infinity,
          height: double.infinity,
          raduis: BorderRadius.all(Radius.circular(12)),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black12,
          ),
        ),
        const Positioned(
          top: 12,
          left: 12,
          child: TShimmerEffect(width: 80, height: 16),
        ),
        const Positioned(
          bottom: 10,
          right: 12,
          child: TShimmerEffect(width: 20, height: 14),
        ),
      ],
    );
  }
}
