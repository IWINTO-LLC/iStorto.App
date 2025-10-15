import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/data/product_repository.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/logging/logger.dart';

class FavoriteProductsController extends GetxController {
  static FavoriteProductsController get instance => Get.find();

  RxList<ProductModel> favoriteProducts = <ProductModel>[].obs;
  final _client = SupabaseService.client;
  String? _userId;
  RxSet<String> favoriteProductIds = <String>{}.obs;

  // متغيرات لتتبع حالة التحميل لكل منتج
  final RxMap<String, bool> _processingProducts = <String, bool>{}.obs;

  // متغيرات البحث وطريقة العرض
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final RxBool isSearchExpanded = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt viewMode = 0.obs; // 0: قائمة، 1: شبكة 4 عناصر، 2: شبكة عنصرين
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // متغيرات حالة التهيئة والمصادقة
  final RxBool _isInitializing = true.obs;
  final RxBool _isUserAuthenticated = false.obs;

  bool get isInitializing => _isInitializing.value;
  bool get isUserAuthenticated => _isUserAuthenticated.value;

  @override
  void onInit() {
    super.onInit();
    // التحقق من حالة المصادقة
    _checkAuthenticationStatus();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  // التحقق من حالة المصادقة
  void _checkAuthenticationStatus() {
    final user = _client.auth.currentUser;
    if (user != null) {
      _userId = user.id;
      _isUserAuthenticated.value = true;
      _initializeAsync();
    } else {
      _isUserAuthenticated.value = false;
      _isInitializing.value = false;
      // الاستماع لتغييرات حالة المصادقة
      _client.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null) {
          _userId = user.id;
          _isUserAuthenticated.value = true;
          _initializeAsync();
        } else {
          _userId = null;
          _isUserAuthenticated.value = false;
          _clearData();
        }
      });
    }
  }

  // مسح البيانات عند تسجيل الخروج
  void _clearData() {
    favoriteProducts.clear();
    favoriteProductIds.clear();
    filteredProducts.clear();
    _processingProducts.clear();
    update();
  }

  // تهيئة غير متزامنة
  Future<void> _initializeAsync() async {
    try {
      // التحقق من أن المستخدم مصادق عليه
      if (_userId == null) {
        TLoggerHelper.warning(
          'User not authenticated, skipping initialization',
        );
        _isInitializing.value = false;
        return;
      }

      // تعيين حالة التهيئة كاملة
      _isInitializing.value = false;

      // بدء الاستماع للتغيرات
      listenToFavorites();

      TLoggerHelper.info(
        'FavoriteProductsController initialized successfully for user: $_userId',
      );
    } catch (e) {
      TLoggerHelper.error('Error initializing FavoriteProductsController: $e');
      _isInitializing.value = false;
    }
  }

  void _setupSearchListener() {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _filterProducts();
  }

  void _filterProducts() {
    List<ProductModel> filtered = favoriteProducts;

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

    filteredProducts.value = filtered;
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (isSearchExpanded.value) {
      searchFocusNode.requestFocus();
    } else {
      searchController.clear();
      searchQuery.value = '';
      _filterProducts();
      searchFocusNode.unfocus();
    }
  }

  // الحصول على حالة معالجة منتج معين
  bool isProcessing(String productId) =>
      _processingProducts[productId] ?? false;

  // إضافة منتج للمفضلة
  Future<void> saveProduct(ProductModel product) async {
    // التحقق من أن المستخدم مصادق عليه
    if (_userId == null) {
      TLoggerHelper.warning('Cannot save product: user not authenticated');
      return;
    }

    if (!isSaved(product.id)) {
      try {
        // تعيين حالة المعالجة
        _processingProducts[product.id] = true;
        update();

        await _client.from('favorite_products').insert({
          'user_id': _userId,
          'product_id': product.id,
          'created_at': DateTime.now().toIso8601String(),
        });

        favoriteProductIds.add(product.id);
        favoriteProducts.add(product);

        // إزالة حالة المعالجة
        _processingProducts[product.id] = false;
        update();
      } catch (e) {
        // إعادة تعيين حالة المعالجة في حالة الخطأ
        _processingProducts[product.id] = false;
        update();
        TLoggerHelper.info('Error adding favorite: $e');
      }
    }
  }

  // حذف منتج من المفضلة
  Future<void> removeProduct(ProductModel product) async {
    // التحقق من أن المستخدم مصادق عليه
    if (_userId == null) {
      TLoggerHelper.warning('Cannot remove product: user not authenticated');
      return;
    }

    try {
      // تعيين حالة المعالجة
      _processingProducts[product.id] = true;
      update();

      await _client
          .from('favorite_products')
          .delete()
          .eq('user_id', _userId!)
          .eq('product_id', product.id);

      favoriteProductIds.remove(product.id);
      favoriteProducts.removeWhere((p) => p.id == product.id);

      // إزالة حالة المعالجة
      _processingProducts[product.id] = false;
      update();
    } catch (e) {
      // إعادة تعيين حالة المعالجة في حالة الخطأ
      _processingProducts[product.id] = false;
      update();
      TLoggerHelper.info('Error removing favorite: $e');
    }
  }

  // مسح كل المفضلة
  Future<void> clearList() async {
    // التحقق من أن المستخدم مصادق عليه
    if (_userId == null) {
      TLoggerHelper.warning('Cannot clear list: user not authenticated');
      return;
    }

    try {
      await _client.from('favorite_products').delete().eq('user_id', _userId!);

      favoriteProductIds.clear();
      favoriteProducts.clear();
      filteredProducts.clear();
      _processingProducts.clear();
      update();
    } catch (e) {
      TLoggerHelper.info('Error clearing favorites: $e');
    }
  }

  // الاستماع لتغيرات المفضلة
  void listenToFavorites() {
    // التحقق من أن المستخدم مصادق عليه
    if (_userId == null) {
      TLoggerHelper.warning(
        'Cannot listen to favorites: user not authenticated',
      );
      return;
    }

    _client
        .from('favorite_products')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .listen((data) async {
          final ids =
              (data as List)
                  .map((item) => item['product_id'] as String)
                  .toSet();
          favoriteProductIds.value = ids;
          if (ids.isNotEmpty) {
            final products = await ProductRepository.instance.getProductsByIds(
              ids.toList(),
            );
            favoriteProducts.value = products;
            // تحديث المنتجات المفلترة
            _filterProducts();
          } else {
            favoriteProducts.clear();
            filteredProducts.clear();
          }
          update();
        });
  }

  bool isSaved(String productId) {
    return favoriteProductIds.contains(productId);
  }

  var isLoad = false.obs;
}
