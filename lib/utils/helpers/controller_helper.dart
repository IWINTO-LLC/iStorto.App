import 'package:get/get.dart';

/// Helper class for managing GetX controllers initialization
class ControllerHelper {
  /// Initialize a controller only if it's not already registered
  ///
  /// Example:
  /// ```dart
  /// ControllerHelper.initController<VendorController>(
  ///   () => VendorController(),
  /// );
  /// ```
  static T initController<T>(T Function() builder, {String? tag}) {
    if (!Get.isRegistered<T>(tag: tag)) {
      return Get.put<T>(builder(), tag: tag);
    }
    return Get.find<T>(tag: tag);
  }

  /// Initialize a lazy controller only if it's not already registered
  ///
  /// Example:
  /// ```dart
  /// ControllerHelper.initLazyController<VendorController>(
  ///   () => VendorController(),
  /// );
  /// ```
  static void initLazyController<T>(T Function() builder, {String? tag}) {
    if (!Get.isRegistered<T>(tag: tag)) {
      Get.lazyPut<T>(builder, tag: tag);
    }
  }

  /// Get a controller if it exists, otherwise initialize it
  ///
  /// Example:
  /// ```dart
  /// final controller = ControllerHelper.getOrInit<VendorController>(
  ///   () => VendorController(),
  /// );
  /// ```
  static T getOrInit<T>(T Function() builder, {String? tag}) {
    try {
      return Get.find<T>(tag: tag);
    } catch (e) {
      return Get.put<T>(builder(), tag: tag);
    }
  }

  /// Check if a controller is registered
  ///
  /// Example:
  /// ```dart
  /// if (ControllerHelper.isRegistered<VendorController>()) {
  ///   // Controller is already registered
  /// }
  /// ```
  static bool isRegistered<T>({String? tag}) {
    return Get.isRegistered<T>(tag: tag);
  }

  /// Remove a controller from memory
  ///
  /// Example:
  /// ```dart
  /// ControllerHelper.remove<VendorController>();
  /// ```
  static void remove<T>({String? tag}) {
    if (Get.isRegistered<T>(tag: tag)) {
      Get.delete<T>(tag: tag);
    }
  }

  /// Reset a controller (remove and reinitialize)
  ///
  /// Example:
  /// ```dart
  /// ControllerHelper.reset<VendorController>(
  ///   () => VendorController(),
  /// );
  /// ```
  static T reset<T>(T Function() builder, {String? tag}) {
    remove<T>(tag: tag);
    return Get.put<T>(builder(), tag: tag);
  }
}
