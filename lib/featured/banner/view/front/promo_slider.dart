import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:sizer/sizer.dart';

import 'package:istoreto/featured/banner/controller/banner_controller.dart';
// import replaced with new vendor banners page
import 'package:istoreto/views/vendor/vendor_banners_page.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/display_image_full.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/vendor/add_vendor_banner_page.dart';

class TPromoSlider extends StatelessWidget {
  const TPromoSlider({
    super.key,
    this.autoPlay = true,
    this.editMode = false,
    required this.vendorId,
  });

  final bool editMode;
  final bool autoPlay;
  final String vendorId;

  @override
  Widget build(BuildContext context) {
    double width = 85.w;
    double aspectRatio = 0.5882;
    double height = width * aspectRatio;

    final controller = BannerController.instance;

    // جلب البانرات الخاصة بالتاجر بغض النظر عن scope
    controller.fetchUserBanners(vendorId);

    return Obx(() {
      // تصفية البانرات لتظهر فقط بانرات التاجر المحدد
      final vendorBanners =
          controller.activeBanners
              .where((banner) => banner.vendorId == vendorId)
              .toList();

      if (vendorBanners.isEmpty) {
        return editMode
            ? _buildEmptyState(width, height, aspectRatio)
            : const SizedBox.shrink();
      }

      return _buildBannerSlider(
        width,
        height,
        aspectRatio,
        controller,
        context,
        vendorBanners,
      );
    });
  }

  // حالة فارغة - لا توجد بانرات
  Widget _buildEmptyState(double width, double height, double aspectRatio) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 10.0),
      child: CarouselSlider(
        carouselController: CarouselSliderController(),
        options: CarouselOptions(
          enableInfiniteScroll: false,
          aspectRatio: aspectRatio,
          height: height + 20,
          viewportFraction: 0.85,
          enlargeCenterPage: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
          autoPlay: true,
        ),
        items: List.generate(3, (index) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: TRoundedContainer(
                  width: width,
                  height: height,
                  enableShadow: true,
                  showBorder: true,
                  backgroundColor: TColors.white,
                  radius: BorderRadius.circular(22),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () => _navigateToAddBanner(),
                  child: TRoundedContainer(
                    enableShadow: true,
                    showBorder: true,
                    width: 50,
                    height: 50,
                    radius: BorderRadius.circular(300),
                    child: const Icon(
                      CupertinoIcons.add,
                      color: TColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // عرض السلايدر مع البانرات
  Widget _buildBannerSlider(
    double width,
    double height,
    double aspectRatio,
    BannerController controller,
    BuildContext context,
    List<dynamic> vendorBanners,
  ) {
    List<Widget> items =
        vendorBanners.map((banner) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: [
                // الصورة
                TRoundedContainer(
                  showBorder: true,
                  radius: BorderRadius.circular(15),
                  child: GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    NetworkImageFullScreen(banner.image),
                          ),
                        ),
                    child: CustomCaChedNetworkImage(
                      width: width,
                      height: height,
                      url: banner.image,
                      raduis: BorderRadius.circular(15),
                    ),
                  ),
                ),

                // العنوان فوق الصورة
                if (banner.title != null && banner.title!.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          children: [
                            Text(
                              banner.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList();

    // إضافة أزرار الإضافة إذا كان في وضع التحرير
    if (editMode) {
      if (vendorBanners.length == 1) {
        items.add(_buildAddButton(width, height));
        items.add(_buildAddButton(width, height));
      } else if (vendorBanners.length == 2) {
        items.add(_buildAddButton(width, height));
      }
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: aspectRatio,
            height: height + 20,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            scrollPhysics: const BouncingScrollPhysics(),
            autoPlay: items.length > 1 && autoPlay,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
          ),
          items: items,
        ),

        // مؤشرات النقاط أسفل السلايدر بعدد البانرات
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                vendorBanners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width:
                      controller.carousalCurrentIndex.value == index ? 10 : 6,
                  height:
                      controller.carousalCurrentIndex.value == index ? 10 : 6,
                  decoration: BoxDecoration(
                    color:
                        controller.carousalCurrentIndex.value == index
                            ? TColors.primary
                            : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),

        // زر الإعدادات في وضع التحرير
        if (editMode)
          Positioned(
            bottom: 15,
            right: TranslationController.instance.isRTL ? null : 7,
            left: TranslationController.instance.isRTL ? 7 : null,
            child: CustomFloatActionButton(
              onTap:
                  () => Get.to(
                    () => VendorBannersPage(vendorId: vendorId),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  ),
              icon: Icons.settings,
            ),
          ),
      ],
    );
  }

  // زر الإضافة
  Widget _buildAddButton(double width, double height) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TRoundedContainer(
        showBorder: true,
        width: width,
        height: height,
        enableShadow: true,
        radius: BorderRadius.circular(15),
        child: Center(
          child: InkWell(
            onTap: () => _navigateToAddBanner(),
            child: TRoundedContainer(
              enableShadow: true,
              width: 50,
              height: 50,
              radius: BorderRadius.circular(300),
              child: const Icon(CupertinoIcons.add, color: TColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  // الانتقال إلى صفحة إضافة بانر جديدة
  void _navigateToAddBanner() {
    Get.to(
      () => AddVendorBannerPage(vendorId: vendorId),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }
}
