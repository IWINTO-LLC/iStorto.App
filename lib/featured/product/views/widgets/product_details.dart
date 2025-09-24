import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/controllers/auth_controller.dart';

import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/bottom_add_tocart.dart';
import 'package:istoreto/featured/product/views/widgets/one_product_details.dart';

class ProductDetails extends StatelessWidget {
  final ProductModel product;
  final String vendorId;
  final bool isEditable;
  final int selected;
  final List<ProductModel> spotList;

  const ProductDetails({
    super.key,
    required this.product,
    this.isEditable = false,
    required this.spotList,
    this.selected = 0,
    required this.vendorId,
  });
  @override
  Widget build(BuildContext context) {
    bool edit = false;
    if (vendorId == AuthController.instance.currentUser.value?.userId) {
      edit = true;
    }
    final PageController pageController = PageController(initialPage: selected);
    return WillPopScope(
      onWillPop: () async {
        // السماح بالرجوع الطبيعي
        return true;
      },
      child: Scaffold(
        // إضافة دعم إيماءات الرجوع في iOS
        extendBodyBehindAppBar: true,
        bottomNavigationBar: BottomAddToCart(product: product),
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            child:
                spotList.isNotEmpty
                    ? Center(
                      child: SizedBox(
                        height: 100.h,
                        width: 100.w,
                        child: PageView.builder(
                          controller: pageController,
                          // إضافة physics مخصص للسماح بإيماءات الرجوع
                          physics: const ClampingScrollPhysics(),
                          itemCount: spotList.length,
                          itemBuilder: (context, index) {
                            return ProductDetailsPage(
                              product: spotList[index],
                              edit: edit,
                              vendorId: vendorId,
                            );
                          },
                        ),
                      ),
                    )
                    : ProductDetailsPage(
                      product: product,
                      edit: edit,
                      vendorId: vendorId,
                    ),
          ),
        ),
      ),
    );
  }
}
