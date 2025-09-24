import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorBannerSlider extends StatefulWidget {
  final String vendorId;
  final bool editMode;

  const VendorBannerSlider({
    super.key,
    required this.vendorId,
    this.editMode = false,
  });

  @override
  State<VendorBannerSlider> createState() => _VendorBannerSliderState();
}

class _VendorBannerSliderState extends State<VendorBannerSlider> {
  final controller = BannerController.instance;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      controller.fetchUserBanners(widget.vendorId);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = 85.w;
    double aspectRatio = 0.5882;
    double height = width * aspectRatio;

    return Obx(() {
      if (controller.isloadUserBanner.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final banners = controller.activeBanners;

      if (banners.isNotEmpty) {
        return widget.editMode
            ? _emptySliderWithAddButton(width, height)
            : const SizedBox.shrink();
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: height,
          aspectRatio: aspectRatio,
          viewportFraction: 0.85,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          autoPlay: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
        ),
        items:
            banners.map((banner) {
              return TRoundedContainer(
                width: width,
                height: height,
                radius: BorderRadius.circular(20),
                backgroundColor: Colors.white,
                enableShadow: true,
                showBorder: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomCaChedNetworkImage(
                    width: width,
                    height: height,
                    url: banner.image,
                    raduis: BorderRadius.circular(15),
                  ),
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _emptySliderWithAddButton(double width, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CarouselSlider(
        options: CarouselOptions(
          height: height + 20,
          viewportFraction: 0.85,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
        ),
        items: List.generate(3, (_) {
          return Stack(
            alignment: Alignment.center,
            children: [
              TRoundedContainer(
                width: width,
                height: height,
                radius: BorderRadius.circular(22),
                backgroundColor: TColors.white,
                enableShadow: true,
                showBorder: true,
              ),
              GestureDetector(
                onTap: () => controller.addBanner('gallery', widget.vendorId),
                child: TRoundedContainer(
                  width: 50,
                  height: 50,
                  radius: BorderRadius.circular(300),
                  enableShadow: true,
                  showBorder: true,
                  child: const Icon(CupertinoIcons.add, color: TColors.primary),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
