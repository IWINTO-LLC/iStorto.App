import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/formatters/formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareServices {
  /// مشاركة منتج
  static Future<void> shareProduct(ProductModel product) async {
    try {
      // تسجيل المشاركة في قاعدة البيانات أولاً
      await _logShare('product', product.id);

      // تحميل الصورة
      XFile? image;
      if (product.images.isNotEmpty) {
        try {
          final imageUrl = Uri.parse(product.images.first);
          final response = await http.get(imageUrl);

          if (response.statusCode == 200) {
            final compressedBytes = await FlutterImageCompress.compressWithList(
              response.bodyBytes,
              quality: 60,
              minWidth: 600,
              minHeight: 600,
            );

            // كتابة الصورة المضغوطة إلى ملف
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/${product.id}_compressed.jpg';
            final file = File(filePath);
            await file.writeAsBytes(compressedBytes);
            image = XFile(file.path);
          }
        } catch (imageError) {
          if (kDebugMode) print("Error loading product image: $imageError");
        }
      }

      // إنشاء رابط المنتج
      final link = Uri.parse("https://istorto.com/product/${product.id}");

      // حساب السعر بالعملة المحلية
      final price = TFormatter.formateNumber(
        CurrencyController.instance.convertToDefaultCurrency(product.price),
      );
      final currency = CurrencyController.instance.currentUserCurrency;

      // إنشاء رسالة المشاركة
      final message = '''
شاهد هذا المنتج!
${product.title}
السعر: $price $currency
$link
''';

      // مشاركة المنتج
      if (image != null) {
        await Share.shareXFiles([image], text: message.trim());
      } else {
        await Share.share(message.trim());
      }

      if (kDebugMode) {
        print('✅ Product shared successfully: ${product.id}');
      }
    } catch (e) {
      if (kDebugMode) print("❌ shareProduct error: $e");
      rethrow;
    }
  }

  /// مشاركة متجر
  static Future<void> shareVendor(VendorModel vendor) async {
    try {
      // فحص البيانات الأساسية
      if (vendor.id?.isEmpty ?? true) {
        throw Exception('معرف المتجر غير متوفر');
      }

      // تسجيل المشاركة في قاعدة البيانات
      await _logShare('vendor', vendor.id!);

      XFile? image;
      final imageUrl =
          vendor.organizationLogo.isNotEmpty ? vendor.organizationLogo : null;

      // محاولة تحميل الصورة إذا كانت متوفرة
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/${vendor.id!}_vendor.jpg';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            image = XFile(file.path);
          }
        } catch (imageError) {
          if (kDebugMode) print("Error loading vendor image: $imageError");
        }
      }

      // إنشاء رابط المتجر (استخدم vendor.id بدلاً من userId)
      final link = "https://istorto.com/vendor/${vendor.id!}";
      final vendorName =
          vendor.organizationName.isNotEmpty ? vendor.organizationName : 'متجر';

      final message = '''
تعرّف على المتجر:
$vendorName

🌐 زوروا الحساب:
$link
''';

      // مشاركة المتجر
      if (image != null) {
        await Share.shareXFiles([image], text: message.trim());
      } else {
        await Share.share(message.trim());
      }

      if (kDebugMode) {
        print('✅ Vendor shared successfully: ${vendor.id!}');
      }
    } catch (e) {
      if (kDebugMode) print("❌ shareVendor error: $e");
      rethrow;
    }
  }

  /// تسجيل المشاركة في قاعدة البيانات
  static Future<void> _logShare(String shareType, String entityId) async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.userId;

      // استدعاء دالة log_share في Supabase
      await SupabaseService.client.rpc(
        'log_share',
        params: {
          'p_share_type': shareType,
          'p_entity_id': entityId,
          'p_user_id': userId,
          'p_device_type': Platform.operatingSystem,
          'p_share_method': 'share_plus',
        },
      );

      if (kDebugMode) {
        print('✅ Share logged: $shareType - $entityId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to log share: $e');
      }
      // لا نرمي الخطأ لأن فشل التسجيل لا يجب أن يمنع المشاركة
    }
  }

  /// الحصول على عدد المشاركات لمنتج
  static Future<int> getProductShareCount(String productId) async {
    try {
      final result = await SupabaseService.client.rpc(
        'get_share_count',
        params: {'p_share_type': 'product', 'p_entity_id': productId},
      );

      return result as int? ?? 0;
    } catch (e) {
      if (kDebugMode) print('Error getting product share count: $e');
      return 0;
    }
  }

  /// الحصول على عدد المشاركات لمتجر
  static Future<int> getVendorShareCount(String vendorId) async {
    try {
      final result = await SupabaseService.client.rpc(
        'get_share_count',
        params: {'p_share_type': 'vendor', 'p_entity_id': vendorId},
      );

      return result as int? ?? 0;
    } catch (e) {
      if (kDebugMode) print('Error getting vendor share count: $e');
      return 0;
    }
  }

  /// الحصول على أكثر المنتجات مشاركة
  static Future<List<Map<String, dynamic>>> getMostSharedProducts({
    int limit = 10,
  }) async {
    try {
      final result =
          await SupabaseService.client.rpc(
                'get_most_shared_products',
                params: {'p_limit': limit},
              )
              as List;

      return result.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) print('Error getting most shared products: $e');
      return [];
    }
  }

  /// الحصول على أكثر المتاجر مشاركة
  static Future<List<Map<String, dynamic>>> getMostSharedVendors({
    int limit = 10,
  }) async {
    try {
      final result =
          await SupabaseService.client.rpc(
                'get_most_shared_vendors',
                params: {'p_limit': limit},
              )
              as List;

      return result.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) print('Error getting most shared vendors: $e');
      return [];
    }
  }
}
