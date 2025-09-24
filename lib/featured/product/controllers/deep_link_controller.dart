import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/views/saved_products_list.dart';

class DeepLinkController extends GetxController {
  void handleDeepLink(Uri? uri) {
    if (uri != null && uri.pathSegments.isNotEmpty) {
      // استخراج كود المنتج

      Navigator.push(
        Get.context!,
        MaterialPageRoute(builder: (context) => SavedProductsPage()),
      ); // التوجيه إلى صفحة المنتج
    }
  }
}
