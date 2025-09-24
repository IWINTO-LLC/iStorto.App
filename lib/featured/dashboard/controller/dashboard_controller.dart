import 'package:get/get.dart';

class DashboardController extends GetxController {
  static DashboardController get instance => Get.find();

  RxInt count = 0.obs;

  void incrementCount() {
    count.value++;
  }
}
