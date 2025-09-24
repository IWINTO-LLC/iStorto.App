import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';

import 'package:istoreto/featured/cart/view/widgets/map_location_picker.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class AddAddressDialog extends StatefulWidget {
  final Function(AddressModel)? onAddressAdded;

  const AddAddressDialog({super.key, this.onAddressAdded});

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _addressDetailsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _isDefaultController = false.obs;
  final _isLoading = false.obs;
  String _phoneNumber = '';
  // رمز السعودية افتراضياً

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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TCustomWidgets.buildTitle('إضافة عنوان جديد'),
                const SizedBox(height: 20),

                // عنوان مخصص
                TCustomWidgets.buildLabel('عنوان العنوان'),
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // المدينة
                TCustomWidgets.buildLabel('المدينة'),
                TextFormField(
                  controller: _cityController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // الشارع
                TCustomWidgets.buildLabel('الشارع'),
                TextFormField(
                  controller: _streetController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // رقم المبنى
                TCustomWidgets.buildLabel('رقم المبنى'),
                TextFormField(
                  controller: _buildingNumberController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // زر اختيار العنوان من الخريطة
                TCustomWidgets.buildLabel('اختيار من الخريطة'),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map, color: TColors.primary),
                    label: Text(
                      'اختيار العنوان من الخريطة',
                      style: titilliumRegular.copyWith(color: TColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: TColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapLocationPicker(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _addressDetailsController.text = result['address'];
                          // يمكنك أيضاً حفظ الإحداثيات في متغير آخر إذا أردت
                          // lat = result['latlng'].latitude;
                          // lng = result['latlng'].longitude;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // تفاصيل العنوان
                TCustomWidgets.buildLabel('تفاصيل العنوان'),
                TextFormField(
                  controller: _addressDetailsController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // رقم الهاتف
                TCustomWidgets.buildLabel('رقم الهاتف'),
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
                    initialCountryCode: "SA",
                    pickerDialogStyle: PickerDialogStyle(
                      countryFlagStyle: const TextStyle(fontSize: 17),
                    ),

                    languageCode: Get.locale?.languageCode ?? 'en',
                    onChanged: (phone) {
                      _phoneNumber = phone.completeNumber;
                    },
                    validator: (phone) {
                      if (phone == null || phone.completeNumber.isEmpty) {
                        return 'مطلوب';
                      }
                      if (phone.completeNumber.length < 10) {
                        return 'رقم الهاتف قصير جداً';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // تعيين كافتراضي
                TCustomWidgets.buildLabel('خيارات إضافية'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => CheckboxListTile(
                      title: Text(
                        'تعيين كعنوان افتراضي',
                        style: titilliumRegular.copyWith(fontSize: 14),
                      ),
                      value: _isDefaultController.value,
                      onChanged:
                          (value) =>
                              _isDefaultController.value = value ?? false,
                      activeColor: TColors.primary,
                      checkColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // أزرار الحفظ والإلغاء
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'إلغاء',
                          style: titilliumRegular.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: _isLoading.value ? null : _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                                  : Text(
                                    'حفظ العنوان',
                                    style: titilliumBold.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      final userId = VendorController.instance.profileData.value.userId ?? '';
      if (userId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في بيانات المستخدم')));
        return;
      }

      final address = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: _titleController.text.trim(),
        fullAddress: _addressDetailsController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        buildingNumber: _buildingNumberController.text.trim(),
        phoneNumber:
            _phoneNumber.isNotEmpty
                ? _phoneNumber
                : _phoneController.text.trim(),
        latitude: null, // يمكن إضافته لاحقاً من الخريطة
        longitude: null,
        createdAt: DateTime.now(),
        isDefault: _isDefaultController.value,
      );

      final addressService = Get.find<AddressService>();
      final success = await addressService.saveAddress(address, userId);

      if (success) {
        Navigator.pop(context);
        widget.onAddressAdded?.call(address);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('address_saved_successfully'.tr)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('address.save_failed'.tr)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      _isLoading.value = false;
    }
  }
}
