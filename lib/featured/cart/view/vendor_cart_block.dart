import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/cart/view/widgets/cart_menu_item.dart';
import 'package:istoreto/featured/cart/view/widgets/cart_summery.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_profile.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';

/// عرض منتجات السلة لتاجر واحد
class VendorCartBlock extends StatelessWidget {
  final String vendorId;
  final List<CartItem> items;

  const VendorCartBlock({
    super.key,
    required this.vendorId,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    print(
      '🎨 Building VendorCartBlock for $vendorId with ${items.length} items',
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات التاجر
            VendorProfilePreview(
              vendorId: vendorId,
              color: Colors.black,
              withunderLink: false,
              withPadding: false,
            ),

            const Divider(height: 24),

            // المنتجات
            ...items.map((item) => CartMenuItem(item: item)).toList(),

            const SizedBox(height: 16),

            // الإجمالي والزر
            // VendorCartBottomBar(vendorId: vendorId, items: items),
          ],
        ),
      ),
    );
  }
}
