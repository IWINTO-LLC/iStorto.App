import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';

import 'expandable_banner.dart';

class CompanyBannersSection extends StatelessWidget {
  const CompanyBannersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BannerController.instance;
    return Obx(() {
      final companyBanners =
          controller.banners
              .where((banner) => banner.scope == BannerScope.company)
              .toList();

      return ExpandableBannerDrawer(
        title: 'company_banners'.tr,
        icon: Icons.business,
        color: Colors.blue,
        bannerCount: companyBanners.length,
        banners: companyBanners,
        isCompanyBanner: true,
      );
    });
  }
}
