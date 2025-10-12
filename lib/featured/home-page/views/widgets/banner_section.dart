import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  final BannerController _bannerController = Get.put(BannerController());
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _startAutoSlide();
  }

  Future<void> _loadBanners() async {
    try {
      await _bannerController.fetchAllBanners();
    } catch (e) {
      print('خطأ في جلب البانرات: $e');
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final companyBanners =
          _bannerController.banners
              .where(
                (banner) =>
                    banner.scope == BannerScope.company && banner.active,
              )
              .toList();

      if (companyBanners.isNotEmpty) {
        if (_currentPage.value < companyBanners.length - 1) {
          _currentPage.value++;
        } else {
          _currentPage.value = 0;
        }
        _pageController.animateToPage(
          _currentPage.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = 95.w;
    double aspectRatio = 0.5882;
    double height = width * aspectRatio;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: height,
      child: Obx(() {
        final companyBanners =
            _bannerController.banners
                .where(
                  (banner) =>
                      banner.scope == BannerScope.company && banner.active,
                )
                .toList();

        if (_bannerController.isLoading.value) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (companyBanners.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'no_banners_available'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _currentPage.value = index;
              },
              itemCount: companyBanners.length,
              itemBuilder: (context, index) {
                return _buildBannerItem(companyBanners[index]);
              },
            ),
            // Page indicators
            if (companyBanners.length > 1)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    companyBanners.length,
                    (index) => Obx(
                      () => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage.value == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage.value == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    double width = 95.w;

    double aspectRatio = 0.5882;
    double height = width * aspectRatio;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: GestureDetector(
        onTap: () {
          // يمكن إضافة التنقل إلى الشاشة المستهدفة هنا
          if (banner.targetScreen.isNotEmpty) {
            // Get.toNamed(banner.targetScreen);
          }
        },

        child: Stack(
          children: [
            Center(
              child: TRoundedContainer(
                radius: BorderRadius.circular(20),
                width: width,
                height: height,
                enableShadow: true,
                showBorder: true,
                backgroundColor: TColors.white,
                child:
                    banner.image.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: banner.image,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Icon(
                                  Icons.campaign,
                                  color: Colors.white,
                                  size: 40,
                                ),
                            errorWidget:
                                (context, url, error) => Icon(
                                  Icons.campaign,
                                  color: Colors.white,
                                  size: 40,
                                ),
                          ),
                        )
                        : Icon(Icons.campaign, color: Colors.white, size: 40),
              ),
            ),
            TRoundedContainer(
              radius: BorderRadius.circular(20),
              width: width,
              height: height,
              enableShadow: true,
              showBorder: true,
              backgroundColor: TColors.black.withValues(alpha: .1),
            ),
            // Background pattern
            // Positioned(
            //   left: -20,
            //   bottom: -20,
            //   child: Container(
            //     width: 80,
            //     height: 80,
            //     decoration: BoxDecoration(
            //       color: Colors.white.withValues(alpha: .1),
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title ?? 'بانر إعلاني',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.description ?? 'عرض خاص',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'انقر للمزيد',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: .9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 100),
                  // Banner Image or Icon
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
