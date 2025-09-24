import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabControllerX extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabControllerX(this.vendorId);
  late TabController tabController;
  var sections = <Map<String, dynamic>>[].obs;
  late String vendorId;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: sections.length + 1, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
