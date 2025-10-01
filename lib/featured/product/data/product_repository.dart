import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_model.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();
  final _client = Supabase.instance.client;
  final CurrencyController _currencyController = Get.find<CurrencyController>();
  final ProductCurrencyService _currencyService =
      Get.find<ProductCurrencyService>();

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
            category:vendor_categories!vendor_category_id(
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
            category:vendor_categories!vendor_category_id(
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
            category:vendor_categories!vendor_category_id(
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
            category:vendor_categories!vendor_category_id(
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
                category:vendor_categories!vendor_category_id(
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
            category:vendor_categories!vendor_category_id(
              id,
              title,
              icon,
              color,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_category_id', categoryId)
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
            category:vendor_categories!vendor_category_id(
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

  // Get products by type using vendor_categories (for market place view)
  Future<List<ProductModel>> getProductsByTypeForVendor(
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
            category:vendor_categories!vendor_category_id(
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
        print("=======Products by Type for Vendor==============");
        print("Vendor ID: $vendorId, Type: $type, Count: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products by type for vendor: $e");
      }
      throw 'Failed to get products by type for vendor: ${e.toString()}';
    }
  }

  // Create new product
  Future<ProductModel> createProduct(ProductModel product) async {
    product.vendorId = VendorController.instance.profileData.value.id;
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
            category:vendor_categories!vendor_category_id(
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
                  category:vendor_categories!vendor_category_id(
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
  Future<int> getUserProductCount(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false);

      if (kDebugMode) {
        print("=======User Product Count==============");
        print("User ID: $vendorId");
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

  // ============ CURRENCY-AWARE PRODUCT METHODS ============

  // Get products converted to user's preferred currency
  Future<List<ProductModel>> getProductsInUserCurrency(String vendorId) async {
    try {
      final products = await getProducts(vendorId);
      final userCurrency =
          _currencyController.currentUserCurrency.isNotEmpty
              ? _currencyController.currentUserCurrency
              : 'USD';

      return _currencyService.convertProductsCurrency(products, userCurrency);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products in user currency: $e");
      }
      throw 'Failed to get products in user currency: ${e.toString()}';
    }
  }

  // Get products in specific currency
  Future<List<ProductModel>> getProductsInCurrency(
    String vendorId,
    String targetCurrency,
  ) async {
    try {
      final products = await getProducts(vendorId);
      return _currencyService.convertProductsCurrency(products, targetCurrency);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products in currency: $e");
      }
      throw 'Failed to get products in currency: ${e.toString()}';
    }
  }

  // Get single product in user currency
  Future<ProductModel?> getProductInUserCurrency(String productId) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return null;

      final userCurrency =
          _currencyController.currentUserCurrency.isNotEmpty
              ? _currencyController.currentUserCurrency
              : 'USD';

      return _currencyService.convertProductToCurrency(product, userCurrency);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting product in user currency: $e");
      }
      throw 'Failed to get product in user currency: ${e.toString()}';
    }
  }

  // Get single product in specific currency
  Future<ProductModel?> getProductInCurrency(
    String productId,
    String targetCurrency,
  ) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return null;

      return _currencyService.convertProductToCurrency(product, targetCurrency);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting product in currency: $e");
      }
      throw 'Failed to get product in currency: ${e.toString()}';
    }
  }

  // Update product with currency information
  Future<bool> updateProductCurrency(String productId, String currency) async {
    try {
      if (productId.isEmpty) {
        throw 'Product ID is required';
      }

      if (currency.isEmpty) {
        throw 'Currency is required';
      }

      await _client
          .from('products')
          .update({
            'currency': currency.toUpperCase(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      if (kDebugMode) {
        print("Product currency updated successfully");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error updating product currency: $e");
      }
      throw 'Failed to update product currency: ${e.toString()}';
    }
  }

  // Get products by currency
  Future<List<ProductModel>> getProductsByCurrency(
    String vendorId,
    String currency,
  ) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('products')
          .select('''
            *,
            category:vendor_categories!vendor_category_id(
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
          .eq('currency', currency.toUpperCase())
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => ProductModel.fromJson(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting products by currency: $e");
      }
      throw 'Failed to get products by currency: ${e.toString()}';
    }
  }

  // Get currency statistics for vendor products
  Future<Map<String, int>> getProductCurrencyStats(String vendorId) async {
    try {
      final response = await _client
          .from('products')
          .select('currency')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false);

      final stats = <String, int>{};

      for (final item in response as List) {
        final currency = item['currency'] ?? 'USD';
        stats[currency] = (stats[currency] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting product currency stats: $e");
      }
      throw 'Failed to get product currency stats: ${e.toString()}';
    }
  }

  // Bulk update products currency
  Future<bool> bulkUpdateProductsCurrency(
    List<String> productIds,
    String currency,
  ) async {
    try {
      if (productIds.isEmpty) {
        throw 'Product IDs are required';
      }

      if (currency.isEmpty) {
        throw 'Currency is required';
      }

      await _client
          .from('products')
          .update({
            'currency': currency.toUpperCase(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', productIds);

      if (kDebugMode) {
        print("Bulk currency update completed successfully");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error bulk updating products currency: $e");
      }
      throw 'Failed to bulk update products currency: ${e.toString()}';
    }
  }
}
