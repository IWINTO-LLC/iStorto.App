import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/cart/data/cart_repository.dart';
import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/services/supabase_service.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  final _cartRepository = CartRepository.instance;

  final isCheckoutVisible = true.obs;

  final cartItems = <CartItem>[].obs;
  final selectedItems = <String, bool>{}.obs;
  final productQuantities = <String, RxInt>{}.obs;
  final loadingProducts = <String>{}.obs;
  final groupedCart = <String, List<CartItem>>{}.obs;

  final total = 0.obs;
  final selectedTotal = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartFromSupabase();
  }

  // أضف دالة للتحكم في Visibility
  void setCheckoutVisibility(bool visible) {
    isCheckoutVisible.value = visible;
  }

  // void setQuantity(String productId, int quantity) {
  //   if (productQuantities.containsKey(productId)) {
  //     productQuantities[productId]!.value = quantity;
  //   } else {
  //     productQuantities[productId] = RxInt(quantity);
  //   }
  // }

  void handleScroll(ScrollDirection direction) {
    isCheckoutVisible.value =
        direction == ScrollDirection.forward ? true : false;
  }

  void _afterCartChange(ProductModel product) {
    getProductQuantity(product.id);
    getTotalItems();
    updateSelectedTotalPrice();
    // تأجيل حفظ البيانات لتجنب استدعاء setState أثناء البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      saveCartToSupabase();
    });
  }

  Future<void> updateQuantity(ProductModel product, int delta) async {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cartItems[index].quantity += delta;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index);
        await _cartRepository.removeProductFromCart(product.id);
      } else {
        await _cartRepository.updateProductQuantity(
          product.id,
          cartItems[index].quantity,
        );
      }
    } else if (delta > 0) {
      cartItems.add(CartItem(product: product));
      await _cartRepository.saveCartItems(cartItems);
    }

    cartItems.refresh();
    _afterCartChange(product);
  }

  Future<void> addToCart(ProductModel product) => updateQuantity(product, 1);
  Future<void> decreaseQuantity(ProductModel product) =>
      updateQuantity(product, -1);

  Future<void> removeFromCart(ProductModel product) async {
    try {
      cartItems.removeWhere((item) => item.product.id == product.id);
      cartItems.refresh();
      await _cartRepository.removeProductFromCart(product.id);
      _afterCartChange(product);
    } catch (e) {
      debugPrint('🔥 Error removing product from cart: $e');
      Get.snackbar(
        'Error',
        'Failed to remove product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      cartItems.clear();
      cartItems.refresh();
      await _cartRepository.clearCart();
      updateSelectedTotalPrice();
    } catch (e) {
      debugPrint('🔥 Error clearing cart: $e');
      Get.snackbar(
        'Error',
        'Failed to clear cart: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void getProductQuantity(String productId) {
    if (!productQuantities.containsKey(productId)) {
      productQuantities[productId] = 0.obs;
    }

    final index = cartItems.indexWhere((item) => item.product.id == productId);
    productQuantities[productId]!.value =
        index != -1 ? cartItems[index].quantity : 0;
  }

  int getTotalItems() {
    final newTotal = cartItems.fold(0, (sum, item) => sum + item.quantity);
    if (total.value != newTotal) {
      total.value = newTotal;
    }
    return total.value;
  }

  void updateSelectedTotalPrice() {
    final totalValue = cartItems.fold(0.0, (sum, item) {
      final selected = selectedItems[item.product.id] ?? false;
      return selected ? sum + item.totalPrice : sum;
    });
    if (selectedTotal.value != totalValue) {
      selectedTotal.value = totalValue;
    }
    // تجنب استدعاء refresh() إذا لم تكن هناك حاجة
    if (selectedItems.isNotEmpty) {
      selectedItems.refresh();
    }
  }

  double get selectedTotalPrice => selectedTotal.value;
  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get selectedItemsCount => cartItems
      .where((item) => selectedItems[item.product.id] ?? false)
      .fold(0, (sum, item) => sum + item.quantity);

  bool get isAllSelected {
    if (cartItems.isEmpty) return false;
    return cartItems.every((item) => selectedItems[item.product.id] ?? false);
  }

  void toggleSelectAll(bool selectAll) {
    for (var item in cartItems) {
      selectedItems[item.product.id] = selectAll;
    }
    selectedItems.refresh();
    updateSelectedTotalPrice();
  }

  Future<void> saveCartToSupabase() async {
    if (cartItems.isEmpty) return;

    try {
      isLoading.value = true;
      await _cartRepository.saveCartItems(cartItems);
    } catch (e) {
      debugPrint('🔥 Error saving cart: $e');
      Get.snackbar(
        'Error',
        'Failed to save cart: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCartFromSupabase() async {
    try {
      isLoading.value = true;
      final loadedItems = await _cartRepository.loadCartItems();

      cartItems.value = loadedItems;

      for (var item in cartItems) {
        productQuantities[item.product.id] = item.quantity.obs;
      }

      // تأجيل تحديث الإجماليات لتجنب استدعاء setState أثناء البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getTotalItems();
        updateSelectedTotalPrice();
      });
    } catch (e) {
      debugPrint('🔥 Error loading cart: $e');
      Get.snackbar(
        'Error',
        'Failed to load cart: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, List<CartItem>> get groupedByVendor =>
      groupBy(cartItems, (item) => item.product.vendorId ?? 'unknown');

  Map<String, List<CartItem>> get groupedSelectedItemsByVendor {
    final Map<String, List<CartItem>> grouped = {};
    final selected =
        cartItems
            .where((item) => selectedItems[item.product.id] ?? false)
            .toList();
    for (var item in selected) {
      final vendorId = item.product.vendorId ?? 'unknown';
      grouped.putIfAbsent(vendorId, () => []).add(item);
    }
    return grouped;
  }

  Map<String, double> get totalPerVendor {
    final Map<String, double> totals = {};
    groupedSelectedItemsByVendor.forEach((vendorId, items) {
      final total = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      totals[vendorId] = total;
    });
    return totals;
  }

  Future<String?> saveToSupabaseAndGetDocId(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await SupabaseService.client
              .from(tableName)
              .insert(data)
              .select('id')
              .single();
      debugPrint("✅ تم الحفظ برقم الوثيقة: ${response['id']}");
      return response['id'].toString();
    } catch (e) {
      debugPrint("❌ فشل الحفظ: $e");
      return null;
    }
  }

  final Map<String, RxBool> showMinus = {};
  final Map<String, RxBool> tapInsideWidget = {};

  void setShowMinus(String productId, bool value) {
    showMinus.putIfAbsent(productId, () => false.obs);
    showMinus[productId]!.value = value;
  }

  bool getTapInside(String productId) =>
      tapInsideWidget[productId]?.value ?? false;

  void setTapInside(String productId, bool value) {
    tapInsideWidget.putIfAbsent(productId, () => false.obs);
    tapInsideWidget[productId]!.value = value;
  }

  final RxnString focusedProductId = RxnString();

  void focusOn(String productId) {
    focusedProductId.value = productId;
  }
}
