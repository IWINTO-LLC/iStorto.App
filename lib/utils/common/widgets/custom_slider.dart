import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:istoreto/featured/product/cashed_network_image.dart';

class CustomSlider extends StatelessWidget {
  CustomSlider({
    super.key,
    this.autoPlay = true,
    this.editMode = false,
    required this.prefferHeight,
    required this.prefferWidth,
    required this.images,
  });
  final bool editMode;
  final bool autoPlay;
  double prefferWidth;
  double prefferHeight;
  final List<String> images;
  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? SizedBox(
          width: prefferWidth,
          height: prefferHeight,
          child: Image.asset(
            'assets/images/ecommerce/placeholder.jpg',
            width: prefferWidth,
            height: prefferHeight,
          ),
        )
        : CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 6 / 8,
            // viewportFraction: 100,
            scrollPhysics: BouncingScrollPhysics(),
            autoPlay: autoPlay,
          ),
          items:
              images
                  .map(
                    (e) => CustomCaChedNetworkImage(
                      width: prefferWidth,
                      height: prefferHeight,
                      url: e,
                      raduis: BorderRadius.circular(15),
                    ),
                  )
                  .toList(),
        );
  }
}
