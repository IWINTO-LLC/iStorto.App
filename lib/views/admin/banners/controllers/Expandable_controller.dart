import 'package:get/get.dart';

class ExpandableController extends GetxController {
  final RxBool _isExpanded = false.obs;

  bool get isExpanded => _isExpanded.value;

  void toggleExpansion() {
    _isExpanded.value = !_isExpanded.value;
  }

  void expand() {
    _isExpanded.value = true;
  }

  void collapse() {
    _isExpanded.value = false;
  }
}
