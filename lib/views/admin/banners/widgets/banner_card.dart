import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/views/admin/banners/controllers/helper_functions.dart';

class BannerCard extends StatelessWidget {
  final BannerModel banner;
  final bool isCompanyBanner;

  const BannerCard({
    super.key,
    required this.banner,
    required this.isCompanyBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: banner.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.error, size: 40),
                  ),
            ),
          ),

          // Status and Scope Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        banner.active
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: banner.active ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        banner.active ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: banner.active ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        banner.active ? 'active'.tr : 'inactive'.tr,
                        style: TextStyle(
                          color: banner.active ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Scope Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCompanyBanner
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompanyBanner ? Colors.blue : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompanyBanner ? Icons.business : Icons.store,
                        size: 14,
                        color: isCompanyBanner ? Colors.blue : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompanyBanner ? 'company'.tr : 'vendor'.tr,
                        style: TextStyle(
                          color: isCompanyBanner ? Colors.blue : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Edit Button
                IconButton(
                  onPressed: () => showEditBannerDialog(context, banner),
                  icon: const Icon(Icons.edit, size: 18),
                  color: Colors.grey.shade600,
                  tooltip: 'edit_banner'.tr,
                ),
              ],
            ),
          ),

          // Banner Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  banner.title ?? 'untitled_banner'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                if (banner.description != null &&
                    banner.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      banner.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    // Toggle Active/Inactive
                    OutlinedButton.icon(
                      onPressed: () => toggleBannerStatus(context, banner),
                      icon: Icon(
                        banner.active ? Icons.visibility_off : Icons.visibility,
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

                    const SizedBox(width: 8),

                    // Change Scope (only for vendor banners)
                    if (!isCompanyBanner)
                      OutlinedButton.icon(
                        onPressed:
                            () => convertToCompanyBanner(context, banner),
                        icon: const Icon(Icons.business, size: 18),
                        label: Text('to_company'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),

                    const SizedBox(width: 8),

                    // Delete Button
                    OutlinedButton.icon(
                      onPressed: () => deleteBanner(context, banner),
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text('delete'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
