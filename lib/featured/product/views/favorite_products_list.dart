// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/bottom_add_tocart.dart';
import 'package:istoreto/featured/product/views/widgets/one_product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_image_slider_mini.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_horz.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/featured/shop/follow/screens/favorite_vendors.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class FavoriteProductsPage extends StatelessWidget {
  const FavoriteProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoriteProductsController controller =
        Get.find<FavoriteProductsController>();

    return SafeArea(
      child: Column(
        children: [
          // AppBar Content
          _AppBarContent(),

          // Body Content
          Expanded(
            child: Obx(() {
              final filteredProducts = controller.filteredProducts;

              return filteredProducts.isEmpty
                  ? _EmptyState(searchQuery: controller.searchQuery.value)
                  : _MainContent(filteredProducts: filteredProducts);
            }),
          ),
        ],
      ),
    );
  }
}

class _AppBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FavoriteProductsController controller =
        Get.find<FavoriteProductsController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              TranslationController.instance.isRTL
                  ? Icons.arrow_back
                  : Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),

          // Title or Search Field
          Expanded(
            child: Obx(
              () =>
                  controller.isSearchExpanded.value
                      ? TextField(
                        controller: controller.searchController,
                        focusNode: controller.searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'search_in_favorites'.tr,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      )
                      : Center(
                        child: Text(
                          'favorite_products'.tr,
                          style: titilliumBold.copyWith(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
            ),
          ),

          // Search Toggle Button
          IconButton(
            onPressed: controller.toggleSearch,
            icon: Obx(
              () => Icon(
                controller.isSearchExpanded.value
                    ? Icons.close
                    : CupertinoIcons.search,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),

          // View Mode Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'list_view':
                  controller.viewMode.value = 0;
                  break;
                case 'grid_4':
                  controller.viewMode.value = 1;
                  break;
                case 'grid_2':
                  controller.viewMode.value = 2;
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'list_view',
                  child: Obx(
                    () => Row(
                      children: [
                        Icon(
                          controller.viewMode.value == 0
                              ? Icons.check
                              : Icons.view_list,
                          size: 20,
                          color:
                              controller.viewMode.value == 0
                                  ? Colors.green
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'list_view'.tr,
                          style: TextStyle(
                            color:
                                controller.viewMode.value == 0
                                    ? Colors.green
                                    : null,
                            fontWeight:
                                controller.viewMode.value == 0
                                    ? FontWeight.bold
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'grid_4',
                  child: Obx(
                    () => Row(
                      children: [
                        Icon(
                          controller.viewMode.value == 1
                              ? Icons.check
                              : Icons.grid_view,
                          size: 20,
                          color:
                              controller.viewMode.value == 1
                                  ? Colors.green
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'grid_4_items'.tr,
                          style: TextStyle(
                            color:
                                controller.viewMode.value == 1
                                    ? Colors.green
                                    : null,
                            fontWeight:
                                controller.viewMode.value == 1
                                    ? FontWeight.bold
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'grid_2',
                  child: Obx(
                    () => Row(
                      children: [
                        Icon(
                          controller.viewMode.value == 2
                              ? Icons.check
                              : Icons.grid_view,
                          size: 20,
                          color:
                              controller.viewMode.value == 2
                                  ? Colors.green
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'grid_2_items'.tr,
                          style: TextStyle(
                            color:
                                controller.viewMode.value == 2
                                    ? Colors.green
                                    : null,
                            fontWeight:
                                controller.viewMode.value == 2
                                    ? FontWeight.bold
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String searchQuery;

  const _EmptyState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/liquid_loading.gif',
            width: 70.w,
            height: 70.w,
          ),
          Text(
            searchQuery.isNotEmpty ? "no_search_results".tr : "no_items_yet".tr,
            style: titilliumBold.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _MainContent({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    final FavoriteProductsController controller =
        Get.find<FavoriteProductsController>();

    return Obx(() {
      switch (controller.viewMode.value) {
        case 0:
          return _ListViewWithVendors(filteredProducts: filteredProducts);
        case 1:
          return _GridView4WithVendors(filteredProducts: filteredProducts);
        case 2:
          return _GridView2WithVendors(filteredProducts: filteredProducts);
        default:
          return _ListViewWithVendors(filteredProducts: filteredProducts);
      }
    });
  }
}

class _ListViewWithVendors extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _ListViewWithVendors({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ProductView(filteredProducts: filteredProducts),
          _FavoriteVendorsSection(),
        ],
      ),
    );
  }
}

class _GridView4WithVendors extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _GridView4WithVendors({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ProductView(filteredProducts: filteredProducts),
          _FavoriteVendorsSection(),
        ],
      ),
    );
  }
}

class _GridView2WithVendors extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _GridView2WithVendors({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ProductView(filteredProducts: filteredProducts),
          _FavoriteVendorsSection(),
        ],
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _ProductView({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    final FavoriteProductsController controller =
        Get.find<FavoriteProductsController>();

    return Obx(() {
      switch (controller.viewMode.value) {
        case 0:
          return _ListView(filteredProducts: filteredProducts);
        case 1:
          return _GridView4(filteredProducts: filteredProducts);
        case 2:
          return _GridView2(filteredProducts: filteredProducts);
        default:
          return _ListView(filteredProducts: filteredProducts);
      }
    });
  }
}

class _ListView extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _ListView({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...filteredProducts
            .map(
              (product) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ActionsMethods.customLongMethode(
                  product,
                  context,
                  VendorController.instance.isVendor.value,
                  ProductWidgetHorzental(
                    product: product,
                    vendorId: product.vendorId ?? '',
                  ),
                  () => Get.to(
                    () => Scaffold(
                      bottomSheet: BottomAddToCart(product: product),
                      body: SafeArea(
                        child: ProductDetailsPage(
                          product: product,
                          edit: false,
                          vendorId: product.vendorId ?? '',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            ,
      ],
    );
  }
}

class _GridView4 extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _GridView4({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ActionsMethods.customLongMethode(
          filteredProducts[index],
          context,
          VendorController.instance.isVendor.value,
          _buildGridItem(filteredProducts[index]),
          () => Get.to(
            () => Scaffold(
              bottomSheet: BottomAddToCart(product: filteredProducts[index]),
              body: SafeArea(
                child: ProductDetailsPage(
                  product: filteredProducts[index],
                  edit: false,
                  vendorId: filteredProducts[index].vendorId ?? '',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: TProductImageSliderMini(
              editMode: false,
              product: product,
              enableShadow: true,
              radius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              prefferHeight: 48.w * (4 / 3),
              prefferWidth: 48.w,
              // prefferWidth: 174,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  TCustomWidgets.formattedPrice(
                    product.price,
                    13,
                    TColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridView2 extends StatelessWidget {
  final List<ProductModel> filteredProducts;

  const _GridView2({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18.0,
        bottom: 30,
      ),
      child: MasonryGridView.count(
        itemCount: filteredProducts.length,
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder:
            (BuildContext context, int index) =>
                ActionsMethods.customLongMethode(
                  filteredProducts[index],
                  context,
                  VendorController.instance.isVendor.value,
                  ProductWidgetMedium(
                    product: filteredProducts[index],
                    vendorId: filteredProducts[index].vendorId ?? '',
                    editMode: false,
                    prefferHeight: 48.w * (4 / 3),
                    prefferWidth: 48.w,
                  ),
                  () => Get.to(
                    () => Scaffold(
                      bottomSheet: BottomAddToCart(
                        product: filteredProducts[index],
                      ),
                      body: SafeArea(
                        child: ProductDetailsPage(
                          product: filteredProducts[index],
                          edit: false,
                          vendorId: filteredProducts[index].vendorId ?? '',
                        ),
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}

class _FavoriteVendorsSection extends StatelessWidget {
  const _FavoriteVendorsSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VendorModel>>(
      future: _getFavoriteVendors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final vendors = snapshot.data!;

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'your_favorite_shops'.tr,
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Get.to(
                          () => FavoriteVendors(userId: _getCurrentUserId()),
                        ),
                    child: Text(
                      'view_all'.tr,
                      style: const TextStyle(
                        color: TColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vendors List
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      vendors.length > 5
                          ? 5
                          : vendors.length, // Show max 5 vendors
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          // Vendor Avatar
                          GestureDetector(
                            onTap: () => _navigateToVendor(vendor),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                image:
                                    vendor.organizationCover.isNotEmpty
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            vendor.organizationCover,
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {},
                                        )
                                        : null,
                              ),
                              child:
                                  vendor.organizationCover.isEmpty
                                      ? Icon(
                                        Icons.store,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      )
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Vendor Name
                          Text(
                            vendor.organizationName.isNotEmpty
                                ? vendor.organizationName
                                : vendor.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<VendorModel>> _getFavoriteVendors() async {
    try {
      final followController = Get.find<FollowController>();
      final userId = _getCurrentUserId();
      return await followController.getFollowing(userId);
    } catch (e) {
      print('Error getting favorite vendors: $e');
      return [];
    }
  }

  String _getCurrentUserId() {
    // Get actual user ID from AuthController
    try {
      final userId = Get.find<AuthController>().currentUser.value?.userId;
      return userId ?? '';
    } catch (e) {
      print('Error getting current user ID: $e');
      return '';
    }
  }

  void _navigateToVendor(VendorModel vendor) {
    // Navigate to vendor details page
    // You might want to implement this based on your routing
    print('Navigate to vendor: ${vendor.organizationName}');
  }
}
