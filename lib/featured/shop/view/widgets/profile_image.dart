import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

class TProfilePicture extends StatelessWidget {
  const TProfilePicture({
    super.key,
    required this.userImg,
    required this.width,
    required this.height,
  });

  final String userImg;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: TRoundedContainer(
        radius: BorderRadius.circular(100),
        width: 100,
        height: 100,
        child: CachedNetworkImage(
          imageUrl: userImg,
          imageBuilder:
              (context, imageProvider) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          fit: BoxFit.cover,
          placeholder:
              (context, url) => TShimmerEffect(
                width: width,
                height: height,
                raduis: BorderRadius.circular(50),
              ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),

        // Half of the container width/height
      ),
    );
  }
}
