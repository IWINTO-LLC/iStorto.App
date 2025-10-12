import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/cashed_network_image.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class CategorySquerItem extends StatelessWidget {
  const CategorySquerItem({
    super.key,
    required this.name,
    required this.image,
    required this.onTap,
    this.showStatus = false,
    this.status = 0,
  });
  final String name;
  final bool showStatus;
  final String image;
  final int status;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    // Add null safety checks
    if (name.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 110, // Slightly wider for better text display
      margin: const EdgeInsets.only(bottom: TSizes.paddingSizeEight),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 90, // Slightly larger for better visibility
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  image != ""
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CustomCaChedNetworkImage(
                          url: image,
                          raduis: BorderRadius.circular(25),
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                      )
                      : TRoundedContainer(
                        radius: BorderRadius.circular(25),
                        enableShadow: true,
                        showBorder: true,
                        borderWidth: 3,
                        //admin borderColor: Colors.white,
                        child: Icon(Icons.category),
                      ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtWItems / 2),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Only show status for non-active categories
          if (showStatus && status != 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'active'.tr;
      case 0:
        return "";
      case 2:
        return 'pending'.tr;
      case 3:
        return 'inactive'.tr;
      default:
        return 'unknown'.tr;
    }
  }
}
