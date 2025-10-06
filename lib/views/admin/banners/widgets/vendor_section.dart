import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';

import 'expandable_banner.dart';

class VendorBannersSection extends StatelessWidget {
  const VendorBannersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BannerController.instance;
    return Obx(() {
      final vendorBanners =
          controller.banners
              .where((banner) => banner.scope == BannerScope.vendor)
              .toList();

      return ExpandableBannerDrawer(
        title: 'vendor_banners'.tr,
        icon: Icons.store,
        color: Colors.orange,
        bannerCount: vendorBanners.length,
        banners: vendorBanners,
        isCompanyBanner: false,
      );
    });
  }
}
