import 'package:get/get.dart';

class EditingController extends GetxController {
  static EditingController get instance => Get.find();
  var localEditing = false.obs;
}
