import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorCardWidget extends StatelessWidget {
  final VendorModel vendor;

  const VendorCardWidget({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => MarketPlaceView(vendorId: vendor.id!, editMode: false),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vendor Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child:
                  vendor.organizationLogo.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          vendor.organizationLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.store,
                              color: TColors.primary,
                              size: 30,
                            );
                          },
                        ),
                      )
                      : Icon(Icons.store, color: TColors.primary, size: 30),
            ),
            const SizedBox(width: 12),

            // Vendor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.organizationName ?? 'Unknown Vendor',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.brief.isNotEmpty
                        ? vendor.brief
                        : 'No description available',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Verification Status
                      if (vendor.isVerified) ...[
                        Icon(Icons.verified, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'verified'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(width: 12),

                      // Store Status
                      Icon(Icons.store, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        vendor.organizationActivated
                            ? 'active'.tr
                            : 'inactive'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              vendor.organizationActivated
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
