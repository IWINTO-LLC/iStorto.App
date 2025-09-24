import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/slider_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/display_image_full.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/image_strings.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class TProductImageSliderDetails extends StatelessWidget {
  const TProductImageSliderDetails({
    super.key,
    required this.product,
    this.prefferHeight,
    this.prefferWidth,
    this.radius,
  });
  final ProductModel product;
  final BorderRadius? radius;
  final double? prefferHeight;
  final double? prefferWidth;
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(SliderController());
    // RxInt selectdindex = 0.obs;

    final images = product.images;

    // final salePrecentage = ProductController.instance
    //     .calculateSalePresentage(product.price, product.salePrice);
    // final s = double.parse(salePrecentage!);
    if (images.length > 1) {
      return Stack(
        children: [
          TRoundedContainer(
            radius: radius ?? BorderRadius.circular(15),
            showBorder: false,
            enableShadow: true,
            child: CarouselSlider(
              options: CarouselOptions(
                enableInfiniteScroll: false,

                onPageChanged:
                    (index, _) => controller.selectdindex.value = index,
                height: prefferHeight ?? 220,

                viewportFraction: 1,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                // enlargeCenterPage: true,
              ),
              items:
                  images
                      .map(
                        (item) => ActionsMethods.customLongMethode(
                          product,
                          context,
                          VendorController.instance.isVendor.value,
                          CachedNetworkImage(
                            imageUrl: item,
                            imageBuilder:
                                (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    boxShadow: TColors.tboxShadow,
                                    borderRadius:
                                        radius ?? BorderRadius.circular(0),
                                    color: TColors.light,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    TShimmerEffect(
                                      raduis:
                                          radius ?? BorderRadius.circular(15),
                                      width: prefferWidth ?? 120,
                                      height: prefferHeight ?? 220,
                                    ),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error, size: 50),
                          ),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NetworkImageFullScreen(item),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          if (images.length > 1)
            Visibility(
              visible: true,
              child: Positioned(
                bottom: 12,
                left: 4,
                right: 4,
                child: SizedBox(
                  height: 4,
                  child: Center(
                    child: ListView.separated(
                      itemCount: images.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder:
                          (_, index) => Obx(
                            () => TRoundedContainer(
                              width:
                                  index == controller.selectdindex.value
                                      ? 8
                                      : 4,
                              radius: BorderRadius.circular(100),
                              enableShadow: true,
                              showBorder: true,
                              //  height: .5,
                              // margin: const EdgeInsets.only(right: 2, left: 2),
                              backgroundColor:
                                  index == controller.selectdindex.value
                                      ? TColors.primary
                                      : TColors.white,
                            ),
                          ),
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(width: TSizes.spaceBtWItems / 3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (images.length == 1) {
      return ActionsMethods.customLongMethode(
        product,
        context,
        false,
        TRoundedContainer(
          width: prefferWidth ?? 120,
          height: prefferHeight ?? 220,
          radius: BorderRadius.circular(0),
          //enableShadow: true,
          showBorder: false,
          child: CustomCaChedNetworkImage(
            width: prefferWidth ?? 120,
            height: prefferHeight ?? 220,
            url: images.first,
            raduis: BorderRadius.circular(0),
          ),
        ),
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NetworkImageFullScreen(images.first),
          ),
        ),
      );
    } else {
      return Image(
        image: const AssetImage(TImages.imagePlaceholder),
        width: prefferWidth ?? 120,
        height: prefferHeight ?? 220,
      );
    }
  }
}
