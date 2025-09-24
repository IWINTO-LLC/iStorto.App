import 'package:get/get.dart';
import 'package:istoreto/featured/cart/data/save_for_later_repository.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/logging/logger.dart';

class SaveForLaterController extends GetxController {
  static SaveForLaterController get instance => Get.find();
  final _repository = SaveForLaterRepository.instance;
  final RxList<CartItem> savedItems = <CartItem>[].obs;
  final RxList<ProductModel> savedProducts = <ProductModel>[].obs;
  final RxSet<String> savedProductIds = <String>{}.obs;
  final isLoading = false.obs;
  final RxBool _isInitializing = true.obs;
  final RxBool _isUserAuthenticated = false.obs;


  String? get userId => SupabaseService.client.auth.currentUser?.id;

  bool get isInitializing => _isInitializing.value;
  bool get isUserAuthenticated => _isUserAuthenticated.value;

  @override
  void onInit() {
    super.onInit();
    // التحقق من حالة المصادقة
    _checkAuthenticationStatus();
  }

  // التحقق من حالة المصادقة
  void _checkAuthenticationStatus() {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      _isUserAuthenticated.value = true;
      _initializeAsync();
    } else {
      _isUserAuthenticated.value = false;
      _isInitializing.value = false;
      // الاستماع لتغييرات حالة المصادقة
      SupabaseService.client.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null) {
          _isUserAuthenticated.value = true;
          _initializeAsync();
        } else {
          _isUserAuthenticated.value = false;
          _clearData();
        }
      });
    }
  }

  // مسح البيانات عند تسجيل الخروج
  void _clearData() {
    savedItems.clear();
    savedProducts.clear();
    savedProductIds.clear();
    update();
  }

  // تهيئة غير متزامنة لتسريع الإنشاء
  Future<void> _initializeAsync() async {
    try {
      // التحقق من أن المستخدم مصادق عليه
      if (userId == null) {
        TLoggerHelper.warning(
          'User not authenticated, skipping initialization',
        );
        _isInitializing.value = false;
        return;
      }

      // جلب معرفات المنتجات المحفوظة فقط (بدون تفاصيل المنتجات)
      await _loadSavedProductIds();

      // تعيين حالة التهيئة كاملة
      _isInitializing.value = false;

      // بدء الاستماع للتغيرات
      listenToSavedProducts();

      TLoggerHelper.info(
        'SaveForLaterController initialized successfully for user: $userId',
      );
    } catch (e) {
      TLoggerHelper.error('Error initializing SaveForLaterController: $e');
      _isInitializing.value = false;
    }
  }

  Future<void> _loadSavedProductIds() async {
    try {
      // التحقق من أن المستخدم مصادق عليه
      if (userId == null) {
        TLoggerHelper.warning(
          'Cannot load saved products: user not authenticated',
        );
        return;
      }

      final items = await _repository.getSavedItems();
      final ids = items.map((item) => item.product.id).toSet();
      savedProductIds.assignAll(ids);

      TLoggerHelper.info(
        'Loaded ${ids.length} saved product IDs for user: $userId',
      );
    } catch (e) {
      TLoggerHelper.error('Error loading saved product IDs: $e');
    }
  }

  Future<void> fetchSavedItems() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      final items = await _repository.getSavedItems();
      savedItems.value = items;
      
      // تحديث قائمة المنتجات المحفوظة
      final products = items.map((item) => item.product).toList();
      savedProducts.value = products;
      
      // تحديث معرفات المنتجات المحفوظة
      final ids = items.map((item) => item.product.id).toSet();
      savedProductIds.assignAll(ids);
    } catch (e) {
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_load_saved_items'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة منتج للحفظ (من saved_product_controller)
  Future<void> saveProduct(ProductModel product) async {
    // التحقق من أن المستخدم مصادق عليه
    if (userId == null) {
      TLoggerHelper.warning('Cannot save product: user not authenticated');
      return;
    }

    if (!isSaved(product.id)) {
      try {
        // إنشاء CartItem من ProductModel
        final cartItem = CartItem(
          product: product,
          quantity: 1,
        );
        
        await _repository.saveItem(cartItem);
        savedProductIds.add(product.id);
        savedProducts.add(product);
        update();
        
        Get.snackbar(
          'common.success'.tr,
          'cart.item_saved_for_later'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        TLoggerHelper.info('Error adding saved product: $e');
        Get.snackbar(
          'common.error'.tr,
          'cart.failed_to_save_item'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> saveItem(CartItem item) async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _repository.saveItem(item);
      await fetchSavedItems();
      Get.snackbar(
        'common.success'.tr,
        'cart.item_saved_for_later'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_save_item'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // حذف منتج من المحفوظات (من saved_product_controller)
  Future<void> removeProduct(ProductModel product) async {
    // التحقق من أن المستخدم مصادق عليه
    if (userId == null) {
      TLoggerHelper.warning('Cannot remove product: user not authenticated');
      return;
    }

    try {
      await _repository.removeItem(product.id);
      savedProductIds.remove(product.id);
      savedProducts.removeWhere((p) => p.id == product.id);
      savedItems.removeWhere((item) => item.product.id == product.id);
      update();
      
      Get.snackbar(
        'common.success'.tr,
        'cart.item_removed_from_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      TLoggerHelper.info('Error removing saved product: $e');
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_remove_item'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeItem(String productId) async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _repository.removeItem(productId);
      savedItems.removeWhere((item) => item.product.id == productId);
      savedProducts.removeWhere((product) => product.id == productId);
      savedProductIds.remove(productId);
      Get.snackbar(
        'common.success'.tr,
        'cart.item_removed_from_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_remove_item'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(CartItem item) async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _repository.moveToCart(item);
      await fetchSavedItems();
      Get.snackbar(
        'common.success'.tr,
        'cart.item_added_to_cart'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_add_to_cart'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAllToCart() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _repository.moveAllToCart();
      await fetchSavedItems();
      Get.snackbar(
        'common.success'.tr,
        'cart.all_items_added_to_cart'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_add_all_to_cart'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if item is saved for later
  Future<bool> isItemSaved(String productId) async {
    if (userId == null) return false;
    return await _repository.isItemSaved(productId);
  }

  // التحقق من أن منتج محفوظ (من saved_product_controller)
  bool isSaved(String productId) {
    return savedProductIds.contains(productId);
  }

  /// Get saved items count
  Future<int> getSavedItemsCount() async {
    if (userId == null) return 0;
    return await _repository.getSavedItemsCount();
  }

  // مسح كل المحفوظات (من saved_product_controller)
  Future<void> clearList() async {
    // التحقق من أن المستخدم مصادق عليه
    if (userId == null) {
      TLoggerHelper.warning('Cannot clear list: user not authenticated');
      return;
    }

    try {
      await _repository.clearAllSavedItems();
      savedProductIds.clear();
      savedProducts.clear();
      savedItems.clear();
      update();
      
      Get.snackbar(
        'common.success'.tr,
        'cart.all_saved_items_cleared'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      TLoggerHelper.info('Error clearing saved products: $e');
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_clear_saved_items'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear all saved items
  Future<void> clearAllSavedItems() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      await _repository.clearAllSavedItems();
      savedItems.clear();
      savedProducts.clear();
      savedProductIds.clear();
      Get.snackbar(
        'common.success'.tr,
        'cart.all_saved_items_cleared'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'common.error'.tr,
        'cart.failed_to_clear_saved_items'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // الاستماع لتغيرات المحفوظات (من saved_product_controller)
  void listenToSavedProducts() {
    // التحقق من أن المستخدم مصادق عليه
    if (userId == null) {
      TLoggerHelper.warning(
        'Cannot listen to saved products: user not authenticated',
      );
      return;
    }

    // يمكن إضافة استماع للتغييرات من Supabase هنا إذا لزم الأمر
    // حالياً نعتمد على التحديث اليدوي عند الحاجة
  }

  // الحصول على المنتجات المحفوظة
  List<ProductModel> get savedProductsList => savedProducts.toList();

  // الحصول على العناصر المحفوظة
  List<CartItem> get savedItemsList => savedItems.toList();

  // الحصول على معرفات المنتجات المحفوظة
  Set<String> get savedProductIdsSet => savedProductIds.toSet();
}
