import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/home-page/views/widgets/small-widgets/view_all.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/helpers/rtl_helper.dart';

class TopSellerSections extends StatefulWidget {
  const TopSellerSections({super.key});

  @override
  State<TopSellerSections> createState() => _TopSellerSectionsState();
}

class _TopSellerSectionsState extends State<TopSellerSections> {
  final VendorRepository _vendorRepository = VendorRepository.instance;
  final RxList<VendorModel> _topVendors = <VendorModel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadTopVendors();
  }

  Future<void> _loadTopVendors() async {
    try {
      _isLoading.value = true;
      final vendors = await _vendorRepository.getAllActiveVendors();
      // أخذ أول 5 بائعين كأفضل البائعين
      _topVendors.value = vendors.take(5).toList();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Error loading vendors: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'top_sellers'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ViewAll(onTap: () {}),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_isLoading.value) {
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          }

          if (_topVendors.isEmpty) {
            return Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'no_vendors_available'.tr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            );
          }

          return SizedBox(
            height: 120,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(width: TSizes.spaceBtWItems);
              },
              scrollDirection: Axis.horizontal,
              // padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _topVendors.length,
              itemBuilder: (context, index) {
                final vendor = _topVendors[index];

                return Padding(
                  padding: RTLHelper.getHorizontalListPadding(
                    index: index,
                    totalItems: _topVendors.length,
                    context: context,
                  ),
                  child: _buildVendorCard(context, vendor),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVendorCard(BuildContext context, VendorModel vendor) {
    return GestureDetector(
      onTap: () {
        if (vendor.id != null) {
          Get.to(() => MarketPlaceView(vendorId: vendor.id!, editMode: false));
        }
      },
      child: TRoundedContainer(
        width: 200,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(12),
        enableShadow: true,
        showBorder: true,
        borderColor: Colors.grey.shade200,
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withValues(alpha: 0.05),
        //       blurRadius: 10,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child:
                  vendor.organizationLogo.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          vendor.organizationLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.store,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.store,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vendor.organizationName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendor.organizationBio.isNotEmpty
                        ? vendor.organizationBio
                        : 'vendor_description'.tr,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      if (vendor.isVerified)
                        _buildTag('verified'.tr, Colors.green),
                      if (vendor.isRoyal) _buildTag('royal'.tr, Colors.amber),
                      _buildTag('active'.tr, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
