import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/logging/logger.dart';

class TempProductRepository {
  static TempProductRepository get instance => TempProductRepository._();
  TempProductRepository._();

  final _client = SupabaseService.client;

  /// Create a new temporary product
  Future<String> createTempProduct(ProductModel product) async {
    try {
      final response =
          await _client
              .from('temp_products')
              .insert(product.toJson())
              .select('id')
              .single();

      TLoggerHelper.info('Temp product created with ID: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      TLoggerHelper.error('Error creating temp product: $e');
      rethrow;
    }
  }

  /// Get temporary product by ID
  Future<ProductModel?> getTempProductById(String id) async {
    try {
      final response =
          await _client.from('temp_products').select('*').eq('id', id).single();

      return _mapToProductModel(response);
    } catch (e) {
      TLoggerHelper.error('Error getting temp product by ID: $e');
      return null;
    }
  }

  /// Get all temporary products for a vendor
  Future<List<ProductModel>> getTempProductsByVendor(String vendorId) async {
    try {
      final response = await _client
          .from('temp_products')
          .select('''
            *,
            categories:category_id(*),
            vendor_categories:vendor_category_id(*)
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response
          .map<ProductModel>((data) => _mapToProductModel(data))
          .toList();
    } catch (e) {
      TLoggerHelper.error('Error getting temp products by vendor: $e');
      return [];
    }
  }

  /// Update temporary product
  Future<bool> updateTempProduct(ProductModel product) async {
    try {
      await _client
          .from('temp_products')
          .update(product.toJson())
          .eq('id', product.id);

      TLoggerHelper.info('Temp product updated: ${product.id}');
      return true;
    } catch (e) {
      TLoggerHelper.error('Error updating temp product: $e');
      return false;
    }
  }

  /// Delete temporary product
  Future<bool> deleteTempProduct(String productId) async {
    try {
      await _client
          .from('temp_products')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      TLoggerHelper.info('Temp product deleted: $productId');
      return true;
    } catch (e) {
      TLoggerHelper.error('Error deleting temp product: $e');
      return false;
    }
  }

  /// Bulk delete temporary products
  Future<bool> bulkDeleteTempProducts(List<String> productIds) async {
    try {
      await _client
          .from('temp_products')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', productIds);

      TLoggerHelper.info('Bulk deleted ${productIds.length} temp products');
      return true;
    } catch (e) {
      TLoggerHelper.error('Error bulk deleting temp products: $e');
      return false;
    }
  }

  /// Activate temporary product (move to main products table)
  Future<bool> activateTempProduct(ProductModel product) async {
    try {
      // First, create the product in main products table
      final productResponse =
          await _client
              .from('products')
              .insert(product.toJson())
              .select('id')
              .single();

      // Then mark temp product as deleted
      await deleteTempProduct(product.id);

      TLoggerHelper.info(
        'Temp product activated: ${product.id} -> ${productResponse['id']}',
      );
      return true;
    } catch (e) {
      TLoggerHelper.error('Error activating temp product: $e');
      return false;
    }
  }

  /// Bulk activate temporary products
  Future<bool> bulkActivateTempProducts(List<ProductModel> products) async {
    try {
      for (final product in products) {
        await activateTempProduct(product);
      }

      TLoggerHelper.info('Bulk activated ${products.length} temp products');
      return true;
    } catch (e) {
      TLoggerHelper.error('Error bulk activating temp products: $e');
      return false;
    }
  }

  /// Update product category
  Future<bool> updateProductCategory(
    String productId,
    CategoryModel category,
  ) async {
    try {
      await _client
          .from('temp_products')
          .update({
            'category_id': category.id,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      TLoggerHelper.info('Updated product category: $productId');
      return true;
    } catch (e) {
      TLoggerHelper.error('Error updating product category: $e');
      return false;
    }
  }

  /// Update product sector
  Future<bool> updateProductSector(String productId, SectorModel sector) async {
    try {
      await _client
          .from('temp_products')
          .update({
            'product_type': sector.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      TLoggerHelper.info('Updated product sector: $productId');
      return true;
    } catch (e) {
      TLoggerHelper.error('Error updating product sector: $e');
      return false;
    }
  }

  /// Get temp products count by vendor
  Future<int> getTempProductsCount(String vendorId) async {
    try {
      final response = await _client
          .from('temp_products')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false);

      return response.length;
    } catch (e) {
      TLoggerHelper.error('Error getting temp products count: $e');
      return 0;
    }
  }

  /// Search temporary products
  Future<List<ProductModel>> searchTempProducts(
    String vendorId,
    String query,
  ) async {
    try {
      final response = await _client
          .from('temp_products')
          .select('''
            *,
            categories:category_id(*),
            vendor_categories:vendor_category_id(*)
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false)
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return response
          .map<ProductModel>((data) => _mapToProductModel(data))
          .toList();
    } catch (e) {
      TLoggerHelper.error('Error searching temp products: $e');
      return [];
    }
  }

  /// Map database response to ProductModel
  ProductModel _mapToProductModel(Map<String, dynamic> data) {
    return ProductModel.fromJson(data);
  }
}
