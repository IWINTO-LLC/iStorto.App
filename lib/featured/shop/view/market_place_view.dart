import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/view/all_tab.dart';
import 'package:istoreto/featured/shop/view/widgets/market_header_organization.dart';
import 'package:istoreto/featured/shop/view/widgets/market_place_shimmer_widget.dart';

class MarketPlaceView extends GetView<VendorController> {
  const MarketPlaceView({
    super.key,
    required this.editMode,
    required this.vendorId,
  });

  final bool editMode;
  final String vendorId;

  @override
  Widget build(BuildContext context) {
    return NestedScrollViewForHome(vendorId: vendorId, editMode: editMode);
  }
}

class NestedScrollViewForHome extends GetView<VendorController> {
  final bool editMode;
  final String vendorId;

  const NestedScrollViewForHome({
    super.key,
    required this.editMode,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    // جلب بيانات البائع عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchVendorData(vendorId);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? const MarketPlaceShimmerWidget()
                            : SingleChildScrollView(
                              child: Column(
                                children: [
                                  MarketHeaderSection(
                                    userId: vendorId,
                                    editMode: editMode,
                                    isVendor: true,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 28.0),
                                    child: AllTab(
                                      vendorId: vendorId,
                                      editMode: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
