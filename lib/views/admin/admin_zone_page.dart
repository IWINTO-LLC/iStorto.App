import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/admin/admin_categories_page.dart';
import 'package:istoreto/views/admin/admin_currencies_page.dart';
import 'package:istoreto/views/admin/admin_banners_page.dart';
import 'package:istoreto/views/test/currency_test_page.dart';
import 'package:istoreto/views/test/product_currency_test_page.dart';
import 'package:istoreto/views/test/banner_test_page.dart';
import 'package:istoreto/views/test/promo_slider_test_page.dart';
import 'package:istoreto/views/test/banner_upload_test_page.dart';
import 'package:istoreto/views/test/banner_debug_page.dart';

class AdminZonePage extends StatelessWidget {
  const AdminZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'admin_zone_title'.tr, centerTitle: true),
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
                        color: Colors.black.withOpacity(0.08),
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
                          color: TColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: TColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // النص المركزي
                      Text(
                        'admin_zone_welcome'.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'admin_zone_subtitle'.tr,
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
                    'admin_zone_management_sections'.tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Categories Management
                _buildManagementCard(
                  icon: Icons.category,
                  title: 'admin_zone_categories'.tr,
                  subtitle: 'admin_zone_categories_desc'.tr,
                  color: Colors.blue,
                  onTap: () => Get.to(() => const AdminCategoriesPage()),
                ),

                const SizedBox(height: 12),

                // Currency Management
                _buildManagementCard(
                  icon: Icons.currency_exchange,
                  title: 'admin_zone_currencies'.tr,
                  subtitle: 'admin_zone_currencies_desc'.tr,
                  color: Colors.amber,
                  onTap: () => Get.to(() => const AdminCurrenciesPage()),
                ),

                const SizedBox(height: 12),

                // Banner Management
                _buildManagementCard(
                  icon: Icons.campaign,
                  title: 'banner_management'.tr,
                  subtitle: 'Manage company and vendor banners',
                  color: Colors.pink,
                  onTap: () => Get.to(() => const AdminBannersPage()),
                ),

                const SizedBox(height: 12),

                // Products Management
                _buildManagementCard(
                  icon: Icons.inventory,
                  title: 'admin_zone_products'.tr,
                  subtitle: 'admin_zone_products_desc'.tr,
                  color: Colors.green,
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Products management will be available soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Users Management
                _buildManagementCard(
                  icon: Icons.people,
                  title: 'admin_zone_users'.tr,
                  subtitle: 'admin_zone_users_desc'.tr,
                  color: Colors.purple,
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Users management will be available soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Orders Management
                _buildManagementCard(
                  icon: Icons.shopping_cart,
                  title: 'admin_zone_orders'.tr,
                  subtitle: 'admin_zone_orders_desc'.tr,
                  color: Colors.orange,
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

                // Analytics
                _buildManagementCard(
                  icon: Icons.analytics,
                  title: 'admin_zone_analytics'.tr,
                  subtitle: 'admin_zone_analytics_desc'.tr,
                  color: Colors.red,
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

                // Settings
                _buildManagementCard(
                  icon: Icons.settings,
                  title: 'admin_zone_settings'.tr,
                  subtitle: 'admin_zone_settings_desc'.tr,
                  color: Colors.grey,
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Settings will be available soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Currency Test (Development)
                _buildManagementCard(
                  icon: Icons.science,
                  title: 'Currency Controller Test',
                  subtitle: 'Test currency conversion and functionality',
                  color: Colors.purple,
                  onTap: () => Get.to(() => const CurrencyTestPage()),
                ),

                const SizedBox(height: 12),

                // Product Currency Test (Development)
                _buildManagementCard(
                  icon: Icons.shopping_bag,
                  title: 'Product Currency Test',
                  subtitle: 'Test product price conversion with currencies',
                  color: Colors.orange,
                  onTap: () => Get.to(() => const ProductCurrencyTestPage()),
                ),

                const SizedBox(height: 12),

                // Banner Test (Development)
                _buildManagementCard(
                  icon: Icons.campaign,
                  title: 'Banner Test',
                  subtitle: 'Test banner functionality with vendorId',
                  color: Colors.teal,
                  onTap: () => Get.to(() => const BannerTestPage()),
                ),

                const SizedBox(height: 12),

                // Promo Slider Test (Development)
                _buildManagementCard(
                  icon: Icons.slideshow,
                  title: 'Promo Slider Test',
                  subtitle: 'Test promo slider with vendor banners',
                  color: Colors.indigo,
                  onTap: () => Get.to(() => const PromoSliderTestPage()),
                ),

                const SizedBox(height: 12),

                // Banner Upload Test (Development)
                _buildManagementCard(
                  icon: Icons.cloud_upload,
                  title: 'Banner Upload Test',
                  subtitle: 'Test Supabase upload with progress tracking',
                  color: Colors.purple,
                  onTap: () => Get.to(() => const BannerUploadTestPage()),
                ),

                const SizedBox(height: 12),

                // Banner Debug Page (Development)
                _buildManagementCard(
                  icon: Icons.bug_report,
                  title: 'Banner Debug',
                  subtitle: 'Debug banner loading and RLS policies',
                  color: Colors.red,
                  onTap: () => Get.to(() => const BannerDebugPage()),
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
              color: Colors.black.withOpacity(0.06),
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
                color: color.withOpacity(0.12),
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
