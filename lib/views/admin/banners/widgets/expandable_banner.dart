import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/views/admin/banners/controllers/Expandable_controller.dart';
import 'package:sizer/sizer.dart';

import 'banner_card.dart';

class ExpandableBannerDrawer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int bannerCount;
  final List<BannerModel> banners;
  final bool isCompanyBanner;

  const ExpandableBannerDrawer({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.bannerCount,
    required this.banners,
    required this.isCompanyBanner,
  });

  @override
  Widget build(BuildContext context) {
    final ExpandableController expandableController = Get.put(
      ExpandableController(),
      tag: '${title}_${isCompanyBanner ? 'company' : 'vendor'}',
    );
    final controller = BannerController.instance;

    return Obx(
      () => Container(
        width: 100.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header قابل للنقر
            InkWell(
              onTap: () => expandableController.toggleExpansion(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // أيقونة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),

                    // العنوان وعدد البانرات
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$bannerCount ${'banners'.tr}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // أيقونة التوسيع
                    AnimatedRotation(
                      turns: expandableController.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // المحتوى القابل للتوسيع
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child:
                  expandableController.isExpanded
                      ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child:
                            banners.isEmpty
                                ? _buildEmptyState()
                                : buildBannersList(),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            isCompanyBanner ? Icons.campaign_outlined : Icons.store_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isCompanyBanner ? 'no_company_banners'.tr : 'no_vendor_banners'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'add_first_banner'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget buildBannersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return BannerCard(banner: banner, isCompanyBanner: isCompanyBanner);
      },
    );
  }
}
