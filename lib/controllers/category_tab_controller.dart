
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTabControllerX extends GetxController {
  var selectedIndex = 0.obs;
  FocusNode arabicFocusNode = FocusNode();
  FocusNode englishFocusNode = FocusNode();

  void changeTab(int index) {
    selectedIndex.value = index;
    if (index == 0) {
      arabicFocusNode.requestFocus();
    } else {
      englishFocusNode.requestFocus();
    }
  }
}
