import 'package:flutter/material.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/cart/view/widgets/address_selector.dart';
import 'package:istoreto/featured/cart/view/widgets/cart__static_menu_item.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/navigation_menu.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:sizer/sizer.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  String _getPaymentMethodText() {
    switch (_currentOrder.paymentMethod) {
      case 'cod':
        return "payment.cash_on_delivery".tr;
      case 'iwinto_wallet':
        return "payment.iwinto_wallet".tr;
      default:
        return "payment.not_specified".tr;
    }
  }

  IconData _getPaymentMethodIcon() {
    switch (_currentOrder.paymentMethod) {
      case 'cod':
        return Icons.money;
      case 'iwinto_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor() {
    switch (_currentOrder.paymentMethod) {
      case 'cod':
        return Colors.green;
      case 'iwinto_wallet':
        return TColors.primary;
      default:
        return Colors.grey;
    }
  }

  void _showEditAddressDialog(BuildContext context) {
    // إنشاء AddressModel من بيانات الطلب الحالي
    final currentAddressModel = AddressModel(
      id: 'order_address_${_currentOrder.id}',
      userId: _currentOrder.buyerId,
      title: "order.order_address".tr,
      fullAddress: _currentOrder.fullAddress ?? '',
      city: '', // سيتم ملؤها من العنوان الكامل
      street: '', // سيتم ملؤها من العنوان الكامل
      buildingNumber: _currentOrder.buildingNumber,
      phoneNumber: _currentOrder.phoneNumber,
      latitude: _currentOrder.locationLat,
      longitude: _currentOrder.locationLng,
      createdAt: _currentOrder.orderDate,
      isDefault: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: AddressSelector(
            currentAddress: currentAddressModel,
            onAddressSelected: (AddressModel selectedAddress) {
              // تحديث العنوان في الصفحة
              setState(() {
                _currentOrder = _currentOrder.copyWith(
                  fullAddress: selectedAddress.fullAddress,
                  buildingNumber: selectedAddress.buildingNumber,
                  phoneNumber: selectedAddress.phoneNumber,
                  locationLat: selectedAddress.latitude,
                  locationLng: selectedAddress.longitude,
                );
              });

              // إظهار رسالة نجاح
              Get.snackbar(
                "common.updated".tr,
                "address.updated_successfully".tr,
                backgroundColor: Colors.black,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(8),
                borderRadius: 8,
                duration: const Duration(seconds: 3),
                barBlur: 0,
                isDismissible: true,
                dismissDirection: DismissDirection.horizontal,
              );
            },
          ),
        );
      },
    );
  }

  void _showEditPhoneDialog(BuildContext context) {
    final phoneController = TextEditingController();
    String currentPhoneNumber = _currentOrder.phoneNumber ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "order.edit_phone_number".tr,
            style: titilliumBold.copyWith(fontSize: 18),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: FlutterPhoneNumberField(
                  dropdownTextStyle: titilliumRegular.copyWith(
                    fontSize: 16,
                    fontFamily: numberFonts,
                  ),
                  style: titilliumRegular.copyWith(
                    fontSize: 16,
                    fontFamily: numberFonts,
                  ),
                  controller: phoneController,
                  textAlign: TextAlign.left,
                  focusNode: null,
                  initialCountryCode: _getCountryCodeFromPhone(
                    currentPhoneNumber,
                  ),
                  initialValue: _getPhoneNumberWithoutCode(currentPhoneNumber),
                  pickerDialogStyle: PickerDialogStyle(
                    countryFlagStyle: const TextStyle(fontSize: 17),
                  ),
                  decoration: InputDecoration(labelText: "address.phone".tr),
                  languageCode: Get.locale?.languageCode ?? 'en',
                  onChanged: (phone) {
                    currentPhoneNumber = phone.completeNumber;
                  },
                  validator: (phone) {
                    if (phone == null || phone.completeNumber.isEmpty) {
                      return "common.required".tr;
                    }
                    if (phone.completeNumber.length < 10) {
                      return "address.phone_too_short".tr;
                    }
                    return null;
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "common.cancel".tr,
                style: titilliumRegular.copyWith(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // تحديث رقم الهاتف في الصفحة
                setState(() {
                  _currentOrder = _currentOrder.copyWith(
                    phoneNumber: currentPhoneNumber,
                  );
                });
                Get.snackbar(
                  "common.updated".tr,
                  "order.phone_updated_successfully".tr,
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(8),
                  borderRadius: 8,
                  duration: const Duration(seconds: 3),
                  barBlur: 0,
                  isDismissible: true,
                  dismissDirection: DismissDirection.horizontal,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                "save".tr,
                style: titilliumBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getCountryCodeFromPhone(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(1, 3);
    } else if (phoneNumber.startsWith('00')) {
      return phoneNumber.substring(2, 4);
    } else if (phoneNumber.startsWith('0')) {
      return phoneNumber.substring(1, 3);
    }
    return 'SA'; // Default country code
  }

  String _getPhoneNumberWithoutCode(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(3);
    } else if (phoneNumber.startsWith('00')) {
      return phoneNumber.substring(4);
    } else if (phoneNumber.startsWith('0')) {
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  void _showEditPaymentMethodDialog(BuildContext context) {
    String selectedMethod = _currentOrder.paymentMethod;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'order.edit_payment_method'.tr,
            style: titilliumBold.copyWith(fontSize: 18),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(
                      "payment.cash_on_delivery".tr,
                      style: titilliumRegular,
                    ),
                    value: 'cod',
                    groupValue: selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                    activeColor: TColors.primary,
                  ),
                  RadioListTile<String>(
                    title: Text(
                      "payment.iwinto_wallet".tr,
                      style: titilliumRegular,
                    ),
                    value: 'iwinto_wallet',
                    groupValue: selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                    activeColor: TColors.primary,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "common.cancel".tr,
                style: titilliumRegular.copyWith(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // تحديث وسيلة الدفع في الصفحة
                setState(() {
                  _currentOrder = _currentOrder.copyWith(
                    paymentMethod: selectedMethod,
                  );
                });
                Get.snackbar(
                  "common.updated".tr,
                  "order.payment_method_updated_successfully".tr,
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(8),
                  borderRadius: 8,
                  duration: const Duration(seconds: 3),
                  barBlur: 0,
                  isDismissible: true,
                  dismissDirection: DismissDirection.horizontal,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                "save".tr,
                style: titilliumBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavigationMenu()),
            (route) => false, // Remove all previous routes
          );
        }
        return true;
      },
      child: Directionality(
        textDirection:
            TranslationController.instance.isRTL
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
          appBar: CustomAppBar(
            isBackButtonExist: false,
            title: 'order.order_confirmed'.tr,
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'order.successMsg'.tr,
                      style: titilliumBold.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${'order.id'.tr}: ${_currentOrder.id}",
                      style: titilliumBold.copyWith(fontSize: 16),
                    ),
                    Text(
                      "${'order.items_count'.tr}: ${_currentOrder.productList.length}",
                      style: titilliumBold.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ..._currentOrder.productList.map(
                      (item) => Column(
                        children: [
                          CartStaticMenuItem(item: item),
                          TCustomWidgets.buildDivider(),
                        ],
                      ),
                    ),
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "cart.all_amount".tr, //
                          style: titilliumBold.copyWith(
                            fontFamily: numberFonts,
                          ),
                        ),
                        TRoundedContainer(
                          radius: BorderRadius.circular(15),
                          // enableShadow: true,
                          // showBorder: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 16,
                            ),
                            child: TCustomWidgets.formattedPrice(
                              _currentOrder.totalPrice,
                              18,
                              TColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (_currentOrder.fullAddress != null &&
                                    _currentOrder.fullAddress!.isNotEmpty
                                ? _currentOrder.fullAddress!
                                : 'order.no_address'.tr),
                            style: titilliumBold.copyWith(fontSize: 14),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: TColors.primary,
                          ),
                          onPressed: () {
                            _showEditAddressDialog(context);
                          },
                          tooltip: 'order.edit_address'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 20,
                          color: TColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'order.phone_number'.tr,
                                style: titilliumRegular.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                (_currentOrder.phoneNumber != null &&
                                        _currentOrder.phoneNumber!.isNotEmpty)
                                    ? _currentOrder.phoneNumber!
                                    : 'order.no_phone'.tr,
                                style: titilliumBold.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: TColors.primary,
                          ),
                          onPressed: () {
                            _showEditPhoneDialog(context);
                          },
                          tooltip: "order.edit_phone".tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // وسيلة الدفع
                    Row(
                      children: [
                        Icon(
                          _getPaymentMethodIcon(),
                          size: 20,
                          color: _getPaymentMethodColor(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "order.payment_method".tr,
                                style: titilliumRegular.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _getPaymentMethodText(),
                                style: titilliumBold.copyWith(
                                  fontSize: 14,
                                  color: _getPaymentMethodColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: TColors.primary,
                          ),
                          onPressed: () {
                            _showEditPaymentMethodDialog(context);
                          },
                          tooltip: "order.edit_payment_method".tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (_currentOrder.locationLat != null &&
                        _currentOrder.locationLng != null)
                      SizedBox(
                        width: 60.w,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map),
                          label: Text(
                            "order.view_location".tr,
                            style: titilliumBold,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationMenu(),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 60.w,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const Scaffold(
                                    body: Center(child: Text('Home')),
                                  ),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "order.back_to_home".tr,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
