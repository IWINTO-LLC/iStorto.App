// lib/examples/test_supabase_connection.dart
import '../services/supabase_service.dart';

class TestSupabaseConnection {
  static Future<void> testConnection() async {
    print('🧪 [TestSupabaseConnection] Starting Supabase connection test...');

    final client = SupabaseService.client;

    // 1. Test basic connection info
    print('🔗 [TestSupabaseConnection] Supabase client initialized');
    print('🔑 [TestSupabaseConnection] Testing connection...');

    try {
      // 2. Test basic connection
      print('🧪 [TestSupabaseConnection] Testing basic connection...');
      final response = await client.from('categories').select('count');
      print(
        '✅ [TestSupabaseConnection] Basic connection successful: $response',
      );

      // 3. Test table access
      print('🧪 [TestSupabaseConnection] Testing table access...');
      final tableResponse = await client
          .from('categories')
          .select('*')
          .limit(5);
      print(
        '📊 [TestSupabaseConnection] Table access successful: ${tableResponse.length} rows',
      );
      print('📋 [TestSupabaseConnection] Sample data: $tableResponse');

      // 4. Test specific queries
      print('🧪 [TestSupabaseConnection] Testing specific queries...');

      // Test count query
      final countResponse = await client.from('categories').select('id');
      print('📊 [TestSupabaseConnection] Total count: ${countResponse.length}');

      // Test with different select options
      final allColumnsResponse = await client.from('categories').select('*');
      print(
        '📊 [TestSupabaseConnection] All columns query: ${allColumnsResponse.length} rows',
      );

      // Test specific columns
      final specificColumnsResponse = await client
          .from('categories')
          .select('id, name, status');
      print(
        '📊 [TestSupabaseConnection] Specific columns query: ${specificColumnsResponse.length} rows',
      );

      // 5. Test error handling
      print('🧪 [TestSupabaseConnection] Testing error handling...');
      try {
        final errorResponse = await client
            .from('nonexistent_table')
            .select('*');
        print(
          '❌ [TestSupabaseConnection] This should not happen: $errorResponse',
        );
      } catch (e) {
        print('✅ [TestSupabaseConnection] Error handling works: $e');
      }

      // 6. Test RLS (Row Level Security) if enabled
      print('🧪 [TestSupabaseConnection] Testing RLS...');
      try {
        final rlsResponse = await client.from('categories').select('*');
        print(
          '📊 [TestSupabaseConnection] RLS test: ${rlsResponse.length} rows accessible',
        );
      } catch (e) {
        print('⚠️ [TestSupabaseConnection] RLS might be blocking access: $e');
      }

      print('✅ [TestSupabaseConnection] All tests completed successfully!');
    } catch (e) {
      print('❌ [TestSupabaseConnection] Connection test failed: $e');
      print('🔍 [TestSupabaseConnection] Error details: ${e.toString()}');

      // Additional debugging
      if (e.toString().contains('JWT')) {
        print('🔑 [TestSupabaseConnection] JWT/Authentication issue detected');
      }
      if (e.toString().contains('RLS')) {
        print('🔒 [TestSupabaseConnection] Row Level Security issue detected');
      }
      if (e.toString().contains('permission')) {
        print('🚫 [TestSupabaseConnection] Permission issue detected');
      }
      if (e.toString().contains('network')) {
        print('🌐 [TestSupabaseConnection] Network issue detected');
      }
    }
  }

  static Future<void> testCategoriesTable() async {
    print(
      '🧪 [TestSupabaseConnection] Testing categories table specifically...',
    );

    final client = SupabaseService.client;

    try {
      // Test 1: Basic select
      print('🔍 [TestSupabaseConnection] Test 1: Basic select');
      final basicSelect = await client.from('categories').select('*');
      print(
        '📊 [TestSupabaseConnection] Basic select result: ${basicSelect.length} rows',
      );

      // Test 2: Count only
      print('🔍 [TestSupabaseConnection] Test 2: Count only');
      final countSelect = await client.from('categories').select('id');
      print(
        '📊 [TestSupabaseConnection] Count result: ${countSelect.length} rows',
      );

      // Test 3: Specific columns
      print('🔍 [TestSupabaseConnection] Test 3: Specific columns');
      final specificSelect = await client
          .from('categories')
          .select('id, name, arabic_name, status, is_feature');
      print(
        '📊 [TestSupabaseConnection] Specific columns result: ${specificSelect.length} rows',
      );

      // Test 4: With order
      print('🔍 [TestSupabaseConnection] Test 4: With order');
      final orderSelect = await client
          .from('categories')
          .select('*')
          .order('created_at', ascending: false);
      print(
        '📊 [TestSupabaseConnection] Order result: ${orderSelect.length} rows',
      );

      // Test 5: With limit
      print('🔍 [TestSupabaseConnection] Test 5: With limit');
      final limitSelect = await client.from('categories').select('*').limit(10);
      print(
        '📊 [TestSupabaseConnection] Limit result: ${limitSelect.length} rows',
      );

      // Test 6: Filter by status
      print('🔍 [TestSupabaseConnection] Test 6: Filter by status');
      final statusSelect = await client
          .from('categories')
          .select('*')
          .eq('status', 1);
      print(
        '📊 [TestSupabaseConnection] Status filter result: ${statusSelect.length} rows',
      );

      // Test 7: Filter by featured
      print('🔍 [TestSupabaseConnection] Test 7: Filter by featured');
      final featuredSelect = await client
          .from('categories')
          .select('*')
          .eq('is_feature', true);
      print(
        '📊 [TestSupabaseConnection] Featured filter result: ${featuredSelect.length} rows',
      );

      // Test 8: Search
      print('🔍 [TestSupabaseConnection] Test 8: Search');
      final searchSelect = await client
          .from('categories')
          .select('*')
          .ilike('name', '%a%');
      print(
        '📊 [TestSupabaseConnection] Search result: ${searchSelect.length} rows',
      );

      print('✅ [TestSupabaseConnection] All category table tests completed!');
    } catch (e) {
      print('❌ [TestSupabaseConnection] Category table test failed: $e');
    }
  }

  static Future<void> testInsertData() async {
    print('🧪 [TestSupabaseConnection] Testing data insertion...');

    final client = SupabaseService.client;

    try {
      // Test insert a sample category
      final testCategory = {
        'name': 'Test Category',
        'arabic_name': 'فئة تجريبية',
        'status': 1,
        'is_feature': false,
        'parent_id': null,
      };

      print(
        '📝 [TestSupabaseConnection] Inserting test category: $testCategory',
      );
      final insertResponse =
          await client.from('categories').insert(testCategory).select();
      print('✅ [TestSupabaseConnection] Insert successful: $insertResponse');

      // Clean up - delete the test category
      if (insertResponse.isNotEmpty) {
        final categoryId = insertResponse[0]['id'];
        print(
          '🗑️ [TestSupabaseConnection] Cleaning up test category: $categoryId',
        );
        await client.from('categories').delete().eq('id', categoryId);
        print('✅ [TestSupabaseConnection] Cleanup successful');
      }
    } catch (e) {
      print('❌ [TestSupabaseConnection] Insert test failed: $e');
    }
  }
}
