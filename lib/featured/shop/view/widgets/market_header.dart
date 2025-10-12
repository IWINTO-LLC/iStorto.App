import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_image_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/view/widgets/market_header_shimmer.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_social_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/views/vendor/vendor_admin_zone.dart';
import 'package:istoreto/views/vendor/vendor_offers_page.dart';
import 'package:istoreto/views/vendor/vendor_product_search_page.dart';
import 'package:istoreto/views/view_personal_info_page.dart';
import 'package:sizer/sizer.dart';

/// A modern vendor header widget that displays vendor information including:
/// - Cover image with gradient overlay
/// - Vendor logo and name with verification badge
/// - Brief description
/// - Statistics (Products, Followers, Posts)
/// - Action buttons (Follow, Share, Manage)
/// - Social media links
///
/// Usage:
/// ```dart
/// MarketHeader(
///   vendorId: 'vendor_id_here',
///   editMode: false, // true for vendor's own page
/// )
/// ```
///
/// Features:
/// - Uses GetX for state management
/// - StatelessWidget for better performance
/// - All icons are black as requested
/// - Responsive design with sizer
/// - Integrated with VendorController for data fetching
class MarketHeader extends StatelessWidget {
  final String vendorId;
  final bool editMode;

  const MarketHeader({
    super.key,
    required this.vendorId,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize VendorController if not already registered
    if (!Get.isRegistered<VendorController>()) {
      Get.put(VendorController());
    }

    // Initialize VendorImageController for edit mode
    if (editMode && !Get.isRegistered<VendorImageController>()) {
      Get.put(VendorImageController());
    }

    return Obx(() {
      if (VendorController.instance.isLoading.value) {
        return const MarketHeaderShimmer();
      }

      final vendor = VendorController.instance.vendorData.value;

      if (vendor == VendorModel.empty()) {
        return Center(
          child: Text('user_profile_top_section.user_not_found'.tr),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header with Cover Image
          SizedBox(
            height: 40.h + 55,
            child: Stack(
              children: [
                // Cover Image Container (Clickable)
                GestureDetector(
                  onTap: () {
                    if (editMode) {
                      // Edit mode: Allow changing the cover
                      if (!Get.isRegistered<VendorImageController>()) {
                        Get.put(VendorImageController());
                      }
                      VendorImageController.instance.editVendorCoverImage(
                        vendorId,
                      );
                    } else {
                      // View mode: Show fullscreen image with zoom
                      if (vendor.organizationCover.isNotEmpty) {
                        Get.to(
                          () => FullscreenImageViewer(
                            images: [vendor.organizationCover],
                            initialIndex: 0,
                            hideControls: true,
                          ),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: 100.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child:
                              vendor.organizationCover.isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl: vendor.organizationCover,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder:
                                        (context, url) => const TShimmerEffect(
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.store,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  )
                                  : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.store,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                        ),

                        // Loading overlay for cover - يظهر أثناء رفع صورة الغلاف
                        if (editMode &&
                            Get.isRegistered<VendorImageController>())
                          Obx(() {
                            final isLoading =
                                VendorImageController.instance.isLoadingCover;

                            if (isLoading) {
                              // Loading indicator overlay with progress percentage
                              final progress =
                                  VendorImageController
                                      .instance
                                      .coverUploadProgress;
                              final percentage = (progress * 100).toInt();

                              return Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                      bottomRight: Radius.circular(24),
                                    ),
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // دائرة التقدم
                                        SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.3),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.white),
                                            strokeWidth: 6,
                                          ),
                                        ),
                                        // النسبة المئوية
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$percentage%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'جاري رفع الغلاف',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Camera badge - زر صغير في الزاوية العلوية اليمنى
                            return SizedBox.shrink();
                            // Positioned(
                            //   bottom: 16,
                            //   right: 16,
                            //   child: Container(
                            //     padding: const EdgeInsets.all(10),
                            //     decoration: BoxDecoration(
                            //       color: Colors.black.withValues(alpha: 0.7),
                            //       shape: BoxShape.circle,
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Colors.black.withValues(alpha: 0.3),
                            //           blurRadius: 8,
                            //           offset: const Offset(0, 2),
                            //         ),
                            //       ],
                            //     ),
                            // child: const Icon(
                            //   Icons.camera_alt,
                            //   color: Colors.red,
                            //   size: 20,
                            // ),
                            // ),
                            //);
                          }),

                        // Camera badge fallback for when controller not registered
                        if (editMode &&
                            !Get.isRegistered<VendorImageController>())
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Gradient Overlay
                // Positioned.fill(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       borderRadius: const BorderRadius.only(
                //         bottomLeft: Radius.circular(24),
                //         bottomRight: Radius.circular(24),
                //       ),
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: [
                //           Colors.transparent,
                //           Colors.black.withValues(alpha: 0.3),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                // Top Action Buttons
                Positioned(
                  top: 30,
                  right: 20,
                  child: Row(
                    children: [
                      // Share Button
                      // ShareVendorButton(vendorId: vendorId),
                      // const SizedBox(width: 12),
                      // Settings Button (for edit mode)
                      if (editMode)
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => VendorAdminZone(vendorId: vendorId),
                              transition: Transition.circularReveal,
                              duration: const Duration(milliseconds: 900),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Left Action Buttons (Profile, Search)
                Positioned(
                  top: 30,
                  left: 20,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            transition: Transition.circularReveal,
                            duration: const Duration(milliseconds: 900),
                            () => VendorProductSearchPage(vendorId: vendorId),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Search icon

                      // Profile icon
                      GestureDetector(
                        onTap:
                            () => Get.to(
                              () => ViewPersonalInfoPage(userId: vendor.userId),
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vendor Logo and Info Section
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        // Vendor Logo (Clickable)
                        GestureDetector(
                          onTap: () {
                            if (editMode) {
                              // Edit mode: Allow changing the logo
                              if (!Get.isRegistered<VendorImageController>()) {
                                Get.put(VendorImageController());
                              }
                              VendorImageController.instance
                                  .editVendorLogoImage(vendorId);
                            } else {
                              // View mode: Show fullscreen image with zoom
                              if (vendor.organizationLogo.isNotEmpty) {
                                Get.to(
                                  () => FullscreenImageViewer(
                                    images: [vendor.organizationLogo],
                                    initialIndex: 0,
                                    hideControls:
                                        true, // إخفاء جميع عناصر التحكم والإبقاء على الزووم فقط
                                  ),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 300),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ClipOval(
                                  child:
                                      vendor.organizationLogo.isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: vendor.organizationLogo,
                                            fit: BoxFit.contain,
                                            placeholder:
                                                (context, url) =>
                                                    const TShimmerEffect(
                                                      width: 120,
                                                      height: 120,
                                                    ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Icon(
                                                        Icons.store,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          )
                                          : Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.store,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),

                                // Camera icon badge - في الزاوية السفلية اليمنى
                                if (editMode &&
                                    Get.isRegistered<VendorImageController>())
                                  Obx(() {
                                    final isLoading =
                                        VendorImageController
                                            .instance
                                            .isLoadingLogo;

                                    if (isLoading) {
                                      // Loading indicator overlay with progress percentage
                                      final progress =
                                          VendorImageController
                                              .instance
                                              .logoUploadProgress;
                                      final percentage =
                                          (progress * 100).toInt();

                                      return Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // دائرة التقدم
                                                SizedBox(
                                                  width: 70,
                                                  height: 70,
                                                  child: CircularProgressIndicator(
                                                    value: progress,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withValues(alpha: 0.3),
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                    strokeWidth: 5,
                                                  ),
                                                ),
                                                // النسبة المئوية
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$percentage%',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'جاري الرفع',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    // Camera badge - زر صغير في الزاوية
                                    return Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,

                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.black,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  }),

                                // Camera badge fallback for when controller not registered
                                if (editMode &&
                                    !Get.isRegistered<VendorImageController>())
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //  const SizedBox(height: 10), // Space for logo
                // Vendor Name and Verification Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        vendor.organizationName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (true) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Brief Description
                if (vendor.organizationBio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      vendor.organizationBio,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 8),

                // Brief Description
                if (vendor.brief.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      vendor.brief,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Stats Row
                Obx(() {
                  final controller = VendorController.instance;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap:
                            () => Get.to(
                              transition: Transition.circularReveal,
                              duration: const Duration(milliseconds: 900),
                              () => VendorProductSearchPage(vendorId: vendorId),
                            ),
                        child: _buildStatCard(
                          icon: Icons.inventory_2,
                          label: 'Products',
                          value: controller.productsCount.value.toString(),
                          color: Colors.black,
                        ),
                      ),
                      _buildStatCard(
                        icon: Icons.people,
                        label: 'Followers',
                        value: controller.followersCount.value.toString(),
                        color: Colors.black,
                      ),
                      GestureDetector(
                        onTap:
                            () => Get.to(
                              transition: Transition.circularReveal,
                              duration: const Duration(milliseconds: 900),
                              () => VendorOffersPage(vendorId: vendorId),
                            ),
                        child: _buildStatCard(
                          icon: Icons.post_add,
                          label: 'Offers',
                          value: controller.offersCount.value.toString(),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: TSizes.spaceBtWsections),

                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!editMode) _buildFollowButton(vendorId),
                    _buildShareButton(vendor),
                    if (editMode) _buildManageButton(vendorId),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Links
                if (vendor.socialLink != null)
                  VendorSocialLinksBar(vendorId: vendorId),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 22.w,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(String vendorId) {
    return Obx(() {
      final controller = VendorController.instance;
      final isFollowing = controller.isFollowing.value;
      final isLoading = controller.isFollowLoading.value;

      return TRoundedContainer(
        width: 120,
        height: 40,
        showBorder: true,
        borderWidth: 1,
        borderColor: isFollowing ? Colors.grey : Colors.black,
        backgroundColor:
            isFollowing ? Colors.grey.shade200 : const Color(0xFFEEEEEE),
        radius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => controller.toggleFollow(vendorId),
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            isFollowing
                                ? Icons.check_circle
                                : CupertinoIcons.add_circled,
                            size: 20,
                            color:
                                isFollowing
                                    ? Colors.blue.shade600
                                    : Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFollowing ? 'following'.tr : 'follow'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  isFollowing
                                      ? Colors.grey.shade600
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShareButton(VendorModel vendor) {
    return TRoundedContainer(
      width: 120,
      height: 40,
      borderWidth: 1,
      radius: BorderRadius.circular(20),
      showBorder: true,
      borderColor: Colors.black,
      backgroundColor: const Color(0xFFEEEEEE),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await ShareServices.shareVendor(vendor);
          },
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text(
                  'Share',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageButton(String vendorId) {
    return TRoundedContainer(
      radius: BorderRadius.circular(100),
      height: 40,
      width: 40,
      showBorder: true,
      borderWidth: 1,
      borderColor: Colors.black,
      backgroundColor: const Color(0xFFEEEEEE),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.to(
                () => VendorAdminZone(vendorId: vendorId),
                transition: Transition.circularReveal,
                duration: const Duration(milliseconds: 900),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.settings, size: 22)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
