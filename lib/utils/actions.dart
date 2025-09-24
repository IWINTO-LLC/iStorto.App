import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/floating_button_client_controller.dart';
import 'package:istoreto/featured/product/controllers/floating_button_vendor_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';

class ActionsMethods {
  static GestureDetector customLongMethode(
    ProductModel product,
    BuildContext context,
    bool editMode,
    Widget child,
    VoidCallback onTap,
  ) {
    var floatControllerClient = Get.put(FloatingButtonsClientController());
    var floatControllerVendor = Get.put(FloatingButtonsController());
    floatControllerVendor.isEditabel = editMode;

    return GestureDetector(
      onLongPressStart: (details) {
        if (editMode) {
          var controller = floatControllerVendor;
          controller.product = product;
          controller.isEditabel = editMode;
          controller.showFloatingButtons(
            context,
            details.globalPosition,
            productIsFavorite: false,
          );
        } else {
          var controller = floatControllerClient;
          controller.product = product;
          controller.isEditabel = editMode;
          controller.showFloatingButtons(
            context,
            details.globalPosition,
            productIsFavorite: false,
          );
        }
      },
      onLongPressMoveUpdate: (details) {
        if (editMode) {
          var controller = floatControllerVendor; // : floatControllerClient;
          controller.updatePosition(details.globalPosition);
        } else {
          var controller = floatControllerClient; // : floatControllerClient;
          controller.updatePosition(details.globalPosition);
        }
      },
      onTap: onTap,
      onLongPressEnd: (details) {
        if (editMode) {
          var controller = floatControllerVendor; // : floatControllerClient;
          controller.processSelection();
          controller.removeFloatingButtons();
        } else {
          var controller = floatControllerClient; // : floatControllerClient;
          controller.processSelection();
          controller.removeFloatingButtons();
        }
      },
      child: child,
    );
  }
}
