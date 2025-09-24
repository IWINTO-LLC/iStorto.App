import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'vendor_model.dart';

class VendorRepository extends GetxController {
  static VendorRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get vendor by ID
  Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response =
          await _client
              .from('vendors')
              .select()
              .eq('id', vendorId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      if (kDebugMode) {
        print("=======Vendor Data==============");
        print(response.toString());
      }

      return VendorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor by ID: $e");
      }
      throw 'Failed to get vendor: ${e.toString()}';
    }
  }

  // Get vendor by user ID
  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response =
          await _client
              .from('vendors')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      if (kDebugMode) {
        print("=======Vendor by User ID==============");
        print(response.toString());
      }

      return VendorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor by user ID: $e");
      }
      throw 'Failed to get vendor by user ID: ${e.toString()}';
    }
  }

  // Get all active vendors
  Future<List<VendorModel>> getAllActiveVendors() async {
    try {
      final response = await _client
          .from('vendors')
          .select()
          .eq('organization_activated', true)
          .eq('organization_deleted', false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======All Active Vendors==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => VendorModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting all active vendors: $e");
      }
      throw 'Failed to get all active vendors: ${e.toString()}';
    }
  }

  // Create new vendor
  Future<VendorModel> createVendor(VendorModel vendor) async {
    try {
      if (!vendor.isValid) {
        throw 'Vendor data is invalid';
      }

      final response =
          await _client
              .from('vendors')
              .insert(vendor.toJson())
              .select()
              .single();

      if (kDebugMode) {
        print("=======Created Vendor==============");
        print(response.toString());
      }

      return VendorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating vendor: $e");
      }
      throw 'Failed to create vendor: ${e.toString()}';
    }
  }

  // Update vendor profile
  Future<VendorModel> updateVendorProfile(
    String vendorId,
    VendorModel vendor,
  ) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final updatedVendor = vendor.updateTimestamp();
      final response =
          await _client
              .from('vendors')
              .update(updatedVendor.toJson())
              .eq('id', vendorId)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Vendor Profile==============");
        print(response.toString());
      }

      return VendorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating vendor profile: $e");
      }
      throw 'Failed to update vendor profile: ${e.toString()}';
    }
  }

  // Update specific field
  Future<void> updateField({
    required String vendorId,
    required String fieldName,
    required dynamic newValue,
  }) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client
          .from('vendors')
          .update({
            fieldName: newValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      if (kDebugMode) {
        print('✅ تم تحديث الحقل "$fieldName" إلى "$newValue" بنجاح');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ حدث خطأ أثناء التحديث: $e');
      }
      throw 'Failed to update field: ${e.toString()}';
    }
  }

  // Delete vendor (soft delete)
  Future<void> deleteVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client
          .from('vendors')
          .update({
            'organization_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      if (kDebugMode) {
        print("Vendor deleted successfully: $vendorId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting vendor: $e");
      }
      throw 'Failed to delete vendor: ${e.toString()}';
    }
  }

  // Permanently delete vendor
  Future<void> permanentlyDeleteVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client.from('vendors').delete().eq('id', vendorId);

      if (kDebugMode) {
        print("Vendor permanently deleted: $vendorId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error permanently deleting vendor: $e");
      }
      throw 'Failed to permanently delete vendor: ${e.toString()}';
    }
  }

  // Search vendors by organization name
  Future<List<VendorModel>> searchVendors(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final response = await _client
          .from('vendors')
          .select()
          .ilike('organization_name', '%$query%')
          .eq('organization_activated', true)
          .eq('organization_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List).map((data) => VendorModel.fromJson(data)).toList();

      if (kDebugMode) {
        print("=======Search Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching vendors: $e");
      }
      throw 'Failed to search vendors: ${e.toString()}';
    }
  }

  // Get vendors count
  Future<int> getVendorsCount() async {
    try {
      final response = await _client
          .from('vendors')
          .select('id')
          .eq('organization_activated', true)
          .eq('organization_deleted', false);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendors count: $e");
      }
      throw 'Failed to get vendors count: ${e.toString()}';
    }
  }

  // Check if slug is available
  Future<bool> isSlugAvailable(String slug) async {
    try {
      if (slug.isEmpty) {
        return false;
      }

      final response =
          await _client
              .from('vendors')
              .select('id')
              .eq('slugn', slug)
              .maybeSingle();

      return response == null;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking slug availability: $e");
      }
      throw 'Failed to check slug availability: ${e.toString()}';
    }
  }

  // Activate/Deactivate vendor
  Future<void> toggleVendorActivation(String vendorId, bool isActive) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client
          .from('vendors')
          .update({
            'organization_activated': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      if (kDebugMode) {
        print("Vendor activation toggled: $vendorId -> $isActive");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling vendor activation: $e");
      }
      throw 'Failed to toggle vendor activation: ${e.toString()}';
    }
  }
}
