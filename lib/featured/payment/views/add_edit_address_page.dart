import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/payment/widgets/google_map_picker.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

/// صفحة إضافة أو تعديل عنوان
class AddEditAddressPage extends StatefulWidget {
  final AddressModel? address; // null = إضافة جديد، !null = تعديل

  const AddEditAddressPage({super.key, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late AddressService addressService;

  // Controllers
  late TextEditingController titleController;
  late TextEditingController fullAddressController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController buildingNumberController;
  late TextEditingController phoneNumberController;

  // Location data
  double? latitude;
  double? longitude;

  // Is default checkbox
  bool isDefault = false;

  // Loading state
  bool isLoading = false;

  bool get isEditMode => widget.address != null;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _initializeControllers();
  }

  void _initializeService() {
    if (!Get.isRegistered<AddressService>()) {
      Get.put(AddressService());
    }
    addressService = AddressService.instance;
  }

  void _initializeControllers() {
    titleController = TextEditingController(text: widget.address?.title ?? '');
    fullAddressController = TextEditingController(
      text: widget.address?.fullAddress ?? '',
    );
    cityController = TextEditingController(text: widget.address?.city ?? '');
    streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    buildingNumberController = TextEditingController(
      text: widget.address?.buildingNumber ?? '',
    );
    phoneNumberController = TextEditingController(
      text: widget.address?.phoneNumber ?? '',
    );

    latitude = widget.address?.latitude;
    longitude = widget.address?.longitude;
    isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    fullAddressController.dispose();
    cityController.dispose();
    streetController.dispose();
    buildingNumberController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'edit_address'.tr : 'add_new_address'.tr,
          style: titilliumBold.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(TSizes.paddingSizeDefault),
          children: [
            // عنوان العنوان (مثل: المنزل، العمل)
            _buildSectionTitle('address_title_label'.tr),
            const SizedBox(height: 8),
            _buildTextField(
              controller: titleController,
              label: 'address_title'.tr,
              hint: 'address_title_hint'.tr,
              icon: Icons.label,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'address_title_required'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // العنوان الكامل
            _buildSectionTitle('full_address_label'.tr),
            const SizedBox(height: 8),
            _buildTextField(
              controller: fullAddressController,
              label: 'full_address'.tr,
              hint: 'full_address_hint'.tr,
              icon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'full_address_required'.tr;
                }
                return null;
              },
            ),

            // زر اختيار من الخريطة (قريباً)
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickLocationFromMap,
              icon: const Icon(Icons.map),
              label: Text('pick_from_map'.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: TColors.primary),
              ),
            ),

            const SizedBox(height: 24),

            // تفاصيل إضافية
            _buildSectionTitle('additional_details'.tr),
            const SizedBox(height: 8),

            // المدينة
            _buildTextField(
              controller: cityController,
              label: 'city'.tr,
              hint: 'city_hint'.tr,
              icon: Icons.location_city,
            ),

            const SizedBox(height: 16),

            // الشارع
            _buildTextField(
              controller: streetController,
              label: 'street'.tr,
              hint: 'street_hint'.tr,
              icon: Icons.signpost,
            ),

            const SizedBox(height: 16),

            // رقم المبنى
            _buildTextField(
              controller: buildingNumberController,
              label: 'building_number'.tr,
              hint: 'building_number_hint'.tr,
              icon: Icons.home,
            ),

            const SizedBox(height: 24),

            // رقم الهاتف
            _buildSectionTitle('contact_info'.tr),
            const SizedBox(height: 8),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'phone_number'.tr,
                hintText: 'phone_number_hint'.tr,
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // تعيين كعنوان افتراضي
            Card(
              child: CheckboxListTile(
                title: Text(
                  'set_as_default_address'.tr,
                  style: titilliumBold.copyWith(fontSize: 15),
                ),
                subtitle: Text(
                  'default_address_description'.tr,
                  style: titilliumRegular.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                value: isDefault,
                onChanged: (value) {
                  setState(() {
                    isDefault = value ?? false;
                  });
                },
                activeColor: TColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            // معلومات الموقع (إذا كانت متوفرة)
            if (latitude != null && longitude != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'location_saved'.tr,
                              style: titilliumBold.copyWith(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${'lat'.tr}: ${latitude!.toStringAsFixed(6)}, ${'lng'.tr}: ${longitude!.toStringAsFixed(6)}',
                              style: titilliumRegular.copyWith(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // زر الحفظ
            ElevatedButton(
              onPressed: isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'save'.tr,
                        style: titilliumBold.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: titilliumBold.copyWith(fontSize: 16, color: Colors.grey.shade800),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: titilliumRegular.copyWith(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: TColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  void _pickLocationFromMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GoogleMapPicker(
              initialPosition:
                  latitude != null && longitude != null
                      ? LatLng(latitude!, longitude!)
                      : null,
              onLocationSelected: (position, address, placemark) {
                setState(() {
                  latitude = position.latitude;
                  longitude = position.longitude;

                  // تعبئة العنوان الكامل
                  if (fullAddressController.text.isEmpty) {
                    fullAddressController.text = address;
                  }

                  // تعبئة الحقول من Placemark
                  if (placemark != null) {
                    if (cityController.text.isEmpty &&
                        placemark.locality != null) {
                      cityController.text = placemark.locality!;
                    }
                    if (streetController.text.isEmpty &&
                        placemark.street != null) {
                      streetController.text = placemark.street!;
                    }
                    if (buildingNumberController.text.isEmpty &&
                        placemark.subThoroughfare != null) {
                      buildingNumberController.text =
                          placemark.subThoroughfare!;
                    }
                  }
                });

                Get.snackbar(
                  'success'.tr,
                  'location_saved'.tr,
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade800,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = AuthController.instance.currentUser.value?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      print("uuuuuusssssssser $userId");
      final address = AddressModel(
        id: widget.address?.id,
        userId: userId,
        title: titleController.text.trim(),
        fullAddress: fullAddressController.text.trim(),
        city:
            cityController.text.trim().isEmpty
                ? null
                : cityController.text.trim(),
        street:
            streetController.text.trim().isEmpty
                ? null
                : streetController.text.trim(),
        buildingNumber:
            buildingNumberController.text.trim().isEmpty
                ? null
                : buildingNumberController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        createdAt: widget.address?.createdAt,
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditMode) {
        success = await addressService.updateAddress(address, userId);
      } else {
        success = await addressService.saveAddress(address, userId);
      }

      if (success) {
        Get.back(); // العودة للصفحة السابقة
        Get.snackbar(
          'success'.tr,
          isEditMode
              ? 'address_updated_successfully'.tr
              : 'address_added_successfully'.tr,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to save address');
      }
    } catch (e) {
      print('Error saving address: $e');
      Get.snackbar(
        'error'.tr,
        '${isEditMode ? 'update_failed'.tr : 'add_failed'.tr}: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
