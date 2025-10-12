import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/models/product_image_model.dart';
import 'package:istoreto/services/supabase_service.dart';

/// مستودع صور المنتجات
/// Product Images Repository
class ProductImageRepository extends GetxController {
  static ProductImageRepository get instance => Get.find();

  /// الحصول على جميع صور المنتجات للمعرض
  Future<List<ProductImageModel>> getAllProductImages({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('product_images_gallery')
          .select()
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ProductImageModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching product images: $e');
      }
      return [];
    }
  }

  /// الحصول على صور منتج معين
  Future<List<ProductImageModel>> getProductImages(String productId) async {
    try {
      final response = await SupabaseService.client
          .from('product_images')
          .select()
          .eq('product_id', productId)
          .order('image_order', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ProductImageModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching images for product $productId: $e');
      }
      return [];
    }
  }

  /// إضافة صور لمنتج
  Future<bool> addProductImages({
    required String productId,
    required List<String> imageUrls,
  }) async {
    try {
      final images = imageUrls.asMap().entries.map((entry) {
        return {
          'product_id': productId,
          'image_url': entry.value,
          'image_order': entry.key,
          'is_thumbnail': entry.key == 0,
        };
      }).toList();

      await SupabaseService.client.from('product_images').insert(images);

      if (kDebugMode) {
        print('✅ Added ${images.length} images for product: $productId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding product images: $e');
      }
      return false;
    }
  }

  /// حذف صورة
  Future<bool> deleteProductImage(String imageId) async {
    try {
      await SupabaseService.client
          .from('product_images')
          .delete()
          .eq('id', imageId);

      if (kDebugMode) {
        print('✅ Deleted image: $imageId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting image: $e');
      }
      return false;
    }
  }

  /// حذف جميع صور منتج
  Future<bool> deleteAllProductImages(String productId) async {
    try {
      await SupabaseService.client
          .from('product_images')
          .delete()
          .eq('product_id', productId);

      if (kDebugMode) {
        print('✅ Deleted all images for product: $productId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting product images: $e');
      }
      return false;
    }
  }

  /// تحديث ترتيب الصور
  Future<bool> updateImageOrder({
    required String imageId,
    required int newOrder,
  }) async {
    try {
      await SupabaseService.client
          .from('product_images')
          .update({'image_order': newOrder})
          .eq('id', imageId);

      if (kDebugMode) {
        print('✅ Updated image order: $imageId → $newOrder');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating image order: $e');
      }
      return false;
    }
  }

  /// تعيين صورة كـ thumbnail
  Future<bool> setAsThumbnail({
    required String productId,
    required String imageId,
  }) async {
    try {
      // إزالة is_thumbnail من جميع صور المنتج
      await SupabaseService.client
          .from('product_images')
          .update({'is_thumbnail': false})
          .eq('product_id', productId);

      // تعيين الصورة المحددة كـ thumbnail
      await SupabaseService.client
          .from('product_images')
          .update({'is_thumbnail': true})
          .eq('id', imageId);

      if (kDebugMode) {
        print('✅ Set thumbnail for product: $productId → $imageId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting thumbnail: $e');
      }
      return false;
    }
  }

  /// البحث في الصور
  Future<List<ProductImageModel>> searchProductImages(String query) async {
    try {
      final response = await SupabaseService.client
          .from('product_images_gallery')
          .select()
          .or('product_title.ilike.%$query%,vendor_name.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ProductImageModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching product images: $e');
      }
      return [];
    }
  }

  /// الحصول على صور حسب التاجر
  Future<List<ProductImageModel>> getVendorProductImages(String vendorId) async {
    try {
      final response = await SupabaseService.client
          .from('product_images_gallery')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false)
          .limit(100);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ProductImageModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching vendor images: $e');
      }
      return [];
    }
  }
}

