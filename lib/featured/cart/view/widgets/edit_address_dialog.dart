import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';

class EditAddressDialog extends StatefulWidget {
  final AddressModel address;
  final Function(AddressModel)? onAddressUpdated;

  const EditAddressDialog({
    super.key,
    required this.address,
    this.onAddressUpdated,
  });

  @override
  State<EditAddressDialog> createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _cityController;
  late final TextEditingController _streetController;
  late final TextEditingController _buildingNumberController;
  late final TextEditingController _addressDetailsController;
  late final TextEditingController _phoneController;
  late final RxBool _isDefaultController;
  final _isLoading = false.obs;
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    // تهيئة Controllers مع البيانات الحالية
    _titleController = TextEditingController(text: widget.address.title);
    _cityController = TextEditingController(text: widget.address.city);
    _streetController = TextEditingController(text: widget.address.street);
    _buildingNumberController = TextEditingController(
      text: widget.address.buildingNumber,
    );
    _addressDetailsController = TextEditingController(
      text: widget.address.fullAddress,
    );
    _phoneController = TextEditingController(text: widget.address.phoneNumber);
    _isDefaultController = widget.address.isDefault.obs;
    _phoneNumber = widget.address.phoneNumber!;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingNumberController.dispose();
    _addressDetailsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header ثابت
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_location, color: TColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'address_edit_title'.tr,
                      style: titilliumBold.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            // محتوى قابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان مخصص
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'address_title_label'.tr,
                          hintText: 'address_title_hint',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'address.title_required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // المدينة
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(labelText: 'المدينة'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال المدينة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // الشارع
                      TextFormField(
                        controller: _streetController,
                        decoration: InputDecoration(labelText: 'الشارع'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال الشارع';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // رقم المبنى
                      TextFormField(
                        controller: _buildingNumberController,
                        decoration: InputDecoration(labelText: 'رقم المبنى'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال رقم المبنى';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // تفاصيل العنوان
                      TextFormField(
                        controller: _addressDetailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'تفاصيل العنوان',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال تفاصيل العنوان';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // رقم الهاتف
                      Directionality(
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

                          controller: _phoneController,
                          textAlign: TextAlign.left,
                          focusNode: null,
                          initialCountryCode: _getCountryCodeFromPhone(
                            widget.address.phoneNumber ?? '',
                          ),
                          initialValue: _getPhoneNumberWithoutCode(
                            widget.address.phoneNumber ?? '',
                          ),
                          pickerDialogStyle: PickerDialogStyle(
                            countryFlagStyle: const TextStyle(fontSize: 17),
                          ),
                          decoration: InputDecoration(labelText: 'رقم الهاتف'),
                          languageCode: Get.locale?.languageCode ?? 'en',
                          onChanged: (phone) {
                            _phoneNumber = phone.completeNumber;
                          },
                          validator: (phone) {
                            if (phone == null ||
                                // ignore: unnecessary_null_comparison
                                phone.completeNumber == null ||
                                phone.completeNumber.isEmpty) {
                              return 'يرجى إدخال رقم الهاتف';
                            }
                            if (phone.completeNumber.length < 10) {
                              return 'رقم الهاتف قصير جداً';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // تعيين كافتراضي
                      Obx(
                        () => CheckboxListTile(
                          title: Text('address_set_as_default'.tr),
                          value: _isDefaultController.value,
                          onChanged:
                              (value) =>
                                  _isDefaultController.value = value ?? false,
                          activeColor: TColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // أزرار ثابتة في الأسفل
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('common.cancel'),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: _isLoading.value ? null : _updateAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isLoading.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text('address_update'.tr),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      final userId = VendorController.instance.profileData.value.userId ?? '';
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في بيانات المستخدم',
              style: titilliumRegular.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      final updatedAddress = widget.address.copyWith(
        title: _titleController.text.trim(),
        fullAddress: _addressDetailsController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        buildingNumber: _buildingNumberController.text.trim(),
        phoneNumber:
            _phoneNumber.isNotEmpty
                ? _phoneNumber
                : _phoneController.text.trim(),
        isDefault: _isDefaultController.value,
      );

      final addressService = Get.find<AddressService>();
      final success = await addressService.updateAddress(
        updatedAddress,
        userId,
      );

      if (success) {
        Navigator.pop(context);
        widget.onAddressUpdated?.call(updatedAddress);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'address.updated_successfully'.tr,
              style: titilliumRegular.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'address.update_failed',
              style: titilliumRegular.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: $e',
            style: titilliumRegular.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      _isLoading.value = false;
    }
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
}
