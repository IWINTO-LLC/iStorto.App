import 'package:get/get.dart';

class ProductSelectedController extends GetxController {
  var selectedProducts = <String>[].obs; // المنتجات المحددة
  var isSelecting = false.obs; // وضع التحديد

  void toggleSelection(String productId) {
    if (selectedProducts.contains(productId)) {
      selectedProducts.remove(productId);
    } else {
      selectedProducts.add(productId);
    }
  }

  void startSelectionMode(String productId) {
    isSelecting.value = true;
    toggleSelection(productId);
  }

  void stopSelectionMode() {
    isSelecting.value = false;
    selectedProducts.clear();
  }
}
