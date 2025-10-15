import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/data/order_repository.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  // Repository
  final OrderRepository _orderRepository = OrderRepository();

  // Observable variables
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var vendorHasOrders = false.obs;
  var errorMessage = ''.obs;

  // Controllers
  final phoneController = TextEditingController();
  final addressDetailsController = TextEditingController();
  final buildingController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // تهيئة القيم الافتراضية
    isLoading.value = false;
    vendorHasOrders.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    // تنظيف Controllers
    phoneController.dispose();
    addressDetailsController.dispose();
    buildingController.dispose();
    streetController.dispose();
    cityController.dispose();
    super.onClose();
  }

  Future<void> updateOrderState(
    String orderId,
    String newState,
    String vendorId,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _orderRepository.updateOrderState(
        orderId,
        newState,
      );

      if (success) {
        // Refresh vendor sales after updating state
        await fetchVendorSales(vendorId);
      } else {
        errorMessage.value = 'Failed to update order state';
      }
    } catch (e) {
      debugPrint('Error updating order state: $e');
      errorMessage.value = 'Error updating order state: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<OrderModel>> fetchUserOrders(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final ordersList = await _orderRepository.getOrdersByBuyer(userId);
      orders.value = ordersList;
      return ordersList;
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      errorMessage.value = 'Error fetching user orders: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من وجود طلبات للمتجر مع GetX
  Future<bool> hasOrders(String vendorId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final hasOrdersResult = await _orderRepository.hasOrders(vendorId);
      vendorHasOrders.value = hasOrdersResult;
      return hasOrdersResult;
    } catch (e) {
      debugPrint('Error checking orders: $e');
      errorMessage.value = 'Error checking orders: $e';
      vendorHasOrders.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Stream للتحقق من وجود طلبات
  Stream<bool> hasOrdersStream(String vendorId) {
    return _orderRepository
        .getOrdersStream(vendorId: vendorId)
        .map((ordersList) => ordersList.isNotEmpty);
  }

  Future<List<OrderModel>> fetchVendorSales(String vendorId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final ordersList = await _orderRepository.getOrdersByVendor(vendorId);
      orders.value = ordersList;
      return ordersList;
    } catch (e) {
      debugPrint('Error fetching vendor sales: $e');
      errorMessage.value = 'Error fetching vendor sales: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Generate a unique doc_id if not provided
      if (order.docId.isEmpty) {
        order = order.copyWith(
          docId: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      final createdOrder = await _orderRepository.createOrder(order);

      if (createdOrder != null) {
        // Order created successfully
        debugPrint('Order created successfully: ${createdOrder.id}');
      } else {
        errorMessage.value = 'Failed to create order';
      }
    } catch (e) {
      debugPrint('Error submitting order: $e');
      errorMessage.value = 'Error submitting order: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void bindVendorSales(String vendorId) {
    try {
      errorMessage.value = '';

      _orderRepository
          .getOrdersStream(vendorId: vendorId)
          .listen(
            (ordersList) {
              orders.value = ordersList;
            },
            onError: (error) {
              debugPrint('Error in bindVendorSales: $error');
              errorMessage.value = 'Error loading orders: $error';
            },
          );
    } catch (e) {
      debugPrint('Error setting up bindVendorSales: $e');
      errorMessage.value = 'Error setting up orders stream: $e';
    }
  }

  /// 🧾 إرجاع Stream فقط بدون تعديل القائمة
  Stream<List<OrderModel>> getVendorSalesStream(String vendorId) {
    return _orderRepository.getOrdersStream(vendorId: vendorId);
  }

  String getOrderState(OrderModel order) {
    return order.stateDisplayText;
  }

  var o = {
    "unKnoun": "غير معروف",
    "paied": "تم الدفع",
    "delivered": "تم التسليم",
    "Preparing": "يتم التحضير'",
    "runing": "جاري",
  };

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _orderRepository.getOrdersStream(buyerId: userId);
  }

  RxString currentAddress = ''.obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxBool useCurrentLocation = false.obs;

  String phone = "";

  Future<void> setCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    await updateAddressFromCoordinates();
  }

  Future<void> updateAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude.value,
        longitude.value,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        currentAddress.value =
            '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      currentAddress.value = 'تعذر تحديد العنوان';
    }
  }

  getColorByState(String state) {
    switch (state) {
      case '0':
        return Colors.yellow;
      case '1':
        return Colors.blueGrey;
      case '2':
        return Colors.green;
      case '3':
        return Colors.orange;
      case '4':
        return Colors.blue;
      default:
        return ""; // القيمة الافتراضية إذا لم يكن الم
    }
  }
}
