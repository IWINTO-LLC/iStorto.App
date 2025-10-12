import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/views/vendor/product_details_page.dart';

/// خدمة معالجة الروابط العميقة
/// Deep Link Handler Service
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  bool _isInitialized = false;

  /// تهيئة خدمة Deep Links
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // معالجة الرابط الأولي (عند فتح التطبيق من رابط)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri.toString());
      }

      // الاستماع للروابط الجديدة (عند التطبيق مفتوح)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri.toString());
          }
        },
        onError: (err) {
          if (kDebugMode) {
            print('❌ Deep Link Error: $err');
          }
        },
      );

      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Deep Link Service initialized with app_links');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Deep Link Service: $e');
      }
    }
  }

  /// معالجة الرابط العميق
  Future<void> _handleDeepLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (kDebugMode) {
        print('🔗 Deep Link received: $link');
        print('   Host: ${uri.host}');
        print('   Path: ${uri.path}');
      }

      // التحقق من النطاق
      if (uri.host != 'istorto.com' && uri.scheme != 'istoreto') {
        if (kDebugMode) {
          print('⚠️ Invalid host: ${uri.host}');
        }
        return;
      }

      // معالجة المسارات المختلفة
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return;

      switch (pathSegments[0]) {
        case 'product':
          await _handleProductLink(pathSegments);
          break;
        case 'vendor':
          await _handleVendorLink(pathSegments);
          break;
        default:
          if (kDebugMode) {
            print('⚠️ Unknown path: ${pathSegments[0]}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling deep link: $e');
      }
    }
  }

  /// معالجة رابط المنتج
  Future<void> _handleProductLink(List<String> pathSegments) async {
    try {
      if (pathSegments.length < 2) {
        if (kDebugMode) {
          print('⚠️ Invalid product link format');
        }
        return;
      }

      final productId = pathSegments[1];
      if (kDebugMode) {
        print('📦 Opening product: $productId');
      }

      // الحصول على بيانات المنتج
      final productController = Get.find<ProductController>();
      final product = await productController.getProductById(productId);

      if (product == null) {
        _showErrorSnackbar('المنتج غير موجود', 'Product not found');
        return;
      }

      // الانتقال لصفحة تفاصيل المنتج
      await Get.to(
        () => ProductDetailsPage(product: product),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );

      if (kDebugMode) {
        print('✅ Navigated to product: ${product.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling product link: $e');
      }
      _showErrorSnackbar('فشل فتح المنتج', 'Failed to open product');
    }
  }

  /// معالجة رابط المتجر
  Future<void> _handleVendorLink(List<String> pathSegments) async {
    try {
      if (pathSegments.length < 2) {
        if (kDebugMode) {
          print('⚠️ Invalid vendor link format');
        }
        return;
      }

      final vendorId = pathSegments[1];
      if (kDebugMode) {
        print('🏪 Opening vendor: $vendorId');
      }

      // الحصول على بيانات المتجر
      final vendorController = Get.find<VendorController>();
      await vendorController.fetchVendorData(vendorId);

      if (vendorController.vendorData.value.id == null) {
        _showErrorSnackbar('المتجر غير موجود', 'Vendor not found');
        return;
      }

      // الانتقال لصفحة المتجر
      await Get.to(
        () => MarketPlaceView(vendorId: vendorId, editMode: false),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );

      if (kDebugMode) {
        print(
          '✅ Navigated to vendor: ${vendorController.vendorData.value.organizationName}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling vendor link: $e');
      }
      _showErrorSnackbar('فشل فتح المتجر', 'Failed to open vendor');
    }
  }

  /// عرض رسالة خطأ
  void _showErrorSnackbar(String messageAr, String messageEn) {
    Get.snackbar(
      'خطأ',
      messageAr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  /// إلغاء الاشتراك عند إغلاق التطبيق
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
  }
}
