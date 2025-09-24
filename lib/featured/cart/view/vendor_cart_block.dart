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
    return cartColumn(
      context,
      vendorId,
      items,
    ); // نفس واجهة عرض البائع ومنتجاته
  }

  Widget cartColumn(
    BuildContext context,
    String vendorId,
    List<CartItem> items,
  ) {
    final cartController = CartController.instance;
    final selectedItems = cartController.selectedItems;

    final allZero = items.every((item) {
      final quantity =
          cartController.productQuantities[item.product.id]?.value ?? 0;
      return quantity == 0;
    });

    // المنتجات المختارة لهذا التاجر فقط
    final selectedForVendor =
        items.where((item) => selectedItems[item.product.id] == true).toList();

    final total = selectedForVendor.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: allZero ? 0 : 1,
        child:
            allZero
                ? const SizedBox.shrink()
                : Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VendorProfilePreview(
                          vendorId: vendorId,
                          color: Colors.black,
                          withunderLink: false,
                        ),
                        const SizedBox(height: 8),
                        ...items.map((item) => CartMenuItem(item: item)),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: TCustomWidgets.formattedPrice(
                                total,
                                19,
                                TColors.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedForVendor.isEmpty
                                          ? Colors.grey
                                          : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),
                                onPressed:
                                    selectedForVendor.isEmpty
                                        ? null
                                        : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      VendorSummaryScreen(
                                                        vendorId: vendorId,
                                                      ),
                                            ),
                                          );
                                        },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 2.0,
                                    left: 4,
                                    right: 4,
                                  ),
                                  child: Text(
                                    "cart.order".tr,
                                    style: titilliumBold.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TCustomWidgets.buildDivider(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
