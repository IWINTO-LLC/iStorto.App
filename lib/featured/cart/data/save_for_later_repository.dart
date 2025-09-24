import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/services/supabase_service.dart';

class SaveForLaterRepository {
  static SaveForLaterRepository get instance => SaveForLaterRepository._();
  SaveForLaterRepository._();

  final _client = SupabaseService.client;

  /// Save item for later
  Future<void> saveItem(CartItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final itemData = {
        'user_id': user.id,
        'product_id': item.product.id,
        'vendor_id': item.product.vendorId,
        'title': item.product.title,
        'price': item.product.price,
        'quantity': item.quantity,
        'image':
            item.product.images.isNotEmpty ? item.product.images.first : null,
        'total_price': item.totalPrice,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('save_for_later')
          .upsert(itemData, onConflict: 'user_id,product_id');
    } catch (e) {
      throw Exception('Failed to save item for later: $e');
    }
  }

  /// Get all saved items for current user
  Future<List<CartItem>> getSavedItems() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('save_for_later')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<CartItem>((data) {
        final product = ProductModel(
          id: data['product_id'] ?? '',
          vendorId: data['vendor_id'],
          title: data['title'] ?? '',
          description: '', // Save for later doesn't store description
          price: (data['price'] ?? 0.0).toDouble(),
          images: data['image'] != null ? [data['image']] : [],
        );

        return CartItem(product: product, quantity: data['quantity'] ?? 1);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load saved items: $e');
    }
  }

  /// Remove item from saved items
  Future<void> removeItem(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from('save_for_later')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove saved item: $e');
    }
  }

  /// Clear all saved items for current user
  Future<void> clearAllSavedItems() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.from('save_for_later').delete().eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to clear saved items: $e');
    }
  }

  /// Check if item is saved for later
  Future<bool> isItemSaved(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final response =
          await _client
              .from('save_for_later')
              .select('id')
              .eq('user_id', user.id)
              .eq('product_id', productId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get saved items count for current user
  Future<int> getSavedItemsCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    try {
      final response = await _client
          .from('save_for_later')
          .select('id')
          .eq('user_id', user.id);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Move item from saved to cart
  Future<void> moveToCart(CartItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Check if item already exists in cart
      final existingCartItem =
          await _client
              .from('cart_items')
              .select('quantity')
              .eq('user_id', user.id)
              .eq('product_id', item.product.id)
              .maybeSingle();

      if (existingCartItem != null) {
        // Update quantity in cart
        final newQuantity =
            (existingCartItem['quantity'] as num).toInt() + item.quantity;
        await _client
            .from('cart_items')
            .update({
              'quantity': newQuantity,
              'total_price': newQuantity * item.product.price,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id)
            .eq('product_id', item.product.id);
      } else {
        // Add new item to cart
        final cartData = {
          'user_id': user.id,
          'product_id': item.product.id,
          'vendor_id': item.product.vendorId,
          'title': item.product.title,
          'price': item.product.price,
          'quantity': item.quantity,
          'image':
              item.product.images.isNotEmpty ? item.product.images.first : null,
          'total_price': item.totalPrice,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _client.from('cart_items').insert(cartData);
      }

      // Remove from saved items
      await removeItem(item.product.id);
    } catch (e) {
      throw Exception('Failed to move item to cart: $e');
    }
  }

  /// Move all saved items to cart
  Future<void> moveAllToCart() async {
    final savedItems = await getSavedItems();
    for (var item in savedItems) {
      await moveToCart(item);
    }
  }
}
