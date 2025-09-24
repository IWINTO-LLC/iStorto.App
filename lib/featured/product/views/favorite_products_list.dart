// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/views/widgets/bottom_add_tocart.dart';
import 'package:istoreto/featured/product/views/widgets/one_product_details.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_horz.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_medium.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/utils/actions.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:sizer/sizer.dart';

class FavoriteProductsPage extends StatefulWidget {
  const FavoriteProductsPage({super.key});

  @override
  State<FavoriteProductsPage> createState() => _FavoriteProductsPageState();
}

class _FavoriteProductsPageState extends State<FavoriteProductsPage> {
  late final FavoriteProductsController controller;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _updateTimer;

  bool _isSearchExpanded = false;
  String _searchQuery = '';
  int _viewMode = 1; // 0: قائمة، 1: شبكة 4 عناصر، 2: شبكة عنصرين

  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // تهيئة controller باستخدام Get.put
    controller = Get.put(FavoriteProductsController());

    _searchController.addListener(_onSearchChanged);

    // تهيئة المنتجات المفلترة بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteProducts();
    });

    // بدء مؤقت لتحديث المنتجات كل ثانية
    _startUpdateTimer();
  }

  void _loadFavoriteProducts() {
    // تحديث المنتجات المفلترة
    setState(() {
      _filteredProducts = List.from(controller.favoriteProducts);
    });

    print('🔍 Loading favorite products...');
    print(
      '🔍 Controller products count: ${controller.favoriteProducts.length}',
    );
    print('🔍 Filtered products count: ${_filteredProducts.length}');

    // إذا كانت المنتجات فارغة، حاول تحميلها مرة أخرى بعد فترة
    if (_filteredProducts.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _filteredProducts = List.from(controller.favoriteProducts);
          });
          print(
            '🔍 After delay - Controller products count: ${controller.favoriteProducts.length}',
          );
          print(
            '🔍 After delay - Filtered products count: ${_filteredProducts.length}',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && controller.favoriteProducts.isNotEmpty) {
        setState(() {
          _filteredProducts = List.from(controller.favoriteProducts);
        });
        // إيقاف المؤقت بعد التحديث
        timer.cancel();
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProducts();
    });
  }

  void _filterProducts() {
    List<ProductModel> filtered = List.from(controller.favoriteProducts);

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (product) =>
                    (product.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    )) ||
                    (product.description?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchQuery = '';
        _filterProducts();
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title:
            _isSearchExpanded
                ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'search_in_favorites'.tr,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                )
                : Text(
                  'favorite_products'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            TranslationController.instance.isRTL
                ? Icons.arrow_back
                : Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          // زر البحث
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchExpanded ? Icons.close : Icons.search,
              color: Colors.black,
            ),
          ),
          // زر طرق العرض
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'list_view') {
                  setState(() {
                    _viewMode = 0;
                  });
                } else if (value == 'grid_4') {
                  setState(() {
                    _viewMode = 1;
                  });
                } else if (value == 'grid_2') {
                  setState(() {
                    _viewMode = 2;
                  });
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'list_view',
                      child: Row(
                        children: [
                          Icon(
                            _viewMode == 0 ? Icons.check : Icons.view_list,
                            size: 20,
                            color: _viewMode == 0 ? Colors.green : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'list_view'.tr,
                            style: TextStyle(
                              color: _viewMode == 0 ? Colors.green : null,
                              fontWeight:
                                  _viewMode == 0 ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'grid_4',
                      child: Row(
                        children: [
                          Icon(
                            _viewMode == 1 ? Icons.check : Icons.grid_view,
                            size: 20,
                            color: _viewMode == 1 ? Colors.green : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'grid_4_items'.tr,
                            style: TextStyle(
                              color: _viewMode == 1 ? Colors.green : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'grid_2',
                      child: Row(
                        children: [
                          Icon(
                            _viewMode == 2 ? Icons.check : Icons.grid_view,
                            size: 20,
                            color: _viewMode == 2 ? Colors.green : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'grid_2_items'.tr,
                            style: TextStyle(
                              color: _viewMode == 2 ? Colors.green : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            _filteredProducts.isEmpty
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/liquid_loading.gif',
                        width: 70.w,
                        height: 70.w,
                      ),
                      Text(
                        _searchQuery.isNotEmpty
                            ? "no_search_results".tr
                            : "no_items_yet".tr,
                        style: titilliumBold.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                )
                : _buildProductView(),
      ),
    );
  }

  Widget _buildProductView() {
    switch (_viewMode) {
      case 0:
        return _buildListView();
      case 1:
        return _buildGridView4();
      case 2:
        return _buildGridView2();
      default:
        return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ActionsMethods.customLongMethode(
            _filteredProducts[index],
            context,
            VendorController.instance.isVendor.value,
            ProductWidgetHorzental(
              product: _filteredProducts[index],
              vendorId: _filteredProducts[index].vendorId ?? '',
            ),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      bottomSheet: BottomAddToCart(
                        product: _filteredProducts[index],
                      ),
                      body: SafeArea(
                        child: ProductDetailsPage(
                          product: _filteredProducts[index],
                          edit: false,
                          vendorId: _filteredProducts[index].vendorId ?? '',
                        ),
                      ),
                    ),
              ),
            ),

            //  Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => ProductDetails(
            //       product: _filteredProducts[index],
            //       selected: index,
            //       vendorId: _filteredProducts[index].vendorId,
            //       spotList: _filteredProducts,
            //     ),
            //   ),
            // ),
          ),
        );
      },
    );
  }

  Widget _buildGridView4() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return ActionsMethods.customLongMethode(
          _filteredProducts[index],
          context,
          VendorController.instance.isVendor.value,
          _buildGridItem(_filteredProducts[index]),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    bottomSheet: BottomAddToCart(
                      product: _filteredProducts[index],
                    ),
                    body: SafeArea(
                      child: ProductDetailsPage(
                        product: _filteredProducts[index],
                        edit: false,
                        vendorId: _filteredProducts[index].vendorId ?? '',
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView2() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18.0,
        bottom: 30,
      ),
      child: MasonryGridView.count(
        itemCount: _filteredProducts.length,
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder:
            (BuildContext context, int index) =>
                ActionsMethods.customLongMethode(
                  _filteredProducts[index],
                  context,
                  VendorController.instance.isVendor.value,
                  ProductWidgetMedium(
                    product: _filteredProducts[index],
                    vendorId: _filteredProducts[index].vendorId ?? '',
                    editMode: false,
                    prefferHeight: 48.w * (4 / 3),
                    prefferWidth: 48.w,
                  ),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            bottomSheet: BottomAddToCart(
                              product: _filteredProducts[index],
                            ),
                            body: SafeArea(
                              child: ProductDetailsPage(
                                product: _filteredProducts[index],
                                edit: false,
                                vendorId:
                                    _filteredProducts[index].vendorId ?? '',
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildGridItem(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            child: FreeCaChedNetworkImage(
              url: product.images.first,
              raduis: BorderRadius.vertical(top: Radius.circular(8)),
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
