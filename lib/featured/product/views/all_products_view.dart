import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/cart/view/cart_widget.dart';
import 'package:istoreto/featured/product/controllers/all_products_view_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/add/add_product.dart';
import 'package:istoreto/featured/product/views/widgets/product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_horz.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/widgets/anime_empty_logo.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/constants/color.dart';

class AllProductViewClient extends StatefulWidget {
  const AllProductViewClient({super.key, required this.vendorId});
  final String vendorId;

  @override
  State<AllProductViewClient> createState() => _AllProductViewClientState();
}

class _AllProductViewClientState extends State<AllProductViewClient>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Initialize controller with TickerProvider
    final viewController = Get.put(AllProductsViewController());
    Get.put(this as TickerProvider); // Register this widget as TickerProvider
    final productController = ProductController.instance;

    // Load products when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewController.loadProducts(widget.vendorId);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar Content
            _AppBarContent(vendorId: widget.vendorId),

            // Body Content
            Expanded(
              child: Obx(() {
                if (productController.isLoading.value) {
                  return _LoadingView();
                }

                if (productController.allItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: AnimeEmptyLogo(),
                  );
                }

                return _ProductView(vendorId: widget.vendorId);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarContent extends StatelessWidget {
  final String vendorId;

  const _AppBarContent({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final viewController = Get.find<AllProductsViewController>();

    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height:
            viewController.isAppBarVisible.value
                ? (viewController.isSearchExpanded.value
                    ? 170
                    : (viewController.categories.isNotEmpty ? 125 : 70))
                : 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: viewController.isAppBarVisible.value ? 1.0 : 0.0,
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          'shop.products'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: viewController.toggleSearch,
                        icon: Icon(
                          viewController.isSearchExpanded.value
                              ? Icons.close
                              : Icons.search,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CartWidget(),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.settings),
                              onSelected: (value) {
                                if (value == 'add_new') {
                                  _addNewProduct(vendorId);
                                }
                              },
                              itemBuilder:
                                  (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'add_new',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add, size: 20),
                                          const SizedBox(width: 8),
                                          Text('product.add_new'.tr),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                switch (value) {
                                  case 'list_view':
                                    viewController.setViewMode(0);
                                    break;
                                  case 'grid_4':
                                    viewController.setViewMode(1);
                                    break;
                                  case 'grid_2':
                                    viewController.setViewMode(2);
                                    break;
                                }
                              },
                              itemBuilder:
                                  (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'list_view',
                                      child: Obx(
                                        () => Row(
                                          children: [
                                            Icon(
                                              viewController.viewMode.value == 0
                                                  ? Icons.check
                                                  : Icons.view_list,
                                              size: 20,
                                              color:
                                                  viewController
                                                              .viewMode
                                                              .value ==
                                                          0
                                                      ? Colors.green
                                                      : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'list_view'.tr,
                                              style: TextStyle(
                                                color:
                                                    viewController
                                                                .viewMode
                                                                .value ==
                                                            0
                                                        ? Colors.green
                                                        : null,
                                                fontWeight:
                                                    viewController
                                                                .viewMode
                                                                .value ==
                                                            0
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
                                              viewController.viewMode.value == 1
                                                  ? Icons.check
                                                  : Icons.grid_view,
                                              size: 20,
                                              color:
                                                  viewController
                                                              .viewMode
                                                              .value ==
                                                          1
                                                      ? Colors.green
                                                      : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'grid_4_items'.tr,
                                              style: TextStyle(
                                                color:
                                                    viewController
                                                                .viewMode
                                                                .value ==
                                                            1
                                                        ? Colors.green
                                                        : null,
                                                fontWeight:
                                                    viewController
                                                                .viewMode
                                                                .value ==
                                                            1
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
                                              viewController.viewMode.value == 2
                                                  ? Icons.check
                                                  : Icons.view_column,
                                              size: 20,
                                              color:
                                                  viewController
                                                              .viewMode
                                                              .value ==
                                                          2
                                                      ? Colors.green
                                                      : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'grid_2_items'.tr,
                                              style: TextStyle(
                                                color:
                                                    viewController
                                                                .viewMode
                                                                .value ==
                                                            2
                                                        ? Colors.green
                                                        : null,
                                                fontWeight:
                                                    viewController
                                                                .viewMode
                                                                .value ==
                                                            2
                                                        ? FontWeight.bold
                                                        : null,
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
                    ],
                  ),
                ),
                if (viewController.isSearchExpanded.value)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: viewController.searchController,
                            focusNode: viewController.searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'common.search_products'.tr,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (viewController.categories.isNotEmpty)
                  Flexible(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewController.categories.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final category = viewController.categories[index];
                          final isSelected =
                              viewController.selectedCategory.value == category;

                          return GestureDetector(
                            onTap: () {
                              viewController.setSelectedCategory(category);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.grey[300]
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.grey[400]!
                                          : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.grey[600],
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w900
                                            : FontWeight.normal,
                                    fontSize: isSelected ? 15 : 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
      itemBuilder: (BuildContext context, int index) {
        return TShimmerEffect(
          width: double.infinity,
          height: 180,
          raduis: BorderRadius.circular(15),
        );
      },
    );
  }
}

class _ProductView extends StatelessWidget {
  final String vendorId;

  const _ProductView({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final viewController = Get.find<AllProductsViewController>();

    return Obx(() {
      switch (viewController.viewMode.value) {
        case 0:
          return _ListView(vendorId: vendorId);
        case 1:
          return _GridView4(vendorId: vendorId);
        case 2:
          return _GridView2(vendorId: vendorId);
        default:
          return _ListView(vendorId: vendorId);
      }
    });
  }
}

class _ListView extends StatelessWidget {
  final String vendorId;

  const _ListView({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final viewController = Get.find<AllProductsViewController>();

    return Obx(() {
      final filteredProducts = viewController.filteredProducts;

      return ListView.separated(
        controller: viewController.scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: filteredProducts.length + 1,
        separatorBuilder: (context, index) => const Divider(),
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 20,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (index == filteredProducts.length) {
            return const SizedBox(height: 70);
          }

          return ActionsMethods.customLongMethode(
            filteredProducts[index],
            context,
            false,
            ProductWidgetHorzental(
              product: filteredProducts[index],
              vendorId: filteredProducts[index].vendorId ?? '',
            ),
            () => Get.to(
              () => ProductDetails(
                selected: index,
                spotList: filteredProducts,
                product: filteredProducts[index],
                vendorId: vendorId,
              ),
            ),
          );
        },
      );
    });
  }
}

class _GridView4 extends StatelessWidget {
  final String vendorId;

  const _GridView4({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final viewController = Get.find<AllProductsViewController>();

    return Obx(() {
      final filteredProducts = viewController.filteredProducts;

      return GridView.builder(
        controller: viewController.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 20,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (BuildContext context, int index) {
          return ActionsMethods.customLongMethode(
            filteredProducts[index],
            context,
            false,
            _buildGridItem(filteredProducts[index]),
            () => Get.to(
              () => ProductDetails(
                selected: index,
                spotList: filteredProducts,
                product: filteredProducts[index],
                vendorId: vendorId,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildGridItem(ProductModel product) {
    return GestureDetector(
      onLongPress: () {
        _showProductOverlay(product);
      },
      child: Container(
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
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image:
                      product.images.isNotEmpty == true
                          ? DecorationImage(
                            image: NetworkImage(product.images.first),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                          : null,
                  color:
                      product.images.isEmpty != false ? Colors.grey[300] : null,
                ),
                child:
                    product.images.isEmpty != false
                        ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 24,
                            color: Colors.grey,
                          ),
                        )
                        : null,
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
                    const SizedBox(height: 2),
                    TCustomWidgets.formattedPrice(
                      product.price,
                      12,
                      TColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridView2 extends StatelessWidget {
  final String vendorId;

  const _GridView2({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final viewController = Get.find<AllProductsViewController>();

    return Obx(() {
      final filteredProducts = viewController.filteredProducts;

      return Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 20,
        ),
        child: MasonryGridView.count(
          controller: viewController.scrollController,
          itemCount: filteredProducts.length,
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          padding: const EdgeInsets.all(14),
          itemBuilder: (BuildContext context, int index) {
            return ActionsMethods.customLongMethode(
              filteredProducts[index],
              context,
              false,
              ProductWidgetMedium(
                product: filteredProducts[index],
                vendorId: vendorId,
                editMode: false,
                prefferHeight: 200,
                prefferWidth: 180,
              ),
              () => Get.to(
                () => ProductDetails(
                  selected: index,
                  spotList: filteredProducts,
                  product: filteredProducts[index],
                  vendorId: vendorId,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

void _addNewProduct(String vendorId) {
  Get.to(
    () => CreateProduct(
      vendorId: vendorId,
      type: '',
      initialList: [],
      sectorTitle:
          SectorController.instance.sectors
              .where((s) => s.name == 'mixlin1')
              .first,
      sectionId: 'mixlin1',
    ),
  );
}

void _showProductOverlay(ProductModel product) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image:
                    product.images.isNotEmpty == true
                        ? DecorationImage(
                          image: NetworkImage(product.images.first),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        )
                        : null,
                color:
                    product.images.isEmpty != false ? Colors.grey[300] : null,
              ),
              child:
                  product.images.isEmpty != false
                      ? const Center(
                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                      )
                      : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (product.description?.isNotEmpty == true) ...[
                    Text(
                      TranslationController.instance.isRTL
                          ? 'التفاصيل:'
                          : 'Details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TCustomWidgets.formattedPrice(
                        product.price,
                        20,
                        TColors.primary,
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
