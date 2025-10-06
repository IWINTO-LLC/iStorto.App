import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

/// مكون عرض آخر تاجر تم إنشاؤه في بطاقة كبيرة بعرض الشاشة الكامل
/// Component to display the last created vendor in a large full-width card
class TheLastVendorSection extends StatelessWidget {
  const TheLastVendorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // رأس القسم
        _SectionHeader(),
        const SizedBox(height: 16),

        // بطاقة التاجر الأخير
        _LastVendorCard(),
      ],
    );
  }
}

/// رأس قسم آخر تاجر
/// Last vendor section header
class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'latest_vendor'.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _ViewAllVendorsButton(),
        ],
      ),
    );
  }
}

/// زر عرض جميع التجار
/// View all vendors button
class _ViewAllVendorsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAllVendors(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'view_all'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
          ],
        ),
      ),
    );
  }

  /// عرض جميع التجار (يمكن تطويرها للتنقل إلى صفحة منفصلة)
  /// Show all vendors (can be developed to navigate to separate page)
  void _showAllVendors(BuildContext context) {
    // TODO: إضافة navigation إلى صفحة عرض جميع التجار
    Get.snackbar(
      'all_vendors'.tr,
      'all_vendors_will_be_shown'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}

/// بطاقة آخر تاجر
/// Last vendor card
class _LastVendorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // Full width minus padding

    return FutureBuilder(
      future: _fetchLastVendor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _VendorLoadingCard(cardWidth: cardWidth);
        }

        if (snapshot.hasError) {
          return _VendorErrorCard(
            error: snapshot.error.toString(),
            onRetry: () => _refreshCard(context),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _VendorEmptyCard();
        }

        return _VendorCardContent(vendor: snapshot.data!, cardWidth: cardWidth);
      },
    );
  }

  /// جلب آخر تاجر من قاعدة البيانات
  /// Fetch last vendor from database
  Future<dynamic> _fetchLastVendor() async {
    try {
      final vendorRepository = VendorRepository.instance;
      final vendors = await vendorRepository.getAllActiveVendors();

      if (vendors.isNotEmpty) {
        // Return the first vendor (most recently created due to order by created_at desc)
        return vendors.first;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching last vendor: $e');
      }
      throw e;
    }
  }

  /// إعادة تحميل البطاقة
  /// Refresh the card
  void _refreshCard(BuildContext context) {
    // Force rebuild by using a StatefulWidget or GetBuilder
    Get.forceAppUpdate();
  }
}

/// بطاقة تحميل التاجر مع shimmer
/// Vendor loading card with shimmer
class _VendorLoadingCard extends StatelessWidget {
  final double cardWidth;

  const _VendorLoadingCard({required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TShimmerEffect(height: 200, width: cardWidth),
    );
  }
}

/// بطاقة خطأ التاجر
/// Vendor error card
class _VendorErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _VendorErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'error_loading_vendor'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text('retry'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة عدم وجود تجار
/// No vendors card
class _VendorEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'no_vendors_available'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'check_back_later'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

/// محتوى بطاقة التاجر
/// Vendor card content
class _VendorCardContent extends StatelessWidget {
  final dynamic vendor;
  final double cardWidth;

  const _VendorCardContent({required this.vendor, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // صورة البانر أو اللوجو
            _VendorImage(vendor: vendor),

            // معلومات التاجر
            _VendorInfo(vendor: vendor),
          ],
        ),
      ),
    );
  }
}

/// صورة التاجر (بانر أو لوجو)
/// Vendor image (banner or logo)
class _VendorImage extends StatelessWidget {
  final dynamic vendor;

  const _VendorImage({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final bannerImage = vendor.organizationCover ?? '';
    final logoImage = vendor.organizationLogo ?? '';

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Stack(
        children: [
          // صورة البانر أو الخلفية
          if (bannerImage.isNotEmpty)
            Image.network(
              bannerImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _DefaultBannerImage();
              },
            )
          else
            _DefaultBannerImage(),

          // لوجو التاجر في الزاوية
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  logoImage.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          logoImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store,
                              color: Colors.grey,
                              size: 20,
                            );
                          },
                        ),
                      )
                      : const Icon(Icons.store, color: Colors.grey, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// صورة البانر الافتراضية
/// Default banner image
class _DefaultBannerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black87, Colors.black],
        ),
      ),
      child: const Icon(Icons.store, color: Colors.white, size: 40),
    );
  }
}

/// معلومات التاجر
/// Vendor information
class _VendorInfo extends StatelessWidget {
  final dynamic vendor;

  const _VendorInfo({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم التاجر
          Text(
            vendor.organizationName ?? 'unknown_vendor'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // وصف التاجر
          if (vendor.organizationBio != null &&
              vendor.organizationBio.isNotEmpty)
            Text(
              vendor.organizationBio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 12),

          // أزرار التفاعل
          _VendorActions(vendor: vendor),
        ],
      ),
    );
  }
}

/// أزرار تفاعل التاجر
/// Vendor action buttons
class _VendorActions extends StatelessWidget {
  final dynamic vendor;

  const _VendorActions({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // زر زيارة المتجر
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _visitStore(vendor),
            icon: const Icon(Icons.store, size: 16),
            label: Text('visit_store'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // زر المتابعة
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _followVendor(vendor),
            icon: const Icon(Icons.person_add, size: 16),
            label: Text('follow'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// زيارة متجر التاجر
  /// Visit vendor store
  void _visitStore(dynamic vendor) {
    // TODO: إضافة navigation إلى صفحة متجر التاجر
    Get.to(() => MarketPlaceView(editMode: false, vendorId: vendor.id));
  }

  /// متابعة التاجر
  /// Follow vendor
  void _followVendor(dynamic vendor) {
    // TODO: إضافة منطق متابعة التاجر
    Get.snackbar(
      'following_vendor'.tr,
      '${vendor.organizationName ?? 'vendor'.tr} ${'followed_successfully'.tr}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
