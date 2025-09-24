import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/data/address_repository.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
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
  final _addressRepository = AddressRepository();

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

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id ?? '';
      if (userId.isEmpty) {
        TLoader.warningSnackBar(
          title: "error".tr,
          message: "User data error".tr,
        );
        return;
      }

      final address = AddressModel(
        id: null, // سيتم إنشاؤه تلقائياً من Supabase
        title: _titleController.text.trim(),
        fullAddress: _addressDetailsController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        buildingNumber: _buildingNumberController.text.trim(),
        phoneNumber:
            _phoneNumber.isNotEmpty
                ? _phoneNumber
                : _phoneController.text.trim(),
        latitude: null, // سيتم تحديثه لاحقاً إذا تم تحديد الموقع
        longitude: null,
        createdAt: DateTime.now(),
        isDefault: _isDefaultController.value,
        userId: userId,
      );

      final createdAddress = await _addressRepository.createAddress(address);

      if (createdAddress != null) {
        // إذا كان العنوان افتراضياً، قم بإزالة الافتراضي من العناوين الأخرى
        if (_isDefaultController.value) {
          await _addressRepository.setAsDefault(createdAddress.id!, userId);
        }

        TLoader.successSnackBar(
          title: "success".tr,
          message: "Address saved successfully".tr,
        );
        Navigator.pop(context, true); // إرجاع true للإشارة إلى النجاح
      } else {
        TLoader.warningSnackBar(
          title: "error".tr,
          message: "Failed to save address".tr,
        );
      }
    } catch (e) {
      TLoader.warningSnackBar(title: "error".tr, message: e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "address.add_new_address".tr,
            style: titilliumBold.copyWith(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: TColors.black,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان مخصص
                    TCustomWidgets.buildLabel("address.custom_title".tr),
                    TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "address.required".tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "address.title_hint".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // المدينة
                    TCustomWidgets.buildLabel("address.city".tr),
                    TextFormField(
                      controller: _cityController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "address.required".tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // الشارع
                    TCustomWidgets.buildLabel("address.street".tr),
                    TextFormField(
                      controller: _streetController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "address.required".tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // رقم المبنى
                    TCustomWidgets.buildLabel("address.building_number".tr),
                    TextFormField(
                      controller: _buildingNumberController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "address.required".tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // زر اختيار العنوان من الخريطة
                    TCustomWidgets.buildLabel("address.select_from_map".tr),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.location_pin,
                          color: TColors.primary,
                        ),
                        label: Text(
                          "address.select_from_map".tr,
                          style: titilliumRegular.copyWith(
                            color: TColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: TColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // TODO: إضافة خريطة اختيار الموقع
                          TLoader.warningSnackBar(
                            title: "info".tr,
                            message: "address.map_feature_coming_soon".tr,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // تفاصيل العنوان
                    TCustomWidgets.buildLabel("address.address_details".tr),
                    TextFormField(
                      controller: _addressDetailsController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "address.required".tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // رقم الهاتف
                    TCustomWidgets.buildLabel("address.phone".tr),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: FlutterPhoneNumberField(
                        dropdownTextStyle: titilliumRegular.copyWith(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                        style: titilliumRegular.copyWith(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                        controller: _phoneController,
                        textAlign: TextAlign.left,
                        focusNode: null,
                        initialCountryCode: "SA",
                        pickerDialogStyle: PickerDialogStyle(
                          countryFlagStyle: const TextStyle(fontSize: 17),
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        languageCode: Get.locale?.languageCode ?? 'en',
                        onChanged: (phone) {
                          _phoneNumber = phone.completeNumber;
                        },
                        validator: (phone) {
                          if (phone == null || phone.completeNumber.isEmpty) {
                            return "address.required".tr;
                          }
                          if (phone.completeNumber.length < 10) {
                            return "address.phone_too_short".tr;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // تعيين كافتراضي
                    TCustomWidgets.buildLabel("address.additional_options".tr),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(
                        () => CheckboxListTile(
                          title: Text(
                            "address.set_as_default".tr,
                            style: titilliumRegular.copyWith(fontSize: 14),
                          ),
                          value: _isDefaultController.value,
                          onChanged:
                              (value) =>
                                  _isDefaultController.value = value ?? false,
                          activeColor: TColors.primary,
                          checkColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
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
                              "address.cancel".tr,
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
                              onPressed:
                                  _isLoading.value
                                      ? null
                                      : () => _saveAddress(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        "address.save_address".tr,
                                        style: titilliumBold.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
