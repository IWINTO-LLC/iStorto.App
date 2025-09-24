import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/controllers/auth_controller.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';

class AddressSelector extends StatelessWidget {
  final Function(AddressModel) onAddressSelected;
  final AddressModel? currentAddress;

  const AddressSelector({
    super.key,
    required this.onAddressSelected,
    this.currentAddress,
  });

  @override
  Widget build(BuildContext context) {
    final addressService = Get.put(AddressService());
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id ?? '';

    // جلب العناوين عند فتح الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId.isNotEmpty) {
        addressService.getUserAddresses(userId);
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: TColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'اختر عنوان التوصيل',
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.grey.shade600),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // قائمة العناوين المحفوظة
          Obx(() {
            if (addressService.addresses.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                ...addressService.addresses.map(
                  (address) =>
                      _buildAddressCard(context, address, addressService),
                ),
                const SizedBox(height: 12),
                _buildAddNewAddressButton(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد عناوين محفوظة',
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildAddNewAddressButton(context),
      ],
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    AddressService addressService,
  ) {
    final isSelected = currentAddress?.id == address.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? TColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? TColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isSelected ? TColors.primary : Colors.grey.shade600,
        ),
        title: Text(
          address.title,
          style: titilliumBold.copyWith(
            color: isSelected ? TColors.primary : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.fullAddress,
              style: titilliumRegular.copyWith(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (address.isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'افتراضي',
                  style: titilliumRegular.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected:
              (value) =>
                  _handleAddressAction(context, value, address, addressService),
          itemBuilder:
              (context) => [
                if (!address.isDefault)
                  PopupMenuItem(
                    value: 'set_default',
                    child: Text('تعيين كافتراضي'),
                  ),
                PopupMenuItem(value: 'edit', child: Text('تعديل')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف', style: const TextStyle(color: Colors.red)),
                ),
              ],
        ),
        onTap: () {
          onAddressSelected(address);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildAddNewAddressButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: TColors.primary, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton.icon(
          onPressed: () => _showAddAddressDialog(context),
          icon: const Icon(Icons.add_location),
          label: Text(
            'إضافة عنوان جديد',
            style: titilliumBold.copyWith(fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: TColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAddressAction(
    BuildContext context,
    String action,
    AddressModel address,
    AddressService addressService,
  ) {
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id ?? '';

    switch (action) {
      case 'set_default':
        if (userId.isNotEmpty) {
          addressService.setDefaultAddress(address.id!, userId);
        }
        break;
      case 'edit':
        _showEditAddressDialog(context, address);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address, addressService);
        break;
    }
  }

  void _showAddAddressDialog(BuildContext context) async {
    Navigator.pop(context); // إغلاق نافذة اختيار العناوين

    // فتح صفحة إضافة عنوان جديد
    // TODO: استبدال AddAddressPage بالصفحة الصحيحة
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const AddAddressPage()),
    // );
    final result = false; // مؤقت

    // تحديث قائمة العناوين إذا تم إضافة عنوان بنجاح
    if (result == true) {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id ?? '';
      if (userId.isNotEmpty) {
        Get.find<AddressService>().getUserAddresses(userId);
      }
    }
  }

  void _showEditAddressDialog(BuildContext context, AddressModel address) {
    Navigator.pop(context); // إغلاق نافذة اختيار العناوين

    // فتح نافذة تعديل العنوان
    // TODO: استبدال EditAddressDialog بالنافذة الصحيحة
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تعديل العنوان'),
            content: Text('هذه الميزة قيد التطوير'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('موافق'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AddressModel address,
    AddressService addressService,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('حذف العنوان'),
            content: Text('هل أنت متأكد من حذف هذا العنوان؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  final authController = Get.find<AuthController>();
                  final userId = authController.currentUser.value?.id ?? '';
                  if (userId.isNotEmpty) {
                    addressService.deleteAddress(address.id!, userId);
                  }
                  Navigator.pop(context);
                },
                child: Text('حذف', style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
