// lib/data/repositories/vendor_category_repository.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vendor_category_model.dart';

class VendorCategoryRepository extends GetxController {
  static VendorCategoryRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // إضافة فئة جديدة للتاجر
  // Add new category to vendor
  Future<VendorCategoryModel> addVendorCategory(
    AddVendorCategoryRequest request,
  ) async {
    try {
      if (request.vendorId.isEmpty || request.majorCategoryId.isEmpty) {
        throw 'Vendor ID and Category ID are required';
      }

      final response =
          await _client
              .from('vendor_major_categories')
              .insert(request.toJson())
              .select()
              .single();

      if (kDebugMode) {
        print("=======Added Vendor Category==============");
        print(response.toString());
      }

      return VendorCategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error adding vendor category: $e");
      }
      throw 'Failed to add vendor category: ${e.toString()}';
    }
  }

  // الحصول على جميع فئات التاجر
  // Get all vendor categories
  Future<List<VendorCategoryModel>> getVendorCategories(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('vendor_major_categories')
          .select('''
            *,
            major_categories:major_category_id(*)
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('is_primary', ascending: false)
          .order('priority', ascending: true)
          .order('created_at', ascending: true);

      if (kDebugMode) {
        print("=======Vendor Categories==============");
        print("Vendor ID: $vendorId");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => VendorCategoryModel.fromJsonWithCategory(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor categories: $e");
      }
      throw 'Failed to get vendor categories: ${e.toString()}';
    }
  }

  // الحصول على الفئة الأساسية للتاجر
  // Get vendor's primary category
  Future<VendorCategoryModel?> getVendorPrimaryCategory(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response =
          await _client
              .from('vendor_major_categories')
              .select('''
            *,
            major_categories:major_category_id(*)
          ''')
              .eq('vendor_id', vendorId)
              .eq('is_primary', true)
              .eq('is_active', true)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      if (kDebugMode) {
        print("=======Vendor Primary Category==============");
        print("Vendor ID: $vendorId");
        print(response.toString());
      }

      return VendorCategoryModel.fromJsonWithCategory(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor primary category: $e");
      }
      throw 'Failed to get vendor primary category: ${e.toString()}';
    }
  }

  // تحديث فئة التاجر
  // Update vendor category
  Future<VendorCategoryModel> updateVendorCategory(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (id.isEmpty) {
        throw 'Vendor Category ID is required';
      }

      final updatedData = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client
              .from('vendor_major_categories')
              .update(updatedData)
              .eq('id', id)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Vendor Category==============");
        print(response.toString());
      }

      return VendorCategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating vendor category: $e");
      }
      throw 'Failed to update vendor category: ${e.toString()}';
    }
  }

  // تحديث أولويات الفئات
  // Update category priorities
  Future<bool> updateCategoryPriorities(
    UpdateCategoryPrioritiesRequest request,
  ) async {
    try {
      if (request.vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      // تحديث كل فئة على حدة
      // Update each category individually
      for (final item in request.priorities) {
        await _client
            .from('vendor_major_categories')
            .update({
              'priority': item.priority,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('vendor_id', request.vendorId)
            .eq('major_category_id', item.majorCategoryId);
      }

      if (kDebugMode) {
        print("=======Updated Category Priorities==============");
        print("Vendor ID: ${request.vendorId}");
        print("Priorities: ${request.priorities.length}");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error updating category priorities: $e");
      }
      throw 'Failed to update category priorities: ${e.toString()}';
    }
  }

  // إزالة فئة من التاجر
  // Remove category from vendor
  Future<bool> removeVendorCategory(
    String vendorId,
    String majorCategoryId,
  ) async {
    try {
      if (vendorId.isEmpty || majorCategoryId.isEmpty) {
        throw 'Vendor ID and Category ID are required';
      }

      await _client
          .from('vendor_major_categories')
          .delete()
          .eq('vendor_id', vendorId)
          .eq('major_category_id', majorCategoryId);

      if (kDebugMode) {
        print("=======Removed Vendor Category==============");
        print("Vendor ID: $vendorId, Category ID: $majorCategoryId");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error removing vendor category: $e");
      }
      throw 'Failed to remove vendor category: ${e.toString()}';
    }
  }

  // إلغاء تفعيل فئة التاجر
  // Deactivate vendor category
  Future<bool> deactivateVendorCategory(
    String vendorId,
    String majorCategoryId,
  ) async {
    try {
      if (vendorId.isEmpty || majorCategoryId.isEmpty) {
        throw 'Vendor ID and Category ID are required';
      }

      await _client
          .from('vendor_major_categories')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId)
          .eq('major_category_id', majorCategoryId);

      if (kDebugMode) {
        print("=======Deactivated Vendor Category==============");
        print("Vendor ID: $vendorId, Category ID: $majorCategoryId");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error deactivating vendor category: $e");
      }
      throw 'Failed to deactivate vendor category: ${e.toString()}';
    }
  }

  // تفعيل فئة التاجر
  // Activate vendor category
  Future<bool> activateVendorCategory(
    String vendorId,
    String majorCategoryId,
  ) async {
    try {
      if (vendorId.isEmpty || majorCategoryId.isEmpty) {
        throw 'Vendor ID and Category ID are required';
      }

      await _client
          .from('vendor_major_categories')
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId)
          .eq('major_category_id', majorCategoryId);

      if (kDebugMode) {
        print("=======Activated Vendor Category==============");
        print("Vendor ID: $vendorId, Category ID: $majorCategoryId");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error activating vendor category: $e");
      }
      throw 'Failed to activate vendor category: ${e.toString()}';
    }
  }

  // تعيين فئة كأساسية
  // Set category as primary
  Future<bool> setPrimaryCategory(
    String vendorId,
    String majorCategoryId,
  ) async {
    try {
      if (vendorId.isEmpty || majorCategoryId.isEmpty) {
        throw 'Vendor ID and Category ID are required';
      }

      // إلغاء الفئة الأساسية الحالية
      // Remove current primary category
      await _client
          .from('vendor_major_categories')
          .update({
            'is_primary': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId)
          .eq('is_primary', true);

      // تعيين الفئة الجديدة كأساسية
      // Set new category as primary
      await _client
          .from('vendor_major_categories')
          .update({
            'is_primary': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId)
          .eq('major_category_id', majorCategoryId);

      if (kDebugMode) {
        print("=======Set Primary Category==============");
        print("Vendor ID: $vendorId, Category ID: $majorCategoryId");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error setting primary category: $e");
      }
      throw 'Failed to set primary category: ${e.toString()}';
    }
  }

  // التحقق من وجود فئة للتاجر
  // Check if vendor has category
  Future<bool> hasVendorCategory(
    String vendorId,
    String majorCategoryId,
  ) async {
    try {
      if (vendorId.isEmpty || majorCategoryId.isEmpty) {
        return false;
      }

      final response =
          await _client
              .from('vendor_major_categories')
              .select('id')
              .eq('vendor_id', vendorId)
              .eq('major_category_id', majorCategoryId)
              .eq('is_active', true)
              .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking vendor category: $e");
      }
      return false;
    }
  }

  // الحصول على عدد فئات التاجر
  // Get vendor categories count
  Future<int> getVendorCategoriesCount(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        return 0;
      }

      final response = await _client
          .from('vendor_major_categories')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor categories count: $e");
      }
      return 0;
    }
  }

  // البحث في فئات التاجر
  // Search in vendor categories
  Future<List<VendorCategoryModel>> searchVendorCategories(
    String vendorId,
    String query,
  ) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('vendor_major_categories')
          .select('''
            *,
            major_categories:major_category_id(*)
          ''')
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .or('''
            major_categories.name.ilike.%$query%,
            major_categories.arabic_name.ilike.%$query%,
            custom_description.ilike.%$query%
          ''');

      final resultList =
          (response as List)
              .map((data) => VendorCategoryModel.fromJsonWithCategory(data))
              .toList();

      if (kDebugMode) {
        print("=======Search Vendor Categories==============");
        print("Vendor ID: $vendorId, Query: $query");
        print("Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching vendor categories: $e");
      }
      throw 'Failed to search vendor categories: ${e.toString()}';
    }
  }

  // الحصول على إحصائيات فئات التاجر
  // Get vendor categories statistics
  Future<Map<String, dynamic>> getVendorCategoriesStats(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response =
          await _client
              .from('vendor_category_stats')
              .select('*')
              .eq('vendor_id', vendorId)
              .single();

      if (kDebugMode) {
        print("=======Vendor Categories Stats==============");
        print("Vendor ID: $vendorId");
        print(response.toString());
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor categories stats: $e");
      }
      throw 'Failed to get vendor categories stats: ${e.toString()}';
    }
  }
}
