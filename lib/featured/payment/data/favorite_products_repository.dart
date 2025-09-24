import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/logging/logger.dart';

class FavoriteProductsRepository {
  static FavoriteProductsRepository get instance =>
      FavoriteProductsRepository._();
  FavoriteProductsRepository._();

  final _client = SupabaseService.client;

  /// Save product to favorites
  Future<void> saveProduct(String userId, String productId) async {
    try {
      await _client.from('favorite_products').insert({
        'user_id': userId,
        'product_id': productId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      TLoggerHelper.error('Error saving favorite product: $e');
      throw Exception('Failed to save favorite product: $e');
    }
  }

  /// Remove product from favorites
  Future<void> removeProduct(String userId, String productId) async {
    try {
      await _client
          .from('favorite_products')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } catch (e) {
      TLoggerHelper.error('Error removing favorite product: $e');
      throw Exception('Failed to remove favorite product: $e');
    }
  }

  /// Get all favorite product IDs for a user
  Future<List<String>> getFavoriteProductIds(String userId) async {
    try {
      final response = await _client
          .from('favorite_products')
          .select('product_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => item['product_id'] as String)
          .toList();
    } catch (e) {
      TLoggerHelper.error('Error getting favorite product IDs: $e');
      return [];
    }
  }

  /// Check if product is favorited
  Future<bool> isProductFavorited(String userId, String productId) async {
    try {
      final response =
          await _client
              .from('favorite_products')
              .select('id')
              .eq('user_id', userId)
              .eq('product_id', productId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      TLoggerHelper.error('Error checking if product is favorited: $e');
      return false;
    }
  }

  /// Clear all favorites for a user
  Future<void> clearAllFavorites(String userId) async {
    try {
      await _client.from('favorite_products').delete().eq('user_id', userId);
    } catch (e) {
      TLoggerHelper.error('Error clearing all favorites: $e');
      throw Exception('Failed to clear all favorites: $e');
    }
  }

  /// Update all favorites for a user (replace existing)
  Future<void> updateAllFavorites(
    String userId,
    List<String> productIds,
  ) async {
    try {
      // Delete existing favorites
      await clearAllFavorites(userId);

      // Insert new favorites
      if (productIds.isNotEmpty) {
        final favoriteData =
            productIds
                .map(
                  (productId) => {
                    'user_id': userId,
                    'product_id': productId,
                    'created_at': DateTime.now().toIso8601String(),
                  },
                )
                .toList();

        await _client.from('favorite_products').insert(favoriteData);
      }
    } catch (e) {
      TLoggerHelper.error('Error updating all favorites: $e');
      throw Exception('Failed to update all favorites: $e');
    }
  }

  /// Get favorites count for a user
  Future<int> getFavoritesCount(String userId) async {
    try {
      final response = await _client
          .from('favorite_products')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      TLoggerHelper.error('Error getting favorites count: $e');
      return 0;
    }
  }

  /// Stream favorites for real-time updates
  Stream<List<String>> watchFavorites(String userId) {
    try {
      return _client
          .from('favorite_products')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map(
            (data) =>
                (data as List)
                    .map((item) => item['product_id'] as String)
                    .toList(),
          );
    } catch (e) {
      TLoggerHelper.error('Error watching favorites: $e');
      return Stream.value([]);
    }
  }
}







