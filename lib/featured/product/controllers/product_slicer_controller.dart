import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductImageSliderController extends GetxController {
  RxInt imageSliderIndex = 1.obs;
  PageController pageController = PageController();
  setImageSliderSelectedIndex(int selectedIndex) {
    imageSliderIndex.value = selectedIndex;
    //pageController.animateToPage(selectedIndex,
    //    duration: const Duration(microseconds: 50), curve: Curves.ease);
  }
}
