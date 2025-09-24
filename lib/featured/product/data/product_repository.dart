import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_model.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get active (non-deleted) products for a vendor
  Future<List<ProductModel>> getProducts(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products: $e");
      }
      throw 'Failed to get products: ${e.toString()}';
    }
  }

  // Get all products for a vendor (including deleted)
  Future<List<ProductModel>> getAllProducts(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting all products: $e");
      }
      throw 'Failed to get all products: ${e.toString()}';
    }
  }

  // Get all products for a vendor
  Future<List<ProductModel>> getProductsByVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Products Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products: $e");
      }
      throw 'Failed to get products: ${e.toString()}';
    }
  }

  // Get featured products for a vendor
  Future<List<ProductModel>> getFeaturedProducts(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_feature', true)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      if (kDebugMode) {
        print("=======Featured Products==============");
        print("Count: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting featured products: $e");
      }
      throw 'Failed to get featured products: ${e.toString()}';
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      if (productId.isEmpty) {
        throw 'Product ID is required';
      }

      final response =
          await _client
              .from('products')
              .select('''
                *,
                category:categories!category_id(
                  id,
                  title,
                  icon,
                  color,
                  is_active,
                  created_at,
                  updated_at
                )
              ''')
              .eq('id', productId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProductModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting product by ID: $e");
      }
      throw 'Failed to get product: ${e.toString()}';
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
    required String vendorId,
    int limit = 20,
  }) async {
    try {
      if (categoryId.isEmpty || vendorId.isEmpty) {
        throw 'Category ID and Vendor ID are required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('category_id', categoryId)
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(limit);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      if (kDebugMode) {
        print("=======Products by Category==============");
        print("Category: $categoryId, Count: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products by category: $e");
      }
      throw 'Failed to get products by category: ${e.toString()}';
    }
  }

  // Get products by type
  Future<List<ProductModel>> getProductsByType(
    String vendorId,
    String type,
  ) async {
    try {
      if (vendorId.isEmpty || type.isEmpty) {
        throw 'Vendor ID and Product Type are required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .eq('product_type', type)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      if (kDebugMode) {
        print("=======Products by Type==============");
        print("Type: $type, Count: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products by type: $e");
      }
      throw 'Failed to get products by type: ${e.toString()}';
    }
  }

  // Create new product
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      if (!product.isValid) {
        throw 'Product data is invalid';
      }

      final response =
          await _client
              .from('products')
              .insert(product.toJson())
              .select()
              .single();

      if (kDebugMode) {
        print("=======Created Product==============");
        print(response.toString());
      }

      return ProductModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating product: $e");
      }
      throw 'Failed to create product: ${e.toString()}';
    }
  }

  // Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      if (product.id.isEmpty) {
        throw 'Product ID is required for update';
      }

      final updatedProduct = product.updateTimestamp();
      final response =
          await _client
              .from('products')
              .update(updatedProduct.toJson())
              .eq('id', product.id)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Product==============");
        print(response.toString());
      }

      return ProductModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating product: $e");
      }
      throw 'Failed to update product: ${e.toString()}';
    }
  }

  // Bulk update products
  Future<void> updateBulkProducts(List<ProductModel> products) async {
    try {
      if (products.isEmpty) {
        throw 'Products list is empty';
      }

      for (final product in products) {
        if (product.id.isNotEmpty) {
          final updatedProduct = product.updateTimestamp();
          await _client
              .from('products')
              .update(updatedProduct.toJson())
              .eq('id', product.id);
        }
      }

      if (kDebugMode) {
        print("=======Bulk Updated Products==============");
        print("Count: ${products.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error bulk updating products: $e");
      }
      throw 'Failed to bulk update products: ${e.toString()}';
    }
  }

  // Delete product (soft delete)
  Future<void> deleteProduct(String productId) async {
    try {
      if (productId.isEmpty) {
        throw 'Product ID is required';
      }

      await _client
          .from('products')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      if (kDebugMode) {
        print("Product deleted successfully: $productId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting product: $e");
      }
      throw 'Failed to delete product: ${e.toString()}';
    }
  }

  // Permanently delete product
  Future<void> permanentlyDeleteProduct(String productId) async {
    try {
      if (productId.isEmpty) {
        throw 'Product ID is required';
      }

      await _client.from('products').delete().eq('id', productId);

      if (kDebugMode) {
        print("Product permanently deleted: $productId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error permanently deleting product: $e");
      }
      throw 'Failed to permanently delete product: ${e.toString()}';
    }
  }

  // Bulk delete products
  Future<void> bulkDeleteProducts(List<String> productIds) async {
    try {
      if (productIds.isEmpty) {
        throw 'Product IDs list is empty';
      }

      for (final productId in productIds) {
        await _client
            .from('products')
            .update({
              'is_deleted': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', productId);
      }

      if (kDebugMode) {
        print("Bulk deleted products: ${productIds.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error bulk deleting products: $e");
      }
      throw 'Failed to bulk delete products: ${e.toString()}';
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(
    String query, {
    String? vendorId,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:categories!category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .ilike('title', '%$query%')
          .eq('is_deleted', false)
          .eq('vendor_id', vendorId ?? '')
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      if (kDebugMode) {
        print("=======Search Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching products: $e");
      }
      throw 'Failed to search products: ${e.toString()}';
    }
  }

  // Get products by IDs
  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    try {
      if (productIds.isEmpty) {
        return [];
      }

      List<ProductModel> resultList = [];

      for (final productId in productIds) {
        final response =
            await _client
                .from('products')
                .select('''
                  *,
                  category:categories!category_id(
                    id,
                    title,
                    icon,
                    color,
                    is_active,
                    created_at,
                    updated_at
                  )
                ''')
                .eq('id', productId)
                .eq('is_deleted', false)
                .maybeSingle();

        if (response != null) {
          resultList.add(ProductModel.fromJson(response));
        }
      }

      if (kDebugMode) {
        print("=======Products by IDs==============");
        print("Requested: ${productIds.length}, Found: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products by IDs: $e");
      }
      throw 'Failed to get products by IDs: ${e.toString()}';
    }
  }

  // Get products count for vendor
  Future<int> getProductsCount(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products count: $e");
      }
      throw 'Failed to get products count: ${e.toString()}';
    }
  }

  // Toggle product feature status
  Future<void> toggleProductFeature(String productId, bool isFeature) async {
    try {
      if (productId.isEmpty) {
        throw 'Product ID is required';
      }

      await _client
          .from('products')
          .update({
            'is_feature': isFeature,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      if (kDebugMode) {
        print("Product feature toggled: $productId -> $isFeature");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling product feature: $e");
      }
      throw 'Failed to toggle product feature: ${e.toString()}';
    }
  }

  // Update product price
  Future<void> updateProductPrice(
    String productId,
    double newPrice, {
    double? oldPrice,
  }) async {
    try {
      if (productId.isEmpty) {
        throw 'Product ID is required';
      }

      final updateData = {
        'price': newPrice,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (oldPrice != null) {
        updateData['old_price'] = oldPrice;
      }

      await _client.from('products').update(updateData).eq('id', productId);

      if (kDebugMode) {
        print("Product price updated: $productId -> $newPrice");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating product price: $e");
      }
      throw 'Failed to update product price: ${e.toString()}';
    }
  }

  // Get user product count
  Future<int> getUserProductCount(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('products')
          .select('id')
          .eq('vendor_id', userId)
          .eq('is_deleted', false);

      if (kDebugMode) {
        print("=======User Product Count==============");
        print("User ID: $userId");
        print("Count: ${(response as List).length}");
      }

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user product count: $e");
      }
      throw 'Failed to get user product count: ${e.toString()}';
    }
  }
}
