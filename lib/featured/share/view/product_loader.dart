import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/featured/product/views/widgets/one_product_details.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/navigation_menu.dart';

class ProductLoaderPage extends StatelessWidget {
  final String productId;

  const ProductLoaderPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<ProductModel?>(
          future: ProductRepository.instance.getProductById(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.id == '') {
              // المنتج غير موجود أو تم إرجاع كائن empty
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("❌ لم يتم العثور على المنتج"),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NavigationMenu(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home),
                          label: const Text("العودة إلى الرئيسية"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final product = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    // الذهاب إلى صفحة marketplace باستخدام vendorId من المنتج
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MarketPlaceView(
                              editMode: false,
                              vendorId: product.vendorId!,
                            ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              body: SafeArea(
                child: ProductDetailsPage(
                  product: product,
                  edit: false,
                  vendorId: product.vendorId!,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
