import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorProfilePreview extends StatelessWidget {
  final String vendorId;
  final bool withunderLink;
  final bool withPhoto;
  final bool withPadding;
  final Color color;

  const VendorProfilePreview({
    super.key,
    required this.vendorId,
    this.withunderLink = true,
    this.withPadding = true,
    this.withPhoto = true,
    required this.color,
  });

  static final Map<String, Future<VendorModel>> _vendorCache = {};

  Future<VendorModel> _getVendorProfile(String id) {
    return _vendorCache.putIfAbsent(id, () async {
      final vendor = await VendorRepository.instance.getVendorById(id);
      if (vendor != null) {
        return vendor;
      } else {
        return VendorModel(organizationName: 'Unknown Vendor');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VendorModel>(
      future: _getVendorProfile(vendorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(withPadding ? 10.0 : 0),
            child: Row(
              children: [
                if (withPhoto)
                  TShimmerEffect(
                    width: 30,
                    height: 30,
                    raduis: BorderRadius.circular(300),
                    baseColor: TColors.grey,
                  ),
                if (withPhoto) const SizedBox(width: 12),
                TShimmerEffect(
                  width: 100,
                  height: 20,
                  raduis: BorderRadius.circular(10),
                  baseColor: TColors.grey,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: EdgeInsets.all(withPadding ? 10.0 : 0),
            child: Text(
              "vendor.unknown".tr,
              style: titilliumBold.copyWith(fontSize: 17, color: color),
            ),
          );
        }

        final profile = snapshot.data!;

        final imageUrl = profile.organizationLogo;
        final name = profile.organizationName;

        return GestureDetector(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(withPadding ? 10.0 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                withPhoto
                    ? TRoundedContainer(
                      radius: BorderRadius.circular(300),
                      showBorder: true,
                      width: 30,
                      height: 30,
                      child: FreeCaChedNetworkImage(
                        // width: 30,
                        // height: 30,
                        url: imageUrl,
                        raduis: BorderRadius.circular(300),
                      ),
                    )
                    : const SizedBox.shrink(),
                withPhoto ? const SizedBox(width: 12) : const SizedBox.shrink(),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: titilliumBold.copyWith(
                      fontSize: 17,
                      color: color,
                      decoration:
                          withunderLink ? TextDecoration.underline : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
