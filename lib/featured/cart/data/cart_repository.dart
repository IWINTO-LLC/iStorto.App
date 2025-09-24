import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/services/supabase_service.dart';

class CartRepository {
  static CartRepository get instance => CartRepository._();
  CartRepository._();

  final _client = SupabaseService.client;

  /// Save cart items to Supabase
  Future<void> saveCartItems(List<CartItem> cartItems) async {
    final user = _client.auth.currentUser;
    if (user == null || cartItems.isEmpty) return;

    try {
      // Delete existing cart items for this user
      await _client.from('cart_items').delete().eq('user_id', user.id);

      // Insert new cart items
      if (cartItems.isNotEmpty) {
        final cartData =
            cartItems
                .map(
                  (item) => {
                    'user_id': user.id,
                    'product_id': item.product.id,
                    'vendor_id': item.product.vendorId,
                    'title': item.product.title,
                    'price': item.product.price,
                    'quantity': item.quantity,
                    'image':
                        item.product.images.isNotEmpty
                            ? item.product.images.first
                            : null,
                    'total_price': item.totalPrice,
                    'created_at': DateTime.now().toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                  },
                )
                .toList();

        await _client.from('cart_items').insert(cartData);
      }
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  /// Load cart items from Supabase
  Future<List<CartItem>> loadCartItems() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('cart_items')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      return response.map<CartItem>((data) {
        final product = ProductModel(
          id: data['product_id'] ?? '',
          vendorId: data['vendor_id'],
          title: data['title'] ?? '',
          description: '', // Cart doesn't store description
          price: (data['price'] ?? 0.0).toDouble(),
          images: data['image'] != null ? [data['image']] : [],
        );

        return CartItem(product: product, quantity: data['quantity'] ?? 1);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  /// Clear all cart items for current user
  Future<void> clearCart() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.from('cart_items').delete().eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  /// Remove specific product from cart
  Future<void> removeProductFromCart(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from('cart_items')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove product from cart: $e');
    }
  }

  /// Update product quantity in cart
  Future<void> updateProductQuantity(String productId, int quantity) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      if (quantity <= 0) {
        await removeProductFromCart(productId);
      } else {
        await _client
            .from('cart_items')
            .update({
              'quantity': quantity,
              'total_price': quantity * (await _getProductPrice(productId)),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id)
            .eq('product_id', productId);
      }
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }

  /// Get product price from cart items
  Future<double> _getProductPrice(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return 0.0;

    try {
      final response =
          await _client
              .from('cart_items')
              .select('price')
              .eq('user_id', user.id)
              .eq('product_id', productId)
              .single();

      return (response['price'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Get cart items count for current user
  Future<int> getCartItemsCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    try {
      final response = await _client
          .from('cart_items')
          .select('quantity')
          .eq('user_id', user.id);

      return response.fold<int>(
        0,
        (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
      );
    } catch (e) {
      return 0;
    }
  }

  /// Get total cart value for current user
  Future<double> getCartTotalValue() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0.0;

    try {
      final response = await _client
          .from('cart_items')
          .select('total_price')
          .eq('user_id', user.id);

      return response.fold<double>(
        0.0,
        (sum, item) => sum + (item['total_price'] ?? 0.0),
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if product exists in cart
  Future<bool> isProductInCart(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final response =
          await _client
              .from('cart_items')
              .select('id')
              .eq('user_id', user.id)
              .eq('product_id', productId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get product quantity in cart
  Future<int> getProductQuantity(String productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    try {
      final response =
          await _client
              .from('cart_items')
              .select('quantity')
              .eq('user_id', user.id)
              .eq('product_id', productId)
              .maybeSingle();

      return response?['quantity'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
