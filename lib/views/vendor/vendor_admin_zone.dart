import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/view/store_settings_new.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/views/vendor/vendor_banners_page.dart';
import 'package:istoreto/views/vendor/vendor_categories_management_page.dart';
import 'package:istoreto/views/vendor/vendor_products_management_page.dart';

class VendorAdminZone extends StatelessWidget {
  final String vendorId;

  const VendorAdminZone({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'vendor_admin_zone_title'.tr,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey.shade50, // خلفية رمادية فاتحة بسيطة
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section - تصميم مبسط وأنيق
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // أيقونة مركزية
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.store, color: Colors.black, size: 40),
                      ),
                      const SizedBox(height: 20),
                      // النص المركزي
                      Text(
                        'vendor_admin_zone_welcome'.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'vendor_admin_zone_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Management Sections - عنوان مبسط
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'vendor_admin_zone_management_sections'.tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Banners Management
                _buildManagementCard(
                  icon: Icons.campaign,
                  title: 'vendor_admin_zone_banners'.tr,
                  subtitle: 'vendor_admin_zone_banners_desc'.tr,
                  color: Colors.black,
                  onTap:
                      () => Get.to(
                        () => VendorBannersPage(vendorId: vendorId),
                        transition: Transition.circularReveal,
                        duration: const Duration(milliseconds: 900),
                      ),
                ),

                const SizedBox(height: 12),

                // Products Management
                _buildManagementCard(
                  icon: Icons.inventory,
                  title: 'vendor_admin_zone_products'.tr,
                  subtitle: 'vendor_admin_zone_products_desc'.tr,
                  color: Colors.black,
                  onTap:
                      () => Get.to(
                        () => VendorProductsManagementPage(vendorId: vendorId),
                        transition: Transition.cupertino,
                        duration: const Duration(milliseconds: 900),
                      ),
                ),

                const SizedBox(height: 12),

                // Categories Management
                _buildManagementCard(
                  icon: Icons.category,
                  title: 'vendor_admin_zone_categories'.tr,
                  subtitle: 'vendor_admin_zone_categories_desc'.tr,
                  color: Colors.black,
                  onTap:
                      () => Get.to(
                        () =>
                            VendorCategoriesManagementPage(vendorId: vendorId),
                        transition: Transition.cupertino,
                        duration: Duration(microseconds: 900),
                      ),
                ),

                const SizedBox(height: 12),

                // Orders Management
                _buildManagementCard(
                  icon: Icons.shopping_cart,
                  title: 'vendor_admin_zone_orders'.tr,
                  subtitle: 'vendor_admin_zone_orders_desc'.tr,
                  color: Colors.black,
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Orders management will be available soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Store Settings
                _buildManagementCard(
                  icon: Icons.settings,
                  title: 'vendor_admin_zone_store_settings'.tr,
                  subtitle: 'vendor_admin_zone_store_settings_desc'.tr,
                  color: Colors.black,
                  onTap: () {
                    Get.to(
                      () => VendorSettingsPageNew(
                        vendorId: vendorId,
                        fromBage: 'vendor_admin_zone',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Analytics
                _buildManagementCard(
                  icon: Icons.analytics,
                  title: 'vendor_admin_zone_analytics'.tr,
                  subtitle: 'vendor_admin_zone_analytics_desc'.tr,
                  color: Colors.black,
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Analytics will be available soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Customer Reviews
                _buildManagementCard(
                  icon: Icons.star_rate,
                  title: 'vendor_admin_zone_reviews'.tr,
                  subtitle: 'vendor_admin_zone_reviews_desc'.tr,
                  color: Colors.black,
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Customer reviews will be available soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),

                // مساحة إضافية في النهاية
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة محسنة
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 18),
            // المحتوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // سهم التنقل
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade600,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
