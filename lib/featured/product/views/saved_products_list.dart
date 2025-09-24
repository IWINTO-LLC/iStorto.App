// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';

import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_horz.dart';
import 'package:istoreto/utils/common/widgets/anime_empty_logo.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

class SavedProductsPage extends StatelessWidget {
  final controller = SavedController.instance;

  SavedProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Saved Product'),
      body: SafeArea(child: SavedProductContent()),
    );
  }
}

class SavedProductContent extends StatelessWidget {
  const SavedProductContent({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = SavedController.instance;
    return Obx(
      () =>
          controller.savedProducts.isEmpty
              ? const AnimeEmptyLogo()
              : Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 30),
                child: ListView.builder(
                  itemCount: controller.savedProducts.length,
                  itemBuilder: (context, index) {
                    var product = controller.savedProducts[index];

                    // إخفاء العنصر إذا كان محذوفاً
                    if (controller.isDeleted(product.id)) {
                      return const SizedBox.shrink();
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform:
                          controller.isDeleted(product.id)
                              ? Matrix4.translationValues(0, -100, 0)
                              : Matrix4.translationValues(0, 0, 0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: SizedBox(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      pageBuilder:
                                          (
                                            context,
                                            anim1,
                                            anim2,
                                          ) => ProductDetails(
                                            key: UniqueKey(),
                                            selected: index,
                                            spotList: controller.savedProducts,
                                            product:
                                                controller.savedProducts[index],
                                            vendorId:
                                                controller
                                                    .savedProducts[index]
                                                    .vendorId ??
                                                '',
                                          ),
                                    ),
                                  );
                                },
                                child: ProductWidgetHorzental(
                                  product: product,
                                  vendorId: product.vendorId ?? '',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left:
                                TranslationController.instance.isRTL
                                    ? 10
                                    : null,
                            right:
                                TranslationController.instance.isRTL
                                    ? null
                                    : 10,
                            top: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: GestureDetector(
                                  onTap:
                                      () => controller.removeProduct(product),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color:
                                          controller.isDeleting(product.id)
                                              ? Colors.red.withValues(
                                                alpha: 0.8,
                                              )
                                              : TColors.black.withValues(
                                                alpha: .5,
                                              ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child:
                                            controller.isDeleting(product.id)
                                                ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : const Icon(
                                                  key: ValueKey('close'),
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
