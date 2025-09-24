import 'package:get/get.dart';
import 'package:istoreto/featured/payment/data/address_model.dart';
import 'package:istoreto/featured/payment/data/address_repository.dart';

class AddressService extends GetxController {
  static AddressService get instance => Get.find();

  final AddressRepository _addressRepository = AddressRepository();
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // جلب جميع عناوين المستخدم
  Future<void> getUserAddresses(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final addressesList = await _addressRepository.getAddressesByUser(userId);
      addresses.value = addressesList;
    } catch (e) {
      print('Error fetching addresses: $e');
      errorMessage.value = 'Error fetching addresses: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // حفظ عنوان جديد
  Future<bool> saveAddress(AddressModel address, String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // إنشاء عنوان جديد مع معرف المستخدم
      final newAddress = address.copyWith(userId: userId);

      final createdAddress = await _addressRepository.createAddress(newAddress);

      if (createdAddress != null) {
        // إذا كان العنوان الجديد هو الافتراضي، إلغاء الافتراضي من العناوين الأخرى
        if (createdAddress.isDefault) {
          await _addressRepository.setAsDefault(createdAddress.id!, userId);
        }

        // تحديث القائمة المحلية
        await getUserAddresses(userId);
        return true;
      } else {
        errorMessage.value = 'Failed to create address';
        return false;
      }
    } catch (e) {
      print('Error saving address: $e');
      errorMessage.value = 'Error saving address: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // حذف عنوان
  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _addressRepository.deleteAddress(addressId);

      if (success) {
        // تحديث القائمة المحلية
        await getUserAddresses(userId);
        return true;
      } else {
        errorMessage.value = 'Failed to delete address';
        return false;
      }
    } catch (e) {
      print('Error deleting address: $e');
      errorMessage.value = 'Error deleting address: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث عنوان
  Future<bool> updateAddress(AddressModel address, String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final updatedAddress = await _addressRepository.updateAddress(address);

      if (updatedAddress != null) {
        // إذا كان العنوان المحدث هو الافتراضي، إلغاء الافتراضي من العناوين الأخرى
        if (updatedAddress.isDefault) {
          await _addressRepository.setAsDefault(updatedAddress.id!, userId);
        }

        // تحديث القائمة المحلية
        await getUserAddresses(userId);
        return true;
      } else {
        errorMessage.value = 'Failed to update address';
        return false;
      }
    } catch (e) {
      print('Error updating address: $e');
      errorMessage.value = 'Error updating address: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // تعيين عنوان كافتراضي
  Future<bool> setDefaultAddress(String addressId, String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _addressRepository.setAsDefault(addressId, userId);

      if (success) {
        // تحديث القائمة المحلية
        await getUserAddresses(userId);
        return true;
      } else {
        errorMessage.value = 'Failed to set default address';
        return false;
      }
    } catch (e) {
      print('Error setting default address: $e');
      errorMessage.value = 'Error setting default address: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // جلب العنوان الافتراضي
  AddressModel? getDefaultAddress() {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // جلب العنوان الافتراضي من قاعدة البيانات
  Future<AddressModel?> getDefaultAddressFromDB(String userId) async {
    try {
      return await _addressRepository.getDefaultAddress(userId);
    } catch (e) {
      print('Error getting default address from DB: $e');
      return null;
    }
  }

  // اختيار عنوان
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  // مسح العنوان المحدد
  void clearSelectedAddress() {
    selectedAddress.value = null;
  }

  // البحث في العناوين
  Future<List<AddressModel>> searchAddresses(
    String userId,
    String query,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final searchResults = await _addressRepository.searchAddresses(
        userId,
        query,
      );
      return searchResults;
    } catch (e) {
      print('Error searching addresses: $e');
      errorMessage.value = 'Error searching addresses: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // جلب العناوين حسب المدينة
  Future<List<AddressModel>> getAddressesByCity(
    String userId,
    String city,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final cityAddresses = await _addressRepository.getAddressesByCity(
        userId,
        city,
      );
      return cityAddresses;
    } catch (e) {
      print('Error getting addresses by city: $e');
      errorMessage.value = 'Error getting addresses by city: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // جلب العناوين القريبة من موقع معين
  Future<List<AddressModel>> getAddressesNearLocation(
    String userId,
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final nearbyAddresses = await _addressRepository.getAddressesNearLocation(
        userId,
        latitude,
        longitude,
        radiusKm,
      );
      return nearbyAddresses;
    } catch (e) {
      print('Error getting addresses near location: $e');
      errorMessage.value = 'Error getting addresses near location: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // نسخ عنوان
  Future<AddressModel?> duplicateAddress(
    String addressId,
    String newTitle,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final duplicatedAddress = await _addressRepository.duplicateAddress(
        addressId,
        newTitle,
      );

      if (duplicatedAddress != null) {
        // تحديث القائمة المحلية
        await getUserAddresses(duplicatedAddress.userId);
      }

      return duplicatedAddress;
    } catch (e) {
      print('Error duplicating address: $e');
      errorMessage.value = 'Error duplicating address: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // جلب إحصائيات العناوين
  Future<Map<String, int>> getAddressStatistics(String userId) async {
    try {
      return await _addressRepository.getAddressStatistics(userId);
    } catch (e) {
      print('Error getting address statistics: $e');
      return {};
    }
  }

  // التحقق من وجود عناوين للمستخدم
  Future<bool> hasAddresses(String userId) async {
    try {
      return await _addressRepository.hasAddresses(userId);
    } catch (e) {
      print('Error checking if user has addresses: $e');
      return false;
    }
  }

  // جلب عدد العناوين
  Future<int> getAddressesCount(String userId) async {
    try {
      return await _addressRepository.getAddressesCount(userId);
    } catch (e) {
      print('Error getting addresses count: $e');
      return 0;
    }
  }

  // تحديث إحداثيات العنوان
  Future<bool> updateAddressCoordinates(
    String addressId,
    double latitude,
    double longitude,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _addressRepository.updateAddressCoordinates(
        addressId,
        latitude,
        longitude,
      );

      if (success) {
        // تحديث العنوان في القائمة المحلية
        final addressIndex = addresses.indexWhere((a) => a.id == addressId);
        if (addressIndex != -1) {
          addresses[addressIndex] = addresses[addressIndex].copyWith(
            latitude: latitude,
            longitude: longitude,
          );
        }
      }

      return success;
    } catch (e) {
      print('Error updating address coordinates: $e');
      errorMessage.value = 'Error updating address coordinates: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // مسح رسالة الخطأ
  void clearError() {
    errorMessage.value = '';
  }

  // إعادة تحميل العناوين
  Future<void> refreshAddresses(String userId) async {
    await getUserAddresses(userId);
  }
}
