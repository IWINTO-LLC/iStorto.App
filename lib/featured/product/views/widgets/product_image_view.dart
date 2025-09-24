import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/product/controllers/product_slicer_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/favorite_widget.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/images/custom_image.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class ProductImageView extends StatelessWidget {
  final ProductModel productModel;
  ProductImageView({super.key, required this.productModel});

  var isDark = false;
  List images = [];
  var slideController = Get.put(ProductImageSliderController());
  @override
  Widget build(BuildContext context) {
    var images = productModel.images;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {},
          //  => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
          // ProductImageScreen(title: getTranslated('product_image', context),imageList: images))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.paddingSizeSmall),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: TColors.darkGrey.withOpacity(.25)),
                borderRadius: BorderRadius.circular(TSizes.paddingSizeSmall),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width,
                    child: PageView.builder(
                      controller: slideController.pageController,
                      itemCount: images?.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                            TSizes.paddingSizeSmall,
                          ),
                          child: CustomImage(
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            image: images![index],
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        slideController.setImageSliderSelectedIndex(index);
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _indicators(context),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: TSizes.paddingSizeDefault,
                            left: TSizes.paddingSizeDefault,
                            bottom: TSizes.paddingSizeDefault,
                          ),
                          child: Obx(
                            () => TRoundedContainer(
                              backgroundColor: TColors.black.withValues(
                                alpha: 0.3,
                              ),
                              radius: BorderRadius.circular(50),
                              padding: EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  '${slideController.imageSliderIndex.value + 1}/${images!.length.toString()}',
                                  style: titilliumBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FavouriteButton(product: productModel),
                        const SizedBox(height: TSizes.paddingSizeSmall),
                        const SizedBox(height: TSizes.paddingSizeSmall),
                        InkWell(
                          onTap: () {
                            {
                              // Share.share(
                              //     Provider.of<ProductDetailsProvider>(
                              //             context,
                              //             listen: false)
                              //         .sharableLink!);
                            }
                          },
                          child: TRoundedContainer(
                            backgroundColor: TColors.black.withValues(
                              alpha: 0.3,
                            ),
                            radius: BorderRadius.circular(40),
                            child: Center(
                              child: const Padding(
                                padding: EdgeInsets.all(
                                  TSizes.paddingSizeSmall,
                                ),
                                child: Icon(Icons.share, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left:
                TranslationController.instance.isRTL
                    ? TSizes.homePagePadding
                    : 0,
            right:
                TranslationController.instance.isRTL
                    ? 0
                    : TSizes.homePagePadding,
            bottom: TSizes.paddingSizeLarge,
          ),
          child: SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    slideController.setImageSliderSelectedIndex(index);
                    slideController.pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: TSizes.paddingSizeSmall,
                    ),
                    child: Center(
                      child: Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            // border: Border.all(
                            //   width: index ==
                            //           slideController.imageSliderIndex.value
                            //       ? 2
                            //       : 0,
                            //   color: (index ==
                            //               slideController.imageSliderIndex &&
                            //           isDark
                            //       ? TColors.grey
                            //       : (index ==
                            //                   slideController
                            //                       .imageSliderIndex.value &&
                            //               !isDark)
                            //           ? TColors.black
                            //           : Colors.transparent),
                            // ),
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              TSizes.paddingSizeExtraSmall,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              TSizes.paddingSizeExtraSmall,
                            ),
                            child: CustomImage(
                              height:
                                  index ==
                                          slideController.imageSliderIndex.value
                                      ? 80
                                      : 70,
                              width:
                                  index ==
                                          slideController.imageSliderIndex.value
                                      ? 80
                                      : 70,
                              image: images[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _indicators(BuildContext context) {
    List<Widget> indicators = [];
    for (int index = 0; index < images.length; index++) {
      indicators.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.paddingSizeExtraExtraSmall,
          ),
          child: Obx(
            () => Container(
              width: index == slideController.imageSliderIndex.value ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    index == slideController.imageSliderIndex.value
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
      );
    }
    return indicators;
  }
}
