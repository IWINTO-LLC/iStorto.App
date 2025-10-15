import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/address/pages/add_address_page.dart';
import 'package:istoreto/featured/cart/view/widgets/address_selector.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  void _loadDefaultAddress() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final addressService = Get.find<AddressService>();
      final profileController = VendorController.instance;

      // انتظار حتى يتم تحميل بيانات الملف الشخصي
      await Future.delayed(Duration(milliseconds: 300));

      final userId = profileController.profileData.value.userId;
      if (userId != null && userId.isNotEmpty) {
        // جلب عناوين المستخدم
        await addressService.getUserAddresses(userId);

        // البحث عن العنوان الافتراضي
        final defaultAddress = addressService.getDefaultAddress();
        if (defaultAddress != null) {
          // تحديث البيانات في OrderController
          final controller = OrderController.instance;
          controller.cityController.text = defaultAddress.city!;
          controller.streetController.text = defaultAddress.buildingNumber!;
          controller.addressDetailsController.text = defaultAddress.fullAddress;
          controller.phone = defaultAddress.phoneNumber!;
          controller.phoneController.text = defaultAddress.phoneNumber!;

          // تحديث الموقع إذا كان متوفراً
          if (defaultAddress.latitude != null &&
              defaultAddress.longitude != null) {
            controller.latitude.value = defaultAddress.latitude!;
            controller.longitude.value = defaultAddress.longitude!;
            controller.useCurrentLocation.value = false;
          }

          // تحديد العنوان كعنوان مختار
          addressService.selectAddress(defaultAddress);
        }
      }
    } catch (e) {
      print('Error loading default address: $e');
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = OrderController.instance;
    final addressService = Get.put(AddressService());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'order.address_section'.tr,
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // حقل الهاتف معطل - سيتم استخدام رقم الهاتف من العنوان المختار فقط
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // منتقي العناوين
          _isLoadingAddress
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          TColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جاري تحميل العناوين...',
                      style: titilliumRegular.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : Obx(() {
                final selectedAddress = addressService.selectedAddress.value;

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (context) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: AddressSelector(
                                onAddressSelected: (address) {
                                  // تحديث البيانات في OrderController
                                  controller.cityController.text =
                                      address.city!;
                                  controller.streetController.text =
                                      address.buildingNumber!;
                                  controller.addressDetailsController.text =
                                      address.fullAddress;
                                  controller.phone = address.phoneNumber!;
                                  controller.phoneController.text =
                                      address.phoneNumber!;

                                  // تحديث الموقع إذا كان متوفراً
                                  if (address.latitude != null &&
                                      address.longitude != null) {
                                    controller.latitude.value =
                                        address.latitude!;
                                    controller.longitude.value =
                                        address.longitude!;
                                    controller.useCurrentLocation.value = false;
                                  }

                                  addressService.selectAddress(address);
                                },
                                currentAddress: selectedAddress,
                              ),
                            ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // أيقونة الموقع
                          Icon(
                            Icons.location_pin,
                            color: TColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),

                          // محتوى العنوان
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // عنوان العنوان
                                Text(
                                  selectedAddress?.title ??
                                      'address_select_address'.tr,
                                  style: titilliumBold.copyWith(
                                    fontSize: 16,
                                    color:
                                        selectedAddress != null
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                  ),
                                ),

                                // تفاصيل العنوان إذا كان محدداً
                                if (selectedAddress != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedAddress.fullAddress,
                                    style: titilliumRegular.copyWith(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // رقم الهاتف إذا كان متوفراً
                                  if (selectedAddress.phoneNumber != null &&
                                      selectedAddress
                                          .phoneNumber!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '📞 ${selectedAddress.phoneNumber}',
                                      style: titilliumRegular.copyWith(
                                        fontSize: 12,
                                        color: TColors.primary,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),

                          // أيقونة السهم
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          // زر حفظ العنوان الحالي
          Obx(() {
            final selectedAddress = addressService.selectedAddress.value;
            final hasAddressData =
                controller.cityController.text.isNotEmpty ||
                controller.streetController.text.isNotEmpty ||
                controller.addressDetailsController.text.isNotEmpty;

            return hasAddressData && selectedAddress == null
                ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressPage(),
                        ),
                      );

                      // إذا تم حفظ العنوان بنجاح، عرض رسالة تأكيد
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('address_saved_successfully'.tr),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: Text('address_save_current'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
                : const SizedBox.shrink();
          }),

          const SizedBox(height: TSizes.spaceBtwInputFields),
        ],
      ),
    );
  }
}
