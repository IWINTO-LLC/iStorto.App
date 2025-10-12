import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/payment/views/add_edit_address_page.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/sizes.dart';

/// صفحة عرض وإدارة العناوين
class AddressesListPage extends StatefulWidget {
  const AddressesListPage({super.key});

  @override
  State<AddressesListPage> createState() => _AddressesListPageState();
}

class _AddressesListPageState extends State<AddressesListPage> {
  late AddressService addressService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    if (!Get.isRegistered<AddressService>()) {
      Get.put(AddressService());
    }
    addressService = AddressService.instance;
    await _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoading = true);
    try {
      final userId = AuthController.instance.currentUser.value?.id;
      if (userId != null) {
        await addressService.getUserAddresses(userId);
      }
    } catch (e) {
      print('Error loading addresses: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'my_addresses'.tr,
          style: titilliumBold.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Obx(() {
                final addresses = addressService.addresses;

                if (addresses.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _buildAddressCard(address);
                    },
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'add_new_address'.tr,
          style: titilliumBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'no_addresses_yet'.tr,
            style: titilliumBold.copyWith(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_your_first_address'.tr,
            style: titilliumRegular.copyWith(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(TSizes.paddingSizeDefault),
            child: ElevatedButton.icon(
              onPressed: _addNewAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.black),
              label: Text(
                'add_new_address'.tr,
                style: titilliumBold.copyWith(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddressOptions(address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة الموقع
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: TColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // العنوان
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.title,
                              style: titilliumBold.copyWith(fontSize: 16),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'default'.tr,
                                  style: titilliumBold.copyWith(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: titilliumRegular.copyWith(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // أيقونة الإجراءات
                  IconButton(
                    onPressed: () => _showAddressOptions(address),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),

              // معلومات إضافية
              if (address.phoneNumber != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      address.phoneNumber!,
                      style: titilliumRegular.copyWith(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressOptions(AddressModel address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط التحكم
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // الخيارات
              if (!address.isDefault)
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('set_as_default'.tr),
                  onTap: () {
                    Navigator.pop(context);
                    _setAsDefault(address);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text('edit_address'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _editAddress(address);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('delete_address'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAddress(address);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setAsDefault(AddressModel address) async {
    try {
      final userId = AuthController.instance.currentUser.value?.id;
      if (userId != null && address.id != null) {
        await addressService.setDefaultAddress(address.id!, userId);
        Get.snackbar(
          'success'.tr,
          'default_address_updated'.tr,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'update_failed'.tr}: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _editAddress(AddressModel address) {
    Get.to(() => AddEditAddressPage(address: address));
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('delete_address'.tr),
        content: Text('delete_address_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && address.id != null) {
      try {
        final userId = AuthController.instance.currentUser.value?.id;
        if (userId != null) {
          await addressService.deleteAddress(address.id!, userId);
          Get.snackbar(
            'success'.tr,
            'address_deleted_successfully'.tr,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
          );
        }
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          '${'delete_failed'.tr}: $e',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    }
  }

  void _addNewAddress() {
    Get.to(() => const AddEditAddressPage());
  }
}
