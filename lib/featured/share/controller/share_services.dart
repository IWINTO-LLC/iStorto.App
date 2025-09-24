import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:istoreto/featured/shop/data/vendor_model.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';

import 'package:istoreto/utils/formatters/formatter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ShareServices {
  static Future<void> shareProduct(ProductModel product) async {
    try {
      //  تحميل الصورة
      final imageUrl = Uri.parse(product.images?.first ?? '');
      final response = await http.get(imageUrl);
      final compressedBytes = await FlutterImageCompress.compressWithList(
        response.bodyBytes,
        quality: 60,
        minWidth: 600,
        minHeight: 600,
      );

      //  كتابة الصورة المضغوطة إلى ملف
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${product.id}_compressed.jpg';
      final file = File(filePath);
      await file.writeAsBytes(compressedBytes);
      final image = XFile(file.path);
      final link = Uri.parse("https://iwinto.com/product/${product.id}");
      final price = TFormatter.formateNumber(
        CurrencyController.instance.convertToDefaultCurrency(product.price),
      );
      final currency = CurrencyController.instance.currentUserCurrency;

      final message = '''
شاهد هذا المنتج!
${product.title}
السعر: $price $currency
$link
''';

      await Share.shareXFiles([image], text: message.trim());
    } catch (e) {
      if (kDebugMode) print(" shareProduct error: $e");
    }
  }

  static Future<void> shareVendor(VendorModel vendor) async {
    try {
      // فحص البيانات الأساسية
      if (vendor.userId == null || vendor.userId!.isEmpty) {
        throw Exception('معرف المتجر غير متوفر');
      }

      XFile? image;
      final imageUrl =
          vendor.organizationLogo.isNotEmpty ? vendor.organizationLogo : null;

      // محاولة تحميل الصورة إذا كانت متوفرة
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/${vendor.userId}_vendor.jpg';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            image = XFile(file.path);
          }
        } catch (imageError) {
          if (kDebugMode) print("Error loading image: $imageError");
          // استمر بدون صورة
        }
      }

      final link = "https://iwinto.com/vendor/${vendor.userId}";
      final vendorName =
          vendor.organizationName.isNotEmpty ? vendor.organizationName : 'متجر';
      final message = '''
تعرّف على المتجر:
$vendorName

🌐 زوروا الحساب:
$link
''';

      if (image != null) {
        await Share.shareXFiles([image], text: message.trim());
      } else {
        await Share.share(message.trim());
      }
    } catch (e) {
      if (kDebugMode) print("shareVendor error: $e");
      rethrow; // إعادة رمي الخطأ للمعالجة في الواجهة
    }
  }
}
