import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/featured/product/views/all_products_view.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_image_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/follow/screens/followers_details.dart';
import 'package:istoreto/featured/shop/follow/screens/widgets/follow_heart.dart';
import 'package:istoreto/featured/shop/view/market_place_managment.dart';
import 'package:istoreto/featured/shop/view/widgets/share_vendor_widget.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_social_bar.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/display_image_full.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';
import 'package:istoreto/views/vendor/vendor_admin_zone.dart';
import 'package:sizer/sizer.dart';

class MarketHeaderSection extends StatefulWidget {
  final String userId;
  final bool editMode;

  const MarketHeaderSection({
    super.key,
    required this.userId,
    required this.editMode,
  });

  @override
  State<MarketHeaderSection> createState() => _MarketHeaderSectionState();
}

class _MarketHeaderSectionState extends State<MarketHeaderSection> {
  bool fetchingExclusive = false;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    // Initialize VendorImageController if not already initialized
    if (!Get.isRegistered<VendorImageController>()) {
      Get.put(VendorImageController());
    }

    // Fetch vendor data
    await VendorController.instance.fetchVendorData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (VendorController.instance.isLoading.value) {
        return TLoaderWidget();
      }

      if (VendorController.instance.vendorData.value == VendorModel.empty()) {
        // Handle no data state
        return Center(
          child: Text('user_profile_top_section.user_not_found'.tr),
        );
      }

      final userMap = VendorController.instance.vendorData.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header with Cover Image
          Stack(
            children: [
              // Cover Image Container
              Container(
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.editMode) {
                      } else {
                        Get.to(
                          () =>
                              NetworkImageFullScreen(userMap.organizationCover),
                        );
                      }
                    },
                    child:
                        userMap.organizationCover == 'loading'
                            ? TShimmerEffect(
                              baseColor: TColors.lightgrey,
                              width: 100.w,
                              height: 40.h,
                            )
                            : userMap.organizationCover.isEmpty
                            ? Container(
                              width: 100.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    TColors.primary.withValues(alpha: 0.8),
                                    TColors.primary.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.store,
                                  size: 80,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            )
                            : Obx(() {
                              // Check if cover image is being updated
                              final vendorImageController =
                                  Get.find<VendorImageController>();
                              final isLoadingCover =
                                  vendorImageController.isLoading;

                              if (isLoadingCover) {
                                return TShimmerEffect(
                                  width: 100.w,
                                  height: 40.h,
                                  baseColor: TColors.lightgrey,
                                );
                              }

                              return CachedNetworkImage(
                                imageUrl: userMap.organizationCover,
                                imageBuilder:
                                    (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                placeholder:
                                    (context, url) => TShimmerEffect(
                                      width: 100.w,
                                      height: 40.h,
                                      baseColor: TColors.lightgrey,
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      width: 100.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            TColors.primary.withValues(
                                              alpha: 0.8,
                                            ),
                                            TColors.primary.withValues(
                                              alpha: 0.6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.store,
                                          size: 80,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ),
                              );
                            }),
                  ),
                ),
              ),

              // Gradient Overlay for better text readability
              Container(
                width: 100.w,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),

              // Top Action Buttons
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Share Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ShareVendorButton(
                        size: 25,
                        vendorId: widget.userId,
                      ),
                    ),

                    // Settings Button (Edit Mode)
                    if (widget.editMode)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: GestureDetector(
                          onTap:
                              () => Get.to(
                                () => VendorAdminZone(vendorId: widget.userId),
                              ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Vendor Logo and Info Section
              Positioned(
                bottom: -60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Vendor Logo
                    Container(
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
                      child: ClipOval(
                        child:
                            userMap.organizationLogo == 'loading'
                                ? TShimmerEffect(
                                  width: 120,
                                  height: 120,
                                  baseColor: TColors.lightgrey,
                                  raduis: BorderRadius.circular(60),
                                )
                                : Obx(() {
                                  final vendorImageController =
                                      Get.find<VendorImageController>();
                                  final isLoadingLogo =
                                      vendorImageController.isLoading;

                                  if (isLoadingLogo) {
                                    return TShimmerEffect(
                                      width: 120,
                                      height: 120,
                                      baseColor: TColors.lightgrey,
                                      raduis: BorderRadius.circular(60),
                                    );
                                  }

                                  return CachedNetworkImage(
                                    imageUrl: userMap.organizationLogo,
                                    width: 120,
                                    height: 120,
                                    fit:
                                        BoxFit
                                            .contain, // Changed from cover to contain
                                    placeholder:
                                        (context, url) => TShimmerEffect(
                                          width: 120,
                                          height: 120,
                                          baseColor: TColors.lightgrey,
                                          raduis: BorderRadius.circular(60),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: TColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.store,
                                            size: 60,
                                            color: TColors.primary,
                                          ),
                                        ),
                                  );
                                }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content Section
          Container(
            margin: const EdgeInsets.only(top: 100),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor Name and Verification Badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final orgName = userMap.organizationName;
                            return TranslateController
                                    .instance
                                    .enableTranslateProductDetails
                                    .value
                                ? FutureBuilder<String>(
                                  future: TranslateController.instance
                                      .getTranslatedText(
                                        text: orgName,
                                        targetLangCode:
                                            Localizations.localeOf(
                                              Get.context!,
                                            ).languageCode,
                                      ),
                                  builder: (context, snapshot) {
                                    final displayText =
                                        snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData
                                            ? snapshot.data!
                                            : orgName;
                                    return Text(
                                      displayText,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    );
                                  },
                                )
                                : Text(
                                  orgName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                          }),
                          const SizedBox(height: 8),

                          // Brief Description
                          if (userMap.brief.isNotEmpty)
                            Obx(() {
                              final brief = userMap.brief;
                              return TranslateController
                                      .instance
                                      .enableTranslateProductDetails
                                      .value
                                  ? FutureBuilder<String>(
                                    future: TranslateController.instance
                                        .getTranslatedText(
                                          text: brief,
                                          targetLangCode:
                                              Localizations.localeOf(
                                                Get.context!,
                                              ).languageCode,
                                        ),
                                    builder: (context, snapshot) {
                                      final displayText =
                                          snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData
                                              ? snapshot.data!
                                              : brief;
                                      return Text(
                                        displayText,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      );
                                    },
                                  )
                                  : Text(
                                    brief,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  );
                            }),

                          // Organization Bio (detailed description)
                          if (userMap.organizationBio.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Obx(() {
                                final bio = userMap.organizationBio;
                                return TranslateController
                                        .instance
                                        .enableTranslateProductDetails
                                        .value
                                    ? FutureBuilder<String>(
                                      future: TranslateController.instance
                                          .getTranslatedText(
                                            text: bio,
                                            targetLangCode:
                                                Localizations.localeOf(
                                                  Get.context!,
                                                ).languageCode,
                                          ),
                                      builder: (context, snapshot) {
                                        final displayText =
                                            snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    snapshot.hasData
                                                ? snapshot.data!
                                                : bio;
                                        return Text(
                                          displayText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            height: 1.5,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    )
                                    : Text(
                                      bio,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        height: 1.5,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    );
                              }),
                            ),
                        ],
                      ),
                    ),

                    // Verification Badge
                    if (userMap.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    // Products Count
                    Expanded(
                      child: _buildStatCard(
                        icon: CupertinoIcons.bag_fill,
                        value:
                            CategoryController.instance.productCount.value
                                .toString(),
                        label: 'Products',
                        onTap: () {
                          if (CategoryController.instance.productCount.value >
                              0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AllProductViewClient(
                                      vendorId: widget.userId,
                                    ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Followers Count
                    Expanded(
                      child: _buildStatCard(
                        icon: CupertinoIcons.heart_fill,
                        value: '0', // You can add actual followers count here
                        label: 'Followers',
                        onTap: () {
                          Navigator.push(
                            Get.context!,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      FollowersScreen(vendorId: widget.userId),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Posts Count (placeholder)
                    Expanded(
                      child: _buildStatCard(
                        icon: CupertinoIcons.doc_text_fill,
                        value: '0',
                        label: 'Posts',
                        onTap: () {
                          // Navigate to posts if needed
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons Row
                Row(
                  children: [
                    // Follow Button (for customers only)
                    if (!widget.editMode &&
                        !VendorController.instance.isVendor.value)
                      Expanded(child: _buildFollowButton()),

                    // Share Button
                    Expanded(child: _buildShareButton()),

                    // Manage Button (for vendor only)
                    if (widget.editMode ||
                        VendorController.instance.isVendor.value)
                      Expanded(child: _buildManageButton()),
                  ],
                ),

                const SizedBox(height: 20),

                // Social Links (under Share button)
                VendorSocialLinksBar(vendorId: widget.userId, iconSize: 25),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    });
  }

  // Helper method to build stat cards
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.black),
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
      ),
    );
  }

  // Helper method to build follow button
  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: () {
        // Follow/Unfollow logic
        final userMap = VendorController.instance.vendorData.value;
        FollowHeart(
          myId: AuthController.instance.currentUser.value!.id,
          orgId: userMap.id ?? '',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Column(
          children: [
            Icon(CupertinoIcons.heart_fill, size: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Follow',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build share button
  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        // Share vendor profile logic
        Get.snackbar(
          'Share',
          'Sharing vendor profile...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: TColors.primary,
          colorText: Colors.white,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Column(
          children: [
            Icon(CupertinoIcons.share, size: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Share',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build manage button (for vendors only)
  Widget _buildManageButton() {
    return GestureDetector(
      onTap: () => Get.to(() => VendorAdminZone(vendorId: widget.userId)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Column(
          children: [
            Icon(Icons.settings, size: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Manage',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

GestureDetector editName(BuildContext context, Map<String, dynamic>? userMap) {
  return GestureDetector(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: TRoundedContainer(
        width: 28,
        height: 28,
        //showBorder: true,
        enableShadow: true,
        radius: BorderRadius.circular(300),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.edit, size: 18),
        ),
      ),
    ),
  );
}

GestureDetector editBriefIcon(
  BuildContext context,
  Map<String, dynamic>? userMap,
) {
  return GestureDetector(
    onTap: () => editBrief(context, userMap),
    child: TRoundedContainer(
      width: 28,
      height: 28,
      //showBorder: true,
      enableShadow: true,
      radius: BorderRadius.circular(300),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.edit, size: 18),
      ),
    ),
  );
}

editBrief(BuildContext context, Map<String, dynamic>? userMap) {}

Widget itemCount(String userId, BuildContext context) {
  // var isVendorAction= CategoryController.instance.productCount.value ==0  &&   !VendorController.instance.isVendor.value
  return GestureDetector(
    onTap: () {
      if (CategoryController.instance.productCount.value > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllProductViewClient(vendorId: userId),
          ),
        );

        // &&   !VendorController.instance.isVendor.value){
      } else if (VendorController.instance.isVendor.value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MarketPlaceManagment(vendorId: userId, editMode: true),
          ),
        );
      } else {}
    },
    child: Obx(
      () =>
          CategoryController.instance.productCount.value == 0 &&
                  !VendorController.instance.isVendor.value
              ? const SizedBox.shrink()
              : TRoundedContainer(
                enableShadow: true,
                showBorder: true,
                borderColor: Colors.white,
                borderWidth: 2.5,
                backgroundColor: TColors.grey,
                radius: BorderRadius.circular(100),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 12,
                      top: 1,
                      bottom: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.bag_fill,
                          color: TColors.titleColor.withValues(alpha: .5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Obx(
                            () => Text(
                              CategoryController.instance.productCount
                                  .toString(),
                              style: titilliumBold.copyWith(
                                fontFamily: numberFonts,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: TColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    ),
  );
}
