import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrolleEditController extends GetxController {
  final ScrollController scrollController = ScrollController();

  void scrollToTop() {
    scrollController.animateTo(
      0.0, 
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut, 
    );
  }

  @override
  void onClose() {
    scrollController.dispose(); // تنظيف الذاكرة عند إغلاق الصفحة
    super.onClose();
  }
}
