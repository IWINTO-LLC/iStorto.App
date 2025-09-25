// lib/data/repositories/major_category_repository.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/major_category_model.dart';
import '../../services/supabase_service.dart';

class MajorCategoryRepository {
  static final SupabaseClient _client = SupabaseService.client;

  // Get all categories
  static Future<List<MajorCategoryModel>> getAllCategories() async {
    try {
      print('🔍 [MajorCategoryRepository] Fetching all categories...');

      // Test basic connection first
      print('🧪 [MajorCategoryRepository] Testing Supabase connection...');
      try {
        final testResponse = await _client.from('categories').select('count');
        print(
          '✅ [MajorCategoryRepository] Connection test successful: $testResponse',
        );
      } catch (e) {
        print('❌ [MajorCategoryRepository] Connection test failed: $e');
      }

      final response = await _client
          .from('categories')
          .select()
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Raw response: ${response.length} categories found',
      );
      print('📋 [MajorCategoryRepository] Response data: $response');

      // Check if response is empty
      if (response.isEmpty) {
        print('⚠️ [MajorCategoryRepository] No categories found in database');
        print('🔍 [MajorCategoryRepository] Checking table structure...');

        // Try to get table info
        try {
          final tableInfo = await _client
              .from('categories')
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
          final noOrderResponse = await _client.from('categories').select('*');
          print(
            '📊 [MajorCategoryRepository] No order query: ${noOrderResponse.length} rows',
          );
        } catch (e) {
          print('❌ [MajorCategoryRepository] No order query failed: $e');
        }

        try {
          // Try with specific columns
          final specificResponse = await _client
              .from('categories')
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
          final countResponse = await _client.from('categories').select('id');
          print(
            '📊 [MajorCategoryRepository] Count query: ${countResponse.length} rows',
          );
        } catch (e) {
          print('❌ [MajorCategoryRepository] Count query failed: $e');
        }
      }

      final categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing category: ${json['name']} (ID: ${json['id']})',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Successfully parsed ${categories.length} categories',
      );
      for (var category in categories) {
        if (kDebugMode) {
          print(
            '📝 [MajorCategoryRepository] Category: ${category.name} | Arabic: ${category.arabicName} | Featured: ${category.isFeature} | Status: ${category.status}',
          );
        }
      }

      return categories;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Get categories with hierarchy
  static Future<List<MajorCategoryModel>> getCategoriesHierarchy() async {
    try {
      final response = await _client
          .from('categories')
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
      throw Exception('Failed to fetch categories hierarchy: $e');
    }
  }

  // Get root categories only
  static Future<List<MajorCategoryModel>> getRootCategories() async {
    try {
      print('🌳 [MajorCategoryRepository] Fetching root categories...');

      final response = await _client
          .from('categories')
          .select()
          .isFilter('parent_id', null)
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Root categories response: ${response.length} found',
      );
      print('📋 [MajorCategoryRepository] Root data: $response');

      final categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing root category: ${json['name']}',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Successfully parsed ${categories.length} root categories',
      );
      for (var category in categories) {
        print(
          '🌳 [MajorCategoryRepository] Root: ${category.name} | Parent: ${category.parentId}',
        );
      }

      return categories;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error fetching root categories: $e');
      throw Exception('Failed to fetch root categories: $e');
    }
  }

  // Get categories by parent ID
  static Future<List<MajorCategoryModel>> getCategoriesByParent(
    String parentId,
  ) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('parent_id', parentId)
          .order('created_at', ascending: false);

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories by parent: $e');
    }
  }

  // Get featured categories
  static Future<List<MajorCategoryModel>> getFeaturedCategories() async {
    try {
      print('⭐ [MajorCategoryRepository] Fetching featured categories...');

      final response = await _client
          .from('categories')
          .select()
          .eq('is_feature', true)
          .eq('status', 1) // Only active categories
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Featured categories response: ${response.length} found',
      );
      print('📋 [MajorCategoryRepository] Featured data: $response');

      final categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing featured category: ${json['name']}',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Successfully parsed ${categories.length} featured categories',
      );
      for (var category in categories) {
        print(
          '⭐ [MajorCategoryRepository] Featured: ${category.name} | Status: ${category.status}',
        );
      }

      return categories;
    } catch (e) {
      print(
        '❌ [MajorCategoryRepository] Error fetching featured categories: $e',
      );
      throw Exception('Failed to fetch featured categories: $e');
    }
  }

  // Get active categories only
  static Future<List<MajorCategoryModel>> getActiveCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('status', 1)
          .order('created_at', ascending: false);

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active categories: $e');
    }
  }

  // Get category by ID
  static Future<MajorCategoryModel?> getCategoryById(String id) async {
    try {
      final response =
          await _client.from('categories').select().eq('id', id).single();

      return MajorCategoryModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch category: $e');
    }
  }

  // Create new category
  static Future<MajorCategoryModel> createCategory(
    MajorCategoryModel category,
  ) async {
    try {
      print(
        '➕ [MajorCategoryRepository] Creating new category: ${category.name}',
      );
      print('📝 [MajorCategoryRepository] Category data: ${category.toJson()}');

      final response =
          await _client
              .from('categories')
              .insert(category.toJson())
              .select()
              .single();

      print('📊 [MajorCategoryRepository] Create response: $response');
      final createdCategory = MajorCategoryModel.fromJson(response);
      print(
        '✅ [MajorCategoryRepository] Successfully created category: ${createdCategory.name} (ID: ${createdCategory.id})',
      );

      return createdCategory;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error creating category: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category
  static Future<MajorCategoryModel> updateCategory(
    MajorCategoryModel category,
  ) async {
    try {
      print(
        '✏️ [MajorCategoryRepository] Updating category: ${category.name} (ID: ${category.id})',
      );
      print(
        '📝 [MajorCategoryRepository] Update data: ${category.updateTimestamp().toJson()}',
      );

      final response =
          await _client
              .from('categories')
              .update(category.updateTimestamp().toJson())
              .eq('id', category.id!)
              .select()
              .single();

      print('📊 [MajorCategoryRepository] Update response: $response');
      final updatedCategory = MajorCategoryModel.fromJson(response);
      print(
        '✅ [MajorCategoryRepository] Successfully updated category: ${updatedCategory.name}',
      );

      return updatedCategory;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category
  static Future<void> deleteCategory(String id) async {
    try {
      print('🗑️ [MajorCategoryRepository] Deleting category with ID: $id');

      // First check if category has children
      final children = await getCategoriesByParent(id);
      print(
        '👶 [MajorCategoryRepository] Found ${children.length} children for category $id',
      );

      if (children.isNotEmpty) {
        print(
          '❌ [MajorCategoryRepository] Cannot delete category with subcategories',
        );
        throw Exception(
          'Cannot delete category with subcategories. Please delete subcategories first.',
        );
      }

      await _client.from('categories').delete().eq('id', id);
      print('✅ [MajorCategoryRepository] Successfully deleted category: $id');
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
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
              .from('categories')
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
              .from('categories')
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

  // Search categories
  static Future<List<MajorCategoryModel>> searchCategories(String query) async {
    try {
      print(
        '🔍 [MajorCategoryRepository] Searching categories with query: "$query"',
      );

      final response = await _client
          .from('categories')
          .select()
          .or('name.ilike.%$query%,arabic_name.ilike.%$query%')
          .order('created_at', ascending: false);

      print(
        '📊 [MajorCategoryRepository] Search response: ${response.length} results found',
      );
      print('📋 [MajorCategoryRepository] Search data: $response');

      final categories =
          response.map<MajorCategoryModel>((json) {
            print(
              '🔄 [MajorCategoryRepository] Parsing search result: ${json['name']}',
            );
            return MajorCategoryModel.fromJson(json);
          }).toList();

      print(
        '✅ [MajorCategoryRepository] Search completed: ${categories.length} categories found',
      );
      for (var category in categories) {
        print(
          '🔍 [MajorCategoryRepository] Search result: ${category.name} | Arabic: ${category.arabicName}',
        );
      }

      return categories;
    } catch (e) {
      print('❌ [MajorCategoryRepository] Error searching categories: $e');
      throw Exception('Failed to search categories: $e');
    }
  }

  // Get categories by status
  static Future<List<MajorCategoryModel>> getCategoriesByStatus(
    int status,
  ) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return response
          .map<MajorCategoryModel>((json) => MajorCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories by status: $e');
    }
  }

  // Bulk update categories
  static Future<List<MajorCategoryModel>> bulkUpdateCategories(
    List<String> ids,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response =
          await _client
              .from('categories')
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
      throw Exception('Failed to bulk update categories: $e');
    }
  }

  // Get category statistics
  static Future<Map<String, int>> getCategoryStats() async {
    try {
      print('📊 [MajorCategoryRepository] Fetching category statistics...');

      final response = await _client
          .from('categories')
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
}
