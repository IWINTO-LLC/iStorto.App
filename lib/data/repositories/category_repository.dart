import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get all categories for a specific vendor
  Future<List<CategoryModel>> getCategoriesByVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('vendor_categories')
          .select()
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      if (kDebugMode) {
        print("=======Categories Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => CategoryModel.fromJson(data))
              .toList();

      if (kDebugMode) {
        print("=======Parsed Categories==============");
        print(resultList);
      }
      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting categories: $e");
      }
      throw 'Failed to get categories: ${e.toString()}';
    }
  }

  // Get all active categories
  Future<List<CategoryModel>> getAllActiveCategories() async {
    try {
      final response = await _client
          .from('vendor_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      if (kDebugMode) {
        print("=======All Categories Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => CategoryModel.fromJson(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting all categories: $e");
      }
      throw 'Failed to get all categories: ${e.toString()}';
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      if (categoryId.isEmpty) {
        throw 'Category ID is required';
      }

      final response =
          await _client
              .from('vendor_categories')
              .select()
              .eq('id', categoryId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return CategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting category by ID: $e");
      }
      throw 'Failed to get category: ${e.toString()}';
    }
  }

  // Add new category
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      if (!category.isValid) {
        throw 'Category data is invalid';
      }

      final response =
          await _client
              .from('vendor_categories')
              .insert(category.toJson())
              .select()
              .single();

      if (kDebugMode) {
        print("=======Added Category==============");
        print(response.toString());
      }

      return CategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error adding category: $e");
      }
      throw 'Failed to add category: ${e.toString()}';
    }
  }

  // Update category
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      if (category.id == null || category.id!.isEmpty) {
        throw 'Category ID is required for update';
      }

      final updatedCategory = category.updateTimestamp();
      final response =
          await _client
              .from('vendor_categories')
              .update(updatedCategory.toJson())
              .eq('id', category.id!)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Category==============");
        print(response.toString());
      }

      return CategoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating category: $e");
      }
      throw 'Failed to update category: ${e.toString()}';
    }
  }

  // Delete category (soft delete by setting is_active to false)
  Future<void> deleteCategory(String categoryId) async {
    try {
      if (categoryId.isEmpty) {
        throw 'Category ID is required';
      }

      await _client
          .from('vendor_categories')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId);

      if (kDebugMode) {
        print("Category deleted successfully: $categoryId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting category: $e");
      }
      throw 'Failed to delete category: ${e.toString()}';
    }
  }

  // Permanently delete category
  Future<void> permanentlyDeleteCategory(String categoryId) async {
    try {
      if (categoryId.isEmpty) {
        throw 'Category ID is required';
      }

      await _client.from('vendor_categories').delete().eq('id', categoryId);

      if (kDebugMode) {
        print("Category permanently deleted: $categoryId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error permanently deleting category: $e");
      }
      throw 'Failed to permanently delete category: ${e.toString()}';
    }
  }

  // Search categories by name
  Future<List<CategoryModel>> searchCategories(
    String query, {
    String? vendorId,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final response = await _client
          .from('vendor_categories')
          .select()
          .or('title.ilike.%$query%')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      List<CategoryModel> resultList =
          (response as List)
              .map((data) => CategoryModel.fromJson(data))
              .toList();

      // Filter by vendor if specified
      if (vendorId != null && vendorId.isNotEmpty) {
        resultList =
            resultList
                .where((category) => category.vendorId == vendorId)
                .toList();
      }

      if (kDebugMode) {
        print("=======Search Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching categories: $e");
      }
      throw 'Failed to search categories: ${e.toString()}';
    }
  }

  // Update category sort order
  Future<void> updateCategorySortOrder(
    String categoryId,
    int newSortOrder,
  ) async {
    try {
      if (categoryId.isEmpty) {
        throw 'Category ID is required';
      }

      await _client
          .from('vendor_categories')
          .update({
            'sort_order': newSortOrder,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId);

      if (kDebugMode) {
        print("Category sort order updated: $categoryId -> $newSortOrder");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating sort order: $e");
      }
      throw 'Failed to update sort order: ${e.toString()}';
    }
  }

  // Get categories count for vendor
  Future<int> getCategoriesCount(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final response = await _client
          .from('vendor_categories')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting categories count: $e");
      }
      throw 'Failed to get categories count: ${e.toString()}';
    }
  }

  // Get all categories for a specific user (alias for getCategoriesByVendor)
  Future<List<CategoryModel>> getAllCategoriesUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('vendor_categories')
          .select()
          .eq('vendor_id', userId)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      if (kDebugMode) {
        print("=======User Categories Data==============");
        print("User ID: $userId");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => CategoryModel.fromJson(data))
              .toList();

      if (kDebugMode) {
        print("=======Parsed User Categories==============");
        print("Categories count: ${resultList.length}");
        print(resultList);
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user categories: $e");
      }
      throw 'Failed to get user categories: ${e.toString()}';
    }
  }
}
