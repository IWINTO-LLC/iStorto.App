// lib/data/repositories/major_category_repository.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/major_category_model.dart';
import '../../services/supabase_service.dart';

class MajorCategoryRepository {
  static final SupabaseClient _client = SupabaseService.client;

  // Get all major_categories
  static Future<List<MajorCategoryModel>> getAllCategories() async {
    try {
      print('🔍 [MajorCategoryRepository] Fetching all major_categories...');

      // Test basic connection first
      print('🧪 [MajorCategoryRepository] Testing Supabase connection...');
      try {
        final testResponse =
            await _client.from('major_categories').select();
        print(
          '✅ [MajorCategoryRepository] Connection test successful: $testResponse',
        );
      } catch (e) {
        print('❌ [MajorCategoryRepository] Connection test failed: $e');
      }

      final response = await _client
          .from('major_categories')
          .select()
          .eq('status', 1) // Only active major_categories
          .order('is_feature', ascending: false)
          .order('name', ascending: true);

      print(
        '📊 [MajorCategoryRepository] Raw response: ${response.length} major_categories found',
      );
      print('📋 [MajorCategoryRepository] Response data: $response');

      // Check if response is empty
      if (response.isEmpty) {
        print(
          '⚠️ [MajorCategoryRepository] No major_categories found in database',
        );
        print('🔍 [MajorCategoryRepository] Checking table structure...');

        // Try to get table info
        try {
          final tableInfo = await _client
              .from('major_categories')
              .select('*')
              .limit(1);
          print(
            '📋 [MajorCategoryRepository] Table structure check: $tableInfo',
          );
        } catch (e) {
          print('❌ [MajorCategoryRepository] Table structure check failed: $e');
        }

        // Try different approaches
        print('🔍 [MajorCategoryRepository] Trying alternative queries...');

        try {
          // Try without order
          final noOrderResponse = await _client
              .from('major_categories')
              .select('*');
          print(
            '📊 [MajorCategoryRepository] No order query: ${noOrderResponse.length} rows',
          );
        } catch (e) {
          print('❌ [MajorCategoryRepository] No order query failed: $e');
        }

        try {
          // Try with specific columns
          final specificResponse = await _client
              .from('major_categories')
              .select('id, name');
          print(
            '📊 [MajorCategoryRepository] Specific columns query: ${specificResponse.length} rows',
          );
        } catch (e) {
          print(
            '❌ [MajorCategoryRepository] Specific columns query failed: $e',
          );
        }

        try {
          // Try count query
          final countResponse = await _client
              .from('major_categories')
              .select('id');
          print(
            '📊 [MajorCategoryRepository] Count query: ${countResponse.length} rows',
          );
        } catch (e) {
          print('❌ [MajorCategoryRepository] Count query failed: $e');
        }
      }

      final major_categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing category: ${json['name']} (ID: ${json['id']})',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Successfully parsed ${major_categories.length} major_categories',
      );
      for (var category in major_categories) {
        if (kDebugMode) {
          print(
            '📝 [MajorCategoryRepository] Category: ${category.name} | Arabic: ${category.arabicName} | Featured: ${category.isFeature} | Status: ${category.status}',
          );
        }
      }

      return major_categories;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error fetching major_categories: $e');
      throw Exception('Failed to fetch major_categories: $e');
    }
  }

  // Get major_categories with hierarchy
  static Future<List<MajorCategoryModel>> getCategoriesHierarchy() async {
    try {
      final response = await _client
          .from('major_categories')
          .select()
          .order('created_at', ascending: false);

      final flatList =
          response
              .map<MajorCategoryModel>(
                (json) => MajorCategoryModel.fromJson(json),
              )
              .toList();

      return MajorCategoryModel.buildHierarchy(flatList);
    } catch (e) {
      throw Exception('Failed to fetch major_categories hierarchy: $e');
    }
  }

  // Get root major_categories only
  static Future<List<MajorCategoryModel>> getRootCategories() async {
    try {
      print('🌳 [MajorCategoryRepository] Fetching root major_categories...');

      final response = await _client
          .from('major_categories')
          .select()
          .isFilter('parent_id', null)
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Root major_categories response: ${response.length} found',
      );
      print('📋 [MajorCategoryRepository] Root data: $response');

      final major_categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing root category: ${json['name']}',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Successfully parsed ${major_categories.length} root major_categories',
      );
      for (var category in major_categories) {
        print(
          '🌳 [MajorCategoryRepository] Root: ${category.name} | Parent: ${category.parentId}',
        );
      }

      return major_categories;
    } catch (e) {
      print(
        '❌ [MajorCategoryRepository] Error fetching root major_categories: $e',
      );
      throw Exception('Failed to fetch root major_categories: $e');
    }
  }

  // Get major_categories by parent ID
  static Future<List<MajorCategoryModel>> getCategoriesByParent(
    String parentId,
  ) async {
    try {
      final response = await _client
          .from('major_categories')
          .select()
          .eq('parent_id', parentId)
          .order('created_at', ascending: false);

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch major_categories by parent: $e');
    }
  }

  // Get featured major_categories
  static Future<List<MajorCategoryModel>> getFeaturedCategories() async {
    try {
      print(
        '⭐ [MajorCategoryRepository] Fetching featured major_categories...',
      );

      final response = await _client
          .from('major_categories')
          .select()
          .eq('is_feature', true)
          .eq('status', 1) // Only active major_categories
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Featured major_categories response: ${response.length} found',
      );
      print('📋 [MajorCategoryRepository] Featured data: $response');

      final major_categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing featured category: ${json['name']}',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Successfully parsed ${major_categories.length} featured major_categories',
      );
      for (var category in major_categories) {
        print(
          '⭐ [MajorCategoryRepository] Featured: ${category.name} | Status: ${category.status}',
        );
      }

      return major_categories;
    } catch (e) {
      print(
        '❌ [MajorCategoryRepository] Error fetching featured major_categories: $e',
      );
      throw Exception('Failed to fetch featured major_categories: $e');
    }
  }

  // Get active major_categories only
  static Future<List<MajorCategoryModel>> getActiveCategories() async {
    try {
      final response = await _client
          .from('major_categories')
          .select()
          .eq('status', 1)
          .order('created_at', ascending: false);

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active major_categories: $e');
    }
  }

  // Get category by ID
  static Future<MajorCategoryModel?> getCategoryById(String id) async {
    try {
      final response =
          await _client.from('major_categories').select().eq('id', id).single();

      return MajorCategoryModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch category: $e');
    }
  }

  // Update category status
  static Future<MajorCategoryModel> updateCategoryStatus(
    String id,
    int status,
  ) async {
    try {
      print(
        '🔄 [MajorCategoryRepository] Updating category status: ID=$id, Status=$status',
      );

      final response =
          await _client
              .from('major_categories')
              .update({
                'status': status,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      print('📊 [MajorCategoryRepository] Status update response: $response');
      final updatedCategory = MajorCategoryModel.fromJson(response);
      print(
        '✅ [MajorCategoryRepository] Successfully updated status for: ${updatedCategory.name} to $status',
      );

      return updatedCategory;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error updating category status: $e');
      throw Exception('Failed to update category status: $e');
    }
  }

  // Toggle featured status
  static Future<MajorCategoryModel> toggleFeatured(
    String id,
    bool isFeatured,
  ) async {
    try {
      print(
        '⭐ [MajorCategoryRepository] Toggling featured status: ID=$id, Featured=$isFeatured',
      );

      final response =
          await _client
              .from('major_categories')
              .update({
                'is_feature': isFeatured,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      print('📊 [MajorCategoryRepository] Featured toggle response: $response');
      final updatedCategory = MajorCategoryModel.fromJson(response);
      print(
        '✅ [MajorCategoryRepository] Successfully toggled featured for: ${updatedCategory.name} to $isFeatured',
      );

      return updatedCategory;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error toggling featured status: $e');
      throw Exception('Failed to toggle featured status: $e');
    }
  }

  // Search major_categories
  static Future<List<MajorCategoryModel>> searchCategories(String query) async {
    try {
      print(
        '🔍 [MajorCategoryRepository] Searching major_categories with query: "$query"',
      );

      final response = await _client
          .from('major_categories')
          .select()
          .or('name.ilike.%$query%,arabic_name.ilike.%$query%')
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Search response: ${response.length} results found',
      );
      print('📋 [MajorCategoryRepository] Search data: $response');

      final major_categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing search result: ${json['name']}',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Search completed: ${major_categories.length} major_categories found',
      );
      for (var category in major_categories) {
        print(
          '🔍 [MajorCategoryRepository] Search result: ${category.name} | Arabic: ${category.arabicName}',
        );
      }

      return major_categories;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error searching major_categories: $e');
      throw Exception('Failed to search major_categories: $e');
    }
  }

  // Get major_categories by status
  static Future<List<MajorCategoryModel>> getCategoriesByStatus(
    int status,
  ) async {
    try {
      final response = await _client
          .from('major_categories')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch major_categories by status: $e');
    }
  }

  // Bulk update major_categories
  static Future<List<MajorCategoryModel>> bulkUpdateCategories(
    List<String> ids,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response =
          await _client
              .from('major_categories')
              .update({
                ...updates,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .inFilter('id', ids)
              .select();

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to bulk update major_categories: $e');
    }
  }

  // Get category statistics
  static Future<Map<String, int>> getCategoryStats() async {
    try {
      print('📊 [MajorCategoryRepository] Fetching category statistics...');

      final response = await _client
          .from('major_categories')
          .select('status, is_feature');

      print('📋 [MajorCategoryRepository] Stats raw data: $response');

      int total = response.length;
      int active = response.where((item) => item['status'] == 1).length;
      int pending = response.where((item) => item['status'] == 2).length;
      int inactive = response.where((item) => item['status'] == 3).length;
      int featured =
          response.where((item) => item['is_feature'] == true).length;

      final stats = {
        'total': total,
        'active': active,
        'pending': pending,
        'inactive': inactive,
        'featured': featured,
      };

      print('📊 [MajorCategoryRepository] Category Statistics:');
      print('   📈 Total: $total');
      print('   ✅ Active: $active');
      print('   ⏳ Pending: $pending');
      print('   ❌ Inactive: $inactive');
      print('   ⭐ Featured: $featured');

      return stats;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error fetching statistics: $e');
      throw Exception('Failed to fetch category statistics: $e');
    }
  }

  // Create new category
  static Future<MajorCategoryModel> createCategory(
    Map<String, dynamic> categoryData,
  ) async {
    try {
      print('🔍 [MajorCategoryRepository] Creating new category...');

      final response =
          await _client
              .from('major_categories')
              .insert(categoryData)
              .select()
              .single();

      print('✅ [MajorCategoryRepository] Category created successfully');

      return MajorCategoryModel.fromJson(response);
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error creating category: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category
  static Future<MajorCategoryModel> updateCategory(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🔍 [MajorCategoryRepository] Updating category: $id');

      final response =
          await _client
              .from('major_categories')
              .update(updates)
              .eq('id', id)
              .select()
              .single();

      print('✅ [MajorCategoryRepository] Category updated successfully');

      return MajorCategoryModel.fromJson(response);
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category
  static Future<void> deleteCategory(String id) async {
    try {
      print('🔍 [MajorCategoryRepository] Deleting category: $id');

      await _client.from('major_categories').delete().eq('id', id);

      print('✅ [MajorCategoryRepository] Category deleted successfully');
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }
}
