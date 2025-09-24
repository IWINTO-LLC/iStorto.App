import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/cart/view/cart_widget.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearchExpanded = false;
  bool _isAppBarVisible = true;
  bool _showScrollToTop = false;
  String _searchQuery = '';
  String _selectedCategory =
      TranslationController.instance.isRTL ? 'الكل' : 'All';
  double _lastScrollPosition = 0;
  int _viewMode = 1; // 0: قائمة، 1: شبكة 4 عناصر، 2: شبكة عنصرين

  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _scrollController.removeListener(_onScroll);
    }
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // التحقق من أن ScrollController لا يزال صالحاً
    if (!_scrollController.hasClients) return;

    final currentPosition = _scrollController.position.pixels;

    // إظهار/إخفاء زر العودة لأعلى
    if (currentPosition > 300) {
      if (!_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      }
    } else {
      if (_showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
      }
    }

    // إخفاء AppBar عند النزول
    if (currentPosition > _lastScrollPosition && currentPosition > 100) {
      if (_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = false;
        });
      }
    }
    // إظهار AppBar عند الصعود
    else if (currentPosition < _lastScrollPosition) {
      if (!_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = true;
        });
      }
    }

    _lastScrollPosition = currentPosition;
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProducts();
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadProducts() async {
    final controller = ProductController.instance;
    final productRepository = Get.find<ProductRepository>();

    try {
      await productRepository.getProductsByVendor(widget.vendorId);

      await Future.delayed(const Duration(milliseconds: 100));

      // طباعة معلومات التصحيح
      print('📊 Total products loaded: ${controller.allItems.length}');
      print(
        '📊 Products with categories: ${controller.allItems.where((p) => p.category?.title != null).length}',
      );

      Set<String> uniqueCategories = <String>{};

      uniqueCategories.add(
        TranslationController.instance.isRTL ? 'الكل' : 'All',
      );

      for (var product in controller.allItems) {
        if (product.category?.title != null &&
            product.category!.title.isNotEmpty) {
          uniqueCategories.add(product.category!.title);
          print('📊 Added category: ${product.category!.title}');
        }
      }

      _categories = uniqueCategories.toList();

      print('📊 Final categories: $_categories');
      print('📊 Categories count: ${_categories.length}');

      if (mounted && _categories.isNotEmpty) {
        _tabController = TabController(length: _categories.length, vsync: this);
        _tabController.addListener(() {
          if (_tabController.indexIsChanging) {
            setState(() {
              _selectedCategory = _categories[_tabController.index];
              _filterProducts();
            });
          }
        });

        _selectedCategory = _categories[0];
      }

      setState(() {
        _filteredProducts = controller.allItems;
      });
    } catch (e) {
      print('❌ Error loading products: $e');

      _categories = [TranslationController.instance.isRTL ? 'الكل' : 'All'];
      _selectedCategory = _categories[0];

      if (mounted) {
        _tabController = TabController(length: 1, vsync: this);
      }
    }
  }

  void _filterProducts() {
    final controller = ProductController.instance;
    List<ProductModel> filtered = controller.allItems;

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
      print('🔍 Products after search filter: ${filtered.length}');
    }

    if (_selectedCategory !=
        (TranslationController.instance.isRTL ? 'الكل' : 'All')) {
      filtered =
          filtered
              .where((product) => product.category?.title == _selectedCategory)
              .toList();
      print('🔍 Products after category filter: ${filtered.length}');
    }

    setState(() {
      _filteredProducts = filtered;
    });

    print('🔍 Final filtered products: ${_filteredProducts.length}');
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

  void _addNewProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateProduct(
              vendorId: widget.vendorId,
              type: '',
              initialList: [],
              sectorTitle:
                  SectorController.instance.sectors
                      .where((s) => s.name == 'mixlin1')
                      .first,
              sectionId: 'mixlin1',
            ),
      ),
    );
  }

  void _showProductOverlay(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
                        product.images.isEmpty != false
                            ? Colors.grey[300]
                            : null,
                  ),
                  child:
                      product.images.isEmpty != false
                          ? const Center(
                            child: Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
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
                            onPressed: () => Navigator.of(context).pop(),
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
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredProducts.length + 1,
      separatorBuilder: (context, index) => const Divider(),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
      itemBuilder: (BuildContext context, int index) {
        if (index == _filteredProducts.length) {
          return const SizedBox(height: 70);
        }

        return ActionsMethods.customLongMethode(
          _filteredProducts[index],
          context,
          false, // VendorController.instance.isVendor.value,
          ProductWidgetHorzental(
            product: _filteredProducts[index],
            vendorId: _filteredProducts[index].vendorId ?? '',
          ),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetails(
                    selected: index,
                    spotList: _filteredProducts,
                    product: _filteredProducts[index],
                    vendorId: widget.vendorId,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (BuildContext context, int index) {
        return ActionsMethods.customLongMethode(
          _filteredProducts[index],
          context,
          false, // VendorController.instance.isVendor.value,
          _buildGridItem(_filteredProducts[index]),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetails(
                    selected: index,
                    spotList: _filteredProducts,
                    product: _filteredProducts[index],
                    vendorId: widget.vendorId,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(ProductModel product) {
    return GestureDetector(
      onLongPress: () {
        _showProductOverlay(context, product);
      },
      child: Container(
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

  Widget _buildTwoColumnGridView() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
      child: MasonryGridView.count(
        itemCount: _filteredProducts.length,
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        padding: const EdgeInsets.all(14),
        itemBuilder: (BuildContext context, int index) {
          return ActionsMethods.customLongMethode(
            _filteredProducts[index],
            context,
            false, // VendorController.instance.isVendor.value,
            ProductWidgetMedium(
              product: _filteredProducts[index],
              vendorId: widget.vendorId,
              editMode: false,
              prefferHeight: 200,
              prefferWidth: 180,
            ),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetails(
                      selected: index,
                      spotList: _filteredProducts,
                      product: _filteredProducts[index],
                      vendorId: widget.vendorId,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height:
                  _isAppBarVisible
                      ? (_isSearchExpanded
                          ? 170
                          : (_categories.isNotEmpty ? 125 : 70))
                      : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isAppBarVisible ? 1.0 : 0.0,
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
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            // العنوان
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
                            // زر البحث
                            IconButton(
                              onPressed: _toggleSearch,
                              icon: Icon(
                                _isSearchExpanded ? Icons.close : Icons.search,
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
                                        _addNewProduct();
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
                                // زر طرق العرض
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
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
                                                  _viewMode == 0
                                                      ? Icons.check
                                                      : Icons.view_list,
                                                  size: 20,
                                                  color:
                                                      _viewMode == 0
                                                          ? Colors.green
                                                          : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'common.list_view'.tr,
                                                  style: TextStyle(
                                                    color:
                                                        _viewMode == 0
                                                            ? Colors.green
                                                            : null,
                                                    fontWeight:
                                                        _viewMode == 0
                                                            ? FontWeight.bold
                                                            : null,
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
                                                  _viewMode == 1
                                                      ? Icons.check
                                                      : Icons.grid_view,
                                                  size: 20,
                                                  color:
                                                      _viewMode == 1
                                                          ? Colors.green
                                                          : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'common.grid_4_items'.tr,
                                                  style: TextStyle(
                                                    color:
                                                        _viewMode == 1
                                                            ? Colors.green
                                                            : null,
                                                    fontWeight:
                                                        _viewMode == 1
                                                            ? FontWeight.bold
                                                            : null,
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
                                                  _viewMode == 2
                                                      ? Icons.check
                                                      : Icons.view_column,
                                                  size: 20,
                                                  color:
                                                      _viewMode == 2
                                                          ? Colors.green
                                                          : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'common.grid_2_items'.tr,
                                                  style: TextStyle(
                                                    color:
                                                        _viewMode == 2
                                                            ? Colors.green
                                                            : null,
                                                    fontWeight:
                                                        _viewMode == 2
                                                            ? FontWeight.bold
                                                            : null,
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
                          ],
                        ),
                      ),
                      if (_isSearchExpanded)
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
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
                      if (_categories.isNotEmpty)
                        Flexible(
                          child: Container(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected =
                                    _selectedCategory == category;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                      _filterProducts();
                                    });
                                    _tabController.animateTo(index);
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
            Expanded(
              child: Obx(() {
                if (!_scrollController.hasClients &&
                    !controller.isLoading.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _scrollController.addListener(_onScroll);
                    }
                  });
                }

                if (controller.isLoading.value) {
                  return ListView.separated(
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 10),
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 20,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return TShimmerEffect(
                        width: double.infinity,
                        height: 180,
                        raduis: BorderRadius.circular(15),
                      );
                    },
                  );
                }

                if (controller.allItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: AnimeEmptyLogo(),
                  );
                } else {
                  return Stack(
                    children: [
                      _viewMode == 0
                          ? _buildListView()
                          : _viewMode == 1
                          ? _buildGridView()
                          : _buildTwoColumnGridView(),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showScrollToTop ? 1.0 : 0.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.translationValues(
                              0,
                              _showScrollToTop ? 0 : 50,
                              0,
                            ),
                            child: GestureDetector(
                              onTap: _scrollToTop,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.keyboard_double_arrow_up,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
