import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class AdminBannersPage extends StatefulWidget {
  const AdminBannersPage({super.key});

  @override
  State<AdminBannersPage> createState() => _AdminBannersPageState();
}

class _AdminBannersPageState extends State<AdminBannersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BannerController _bannerController = Get.put(BannerController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    await _bannerController.fetchAllBanners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'banner_management'.tr, centerTitle: true),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: TColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: TColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.business), text: 'company_banners'.tr),
                Tab(icon: Icon(Icons.store), text: 'vendor_banners'.tr),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Company Banners Tab
                _buildCompanyBannersTab(),

                // Vendor Banners Tab
                _buildVendorBannersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBannerDialog(),
        backgroundColor: TColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('add_banner'.tr, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCompanyBannersTab() {
    return Obx(() {
      if (_bannerController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final companyBanners =
          _bannerController.banners
              .where((banner) => banner.scope == BannerScope.company)
              .toList();

      if (companyBanners.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16),
              Text(
                'no_company_banners'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadBanners,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: companyBanners.length,
          itemBuilder: (context, index) {
            final banner = companyBanners[index];
            return _buildBannerCard(banner, isCompanyBanner: true);
          },
        ),
      );
    });
  }

  Widget _buildVendorBannersTab() {
    return Obx(() {
      if (_bannerController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final vendorBanners =
          _bannerController.banners
              .where((banner) => banner.scope == BannerScope.vendor)
              .toList();

      if (vendorBanners.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 80, color: Colors.grey.shade300),
              SizedBox(height: 16),
              Text(
                'no_vendor_banners'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadBanners,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: vendorBanners.length,
          itemBuilder: (context, index) {
            final banner = vendorBanners[index];
            return _buildBannerCard(banner, isCompanyBanner: false);
          },
        ),
      );
    });
  }

  Widget _buildBannerCard(BannerModel banner, {required bool isCompanyBanner}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                CustomCaChedNetworkImage(
                  height: 180,
                  width: 97.w,
                  url: banner.image,
                  raduis: BorderRadius.vertical(top: Radius.circular(16)),
                ),

                // CachedNetworkImage(
                //   imageUrl: banner.image,
                //   height: 180,
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                //   placeholder:
                //       (context, url) => Container(
                //         height: 180,
                //         color: Colors.grey.shade200,
                //         child: Center(child: CircularProgressIndicator()),
                //       ),
                //   errorWidget:
                //       (context, url, error) => Container(
                //         height: 180,
                //         color: Colors.grey.shade300,
                //         child: Icon(Icons.error, size: 40),
                //       ),
                // ),

                // Active Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          banner.active
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      banner.active ? 'active'.tr : 'inactive'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Scope Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isCompanyBanner
                              ? Colors.blue.withOpacity(0.9)
                              : Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompanyBanner ? Icons.business : Icons.store,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          banner.scope.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Banner Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  banner.title ?? 'untitled_banner'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                if (banner.description != null &&
                    banner.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      banner.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                SizedBox(height: 12),

                // Info Row
                Row(
                  children: [
                    Icon(
                      Icons.screen_search_desktop,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      banner.targetScreen,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.trending_up, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'priority'.tr + ': ${banner.priority}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    // Toggle Active/Inactive
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleBannerStatus(banner),
                        icon: Icon(
                          banner.active
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                        label: Text(
                          banner.active ? 'deactivate'.tr : 'activate'.tr,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              banner.active ? Colors.orange : Colors.green,
                          side: BorderSide(
                            color: banner.active ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    // Change Scope (only for vendor banners)
                    if (!isCompanyBanner)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _convertToCompanyBanner(banner),
                          icon: Icon(Icons.business, size: 18),
                          label: Text('to_company'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),

                    SizedBox(width: 8),

                    // Delete Button
                    OutlinedButton.icon(
                      onPressed: () => _deleteBanner(banner),
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('delete'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBannerDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  'add_new_banner'.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                // Gallery Option (First)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: Text(
                    'from_gallery'.tr,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('choose_from_gallery'.tr),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.back();
                    _bannerController.addCompanyBanner('gallery');
                  },
                ),

                SizedBox(height: 8),

                // Camera Option (Second)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.green),
                  ),
                  title: Text(
                    'from_camera'.tr,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('take_new_photo'.tr),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.back();
                    _bannerController.addCompanyBanner('camera');
                  },
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Future<void> _toggleBannerStatus(BannerModel banner) async {
    if (banner.id == null || banner.id!.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Invalid banner ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    final newStatus = !banner.active;

    try {
      await _bannerController.toggleBannerActive(banner.id!, newStatus);
      await _loadBanners();

      Get.snackbar(
        'success'.tr,
        newStatus
            ? 'banner_activated_successfully'.tr
            : 'banner_deactivated_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_update_banner'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _convertToCompanyBanner(BannerModel banner) async {
    if (banner.id == null || banner.id!.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Invalid banner ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_conversion'.tr),
        content: Text('convert_to_company_banner_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('convert'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _bannerController.convertToCompanyBanner(banner);
      await _loadBanners();

      Get.snackbar(
        'success'.tr,
        'banner_converted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_convert_banner'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _deleteBanner(BannerModel banner) async {
    if (banner.id == null || banner.id!.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Invalid banner ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_deletion'.tr),
        content: Text('delete_banner_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _bannerController.deleteBannerAdmin(banner);
      await _loadBanners();

      Get.snackbar(
        'success'.tr,
        'banner_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_banner'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
