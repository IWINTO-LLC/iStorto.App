import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/views/admin/banners/widgets/company_section.dart';
import 'package:istoreto/views/admin/banners/widgets/vendor_section.dart';

class BannersContent extends StatelessWidget {
  const BannersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الصفحة
          Text(
            'banner_management'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'manage_all_banners'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // بنرات الشركة
          CompanyBannersSection(),
          const SizedBox(height: 24),

          // بنرات التجار
          VendorBannersSection(),
        ],
      ),
    );
  }
}
