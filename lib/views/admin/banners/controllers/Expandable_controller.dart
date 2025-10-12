import 'package:get/get.dart';

class ExpandableController extends GetxController {
  bool isExpanded = false;

  void toggleExpansion() {
    isExpanded = !isExpanded;
    update();
  }
}
