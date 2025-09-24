import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/address/pages/add_address_page.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';

class ManageAddressesPage extends StatefulWidget {
  const ManageAddressesPage({super.key});

  @override
  State<ManageAddressesPage> createState() => _ManageAddressesPageState();
}

class _ManageAddressesPageState extends State<ManageAddressesPage> {
  final AddressService _addressService = Get.find<AddressService>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = VendorController.instance.profileData.value.userId;
      if (userId != null && userId.isNotEmpty) {
        await _addressService.getUserAddresses(userId);
      }
    } catch (e) {
      print('Error loading addresses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف العنوان "${address.title}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final userId = VendorController.instance.profileData.value.userId;
        if (userId != null && userId.isNotEmpty) {
          final success = await _addressService.deleteAddress(
            address.id!,
            userId,
          );
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حذف العنوان بنجاح'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل في حذف العنوان'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حذف العنوان'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _setDefaultAddress(AddressModel address) async {
    try {
      final userId = VendorController.instance.profileData.value.userId;
      if (userId != null && userId.isNotEmpty) {
        final success = await _addressService.setDefaultAddress(
          address.id!,
          userId,
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تعيين العنوان كافتراضي'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تعيين العنوان الافتراضي'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة العناوين',
          style: titilliumBold.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                  ),
                )
                : Obx(() {
                  final addresses = _addressService.addresses;

                  if (addresses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد عناوين محفوظة',
                            style: titilliumBold.copyWith(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط على زر الإضافة لإنشاء عنوان جديد',
                            style: titilliumRegular.copyWith(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadAddresses,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: TColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        address.title,
                                        style: titilliumBold.copyWith(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (address.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: TColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'افتراضي',
                                          style: titilliumRegular.copyWith(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  address.fullAddress,
                                  style: titilliumRegular.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                if (address.phoneNumber?.isNotEmpty ??
                                    false) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '📞 ${address.phoneNumber}',
                                    style: titilliumRegular.copyWith(
                                      fontSize: 13,
                                      color: TColors.primary,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (!address.isDefault)
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed:
                                              () => _setDefaultAddress(address),
                                          icon: Icon(
                                            Icons.star_border,
                                            size: 16,
                                          ),
                                          label: Text('تعيين كافتراضي'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: TColors.primary,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed:
                                            () => _deleteAddress(address),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                        ),
                                        label: Text('حذف'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          );

          if (result == true) {
            _loadAddresses(); // إعادة تحميل العناوين بعد الإضافة
          }
        },
        backgroundColor: TColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
