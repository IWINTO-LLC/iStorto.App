import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';

class AllProductsViewController extends GetxController {
  static AllProductsViewController get instance => Get.find();

  // Scroll Controller
  final ScrollController scrollController = ScrollController();

  // Search Controllers
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // State Variables
  final isSearchExpanded = false.obs;
  final isAppBarVisible = true.obs;
  final showScrollToTop = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final lastScrollPosition = 0.0.obs;
  final viewMode = 1.obs; // 0: قائمة، 1: شبكة 4 عناصر، 2: شبكة عنصرين

  // Data Lists
  final filteredProducts = <ProductModel>[].obs;
  final categories = <String>[].obs;

  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
    _setupScrollListener();
    _setupSearchListener();
  }

  @override
  void onClose() {
    if (scrollController.hasClients) {
      scrollController.removeListener(_onScroll);
    }
    scrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    tabController?.dispose();
    super.onClose();
  }

  void _initializeCategories() {
    selectedCategory.value =
        TranslationController.instance.isRTL ? 'الكل' : 'All';
  }

  void _setupScrollListener() {
    scrollController.addListener(_onScroll);
  }

  void _setupSearchListener() {
    searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final currentPosition = scrollController.position.pixels;

    // إظهار/إخفاء زر العودة لأعلى
    if (currentPosition > 300) {
      if (!showScrollToTop.value) {
        showScrollToTop.value = true;
      }
    } else {
      if (showScrollToTop.value) {
        showScrollToTop.value = false;
      }
    }

    // إخفاء AppBar عند النزول
    if (currentPosition > lastScrollPosition.value && currentPosition > 100) {
      if (isAppBarVisible.value) {
        isAppBarVisible.value = false;
      }
    }
    // إظهار AppBar عند الصعود
    else if (currentPosition < lastScrollPosition.value) {
      if (!isAppBarVisible.value) {
        isAppBarVisible.value = true;
      }
    }

    lastScrollPosition.value = currentPosition;
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    filterProducts();
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadProducts(String vendorId) async {
    final controller = ProductController.instance;
    final productRepository = Get.find<ProductRepository>();

    try {
      await productRepository.getProductsByVendor(vendorId);

      await Future.delayed(const Duration(milliseconds: 100));

      Set<String> uniqueCategories = <String>{};

      uniqueCategories.add(
        TranslationController.instance.isRTL ? 'الكل' : 'All',
      );

      for (var product in controller.allItems) {
        if (product.category?.title != null &&
            product.category!.title.isNotEmpty) {
          uniqueCategories.add(product.category!.title);
        }
      }

      categories.assignAll(uniqueCategories.toList());

      if (categories.isNotEmpty) {
        tabController?.dispose();
        tabController = TabController(
          length: categories.length,
          vsync: Get.find<TickerProvider>(),
        );
        tabController!.addListener(() {
          if (tabController!.indexIsChanging) {
            selectedCategory.value = categories[tabController!.index];
            filterProducts();
          }
        });

        selectedCategory.value = categories[0];
      }

      filteredProducts.assignAll(controller.allItems);
    } catch (e) {
      print('❌ Error loading products: $e');

      categories.assignAll([
        TranslationController.instance.isRTL ? 'الكل' : 'All',
      ]);
      selectedCategory.value = categories[0];

      tabController?.dispose();
      tabController = TabController(
        length: 1,
        vsync: Get.find<TickerProvider>(),
      );
    }
  }

  void filterProducts() {
    final controller = ProductController.instance;
    List<ProductModel> filtered = controller.allItems;

    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (product) =>
                    (product.title.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    )) ||
                    (product.description?.toLowerCase().contains(
                          searchQuery.value.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    if (selectedCategory.value !=
        (TranslationController.instance.isRTL ? 'الكل' : 'All')) {
      filtered =
          filtered
              .where(
                (product) => product.category?.title == selectedCategory.value,
              )
              .toList();
    }

    filteredProducts.assignAll(filtered);
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (isSearchExpanded.value) {
      searchFocusNode.requestFocus();
    } else {
      searchController.clear();
      searchQuery.value = '';
      filterProducts();
      searchFocusNode.unfocus();
    }
  }

  void setViewMode(int mode) {
    viewMode.value = mode;
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    filterProducts();
    tabController?.animateTo(categories.indexOf(category));
  }
}
