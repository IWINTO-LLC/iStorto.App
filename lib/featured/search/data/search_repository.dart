import 'package:istoreto/featured/search/data/search_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// مستودع البحث الشامل
class SearchRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// البحث الشامل في المنتجات والتجار والفئات (محسن)
  Future<List<SearchResultModel>> searchComprehensive({
    required String query,
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // استخدام الدالة المحسنة للبحث إذا كانت متوفرة
      if (query.isNotEmpty || (filters != null && filters.hasActiveFilters)) {
        return await _searchWithOptimizedFunction(
          query,
          filters,
          limit,
          offset,
        );
      }

      // البحث البسيط بدون فلاتر
      final response = await _client
          .from('comprehensive_search_view')
          .select('*')
          .order('search_score', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }

  /// البحث باستخدام الدالة المحسنة
  Future<List<SearchResultModel>> _searchWithOptimizedFunction(
    String query,
    SearchFilters? filters,
    int limit,
    int offset,
  ) async {
    try {
      // استخدام الدالة المحسنة في قاعدة البيانات
      final response = await _client.rpc(
        'search_products_optimized',
        params: {
          'search_query': query,
          'min_price': filters?.minPrice,
          'max_price': filters?.maxPrice,
          'min_rating': filters?.minRating,
          'is_featured': filters?.isFeatured,
          'is_verified': filters?.isVerified,
          'limit_count': limit,
          'offset_count': offset,
        },
      );

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      // في حالة فشل الدالة المحسنة، استخدم الطريقة العادية
      return await _searchWithStandardMethod(query, filters, limit, offset);
    }
  }

  /// البحث بالطريقة العادية (fallback)
  Future<List<SearchResultModel>> _searchWithStandardMethod(
    String query,
    SearchFilters? filters,
    int limit,
    int offset,
  ) async {
    try {
      // بناء الاستعلام الأساسي
      var queryBuilder = _client.from('comprehensive_search_view').select('*');

      // إضافة البحث النصي إذا كان هناك كلمة بحث
      if (query.isNotEmpty) {
        // البحث في النص الشامل (يضم العنوان، الوصف، اسم المتجر، والفئة)
        queryBuilder = queryBuilder.ilike('search_text', '%$query%');
      }

      // تطبيق الفلاتر
      if (filters != null && filters.hasActiveFilters) {
        queryBuilder = _applyFilters(queryBuilder, filters);
      }

      // تطبيق التحديد والترقيم والترتيب
      final response = await queryBuilder
          .order('search_score', ascending: false)
          .range(offset, offset + limit - 1);

      // تحويل النتائج إلى نماذج
      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث: ${e.toString()}');
    }
  }

  /// البحث في المنتجات فقط
  Future<List<SearchResultModel>> searchProducts({
    required String query,
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder queryBuilder = _client
          .from('comprehensive_search_view')
          .select('*')
          .eq('item_type', 'منتج')
          .ilike('search_text', '%$query%');

      if (filters != null && filters.hasActiveFilters) {
        queryBuilder = _applyFilters(queryBuilder, filters);
      }

      final response = await queryBuilder.range(offset, offset + limit - 1);

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث عن المنتجات: ${e.toString()}');
    }
  }

  /// البحث في التجار فقط
  Future<List<SearchResultModel>> searchVendors({
    required String query,
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder queryBuilder = _client
          .from('comprehensive_search_view')
          .select('*')
          .eq('item_type', 'تاجر')
          .ilike('search_text', '%$query%');

      if (filters != null && filters.hasActiveFilters) {
        queryBuilder = _applyFilters(queryBuilder, filters);
      }

      final response = await queryBuilder.range(offset, offset + limit - 1);

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث عن التجار: ${e.toString()}');
    }
  }

  /// البحث في الفئات فقط
  Future<List<SearchResultModel>> searchCategories({
    required String query,
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder queryBuilder = _client
          .from('comprehensive_search_view')
          .select('*')
          .eq('item_type', 'فئة')
          .ilike('search_text', '%$query%');

      if (filters != null && filters.hasActiveFilters) {
        queryBuilder = _applyFilters(queryBuilder, filters);
      }

      final response = await queryBuilder.range(offset, offset + limit - 1);

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث عن الفئات: ${e.toString()}');
    }
  }

  /// البحث السريع (النتائج الأولى فقط)
  Future<List<SearchResultModel>> quickSearch({
    required String query,
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('comprehensive_search_view')
          .select('*')
          .ilike('search_text', '%$query%')
          .order('search_score', ascending: false)
          .limit(limit);

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث السريع: ${e.toString()}');
    }
  }

  /// البحث المتقدم باستخدام Full-Text Search
  Future<List<SearchResultModel>> advancedSearch({
    required String query,
    SearchFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var queryBuilder = _client.from('comprehensive_search_view').select('*');

      if (query.isNotEmpty) {
        // استخدام البحث المتقدم مع ترتيب حسب الصلة
        queryBuilder = queryBuilder.or(
          'product_title.ilike.%$query%,'
          'product_description.ilike.%$query%,'
          'vendor_name.ilike.%$query%,'
          'vendor_category_title.ilike.%$query%,'
          'search_text.ilike.%$query%',
        );
      }

      if (filters != null && filters.hasActiveFilters) {
        queryBuilder = _applyFilters(queryBuilder, filters);
      }

      final response = await queryBuilder
          .order('search_score', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<SearchResultModel>((data) => SearchResultModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث المتقدم: ${e.toString()}');
    }
  }

  /// الحصول على اقتراحات البحث
  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      // البحث في العناوين للحصول على اقتراحات
      final response = await _client
          .from('comprehensive_search_view')
          .select('product_title, vendor_name, vendor_category_title')
          .ilike('search_text', '%$query%')
          .limit(limit);

      final suggestions = <String>{};

      for (final item in response) {
        if (item['product_title'] != null) {
          suggestions.add(item['product_title'].toString());
        }
        if (item['vendor_name'] != null) {
          suggestions.add(item['vendor_name'].toString());
        }
        if (item['vendor_category_title'] != null) {
          suggestions.add(item['vendor_category_title'].toString());
        }
      }

      return suggestions.toList();
    } catch (e) {
      throw Exception('خطأ في الحصول على اقتراحات البحث: ${e.toString()}');
    }
  }

  /// تطبيق الفلاتر على الاستعلام
  dynamic _applyFilters(dynamic queryBuilder, SearchFilters filters) {
    var builder = queryBuilder;

    // فلتر السعر
    if (filters.minPrice != null) {
      builder = builder.gte('price', filters.minPrice!);
    }
    if (filters.maxPrice != null) {
      builder = builder.lte('price', filters.maxPrice!);
    }

    // فلتر التقييم
    if (filters.minRating != null) {
      builder = builder.gte('rating', filters.minRating!);
    }

    // فلتر التحقق
    if (filters.isVerified != null) {
      builder = builder.eq('is_verified', filters.isVerified!);
    }

    // فلتر المميز
    if (filters.isFeatured != null) {
      builder = builder.eq('is_featured', filters.isFeatured!);
    }

    return builder;
  }

  /// الحصول على إحصائيات البحث
  Future<Map<String, int>> getSearchStats({required String query}) async {
    try {
      final response = await _client
          .from('comprehensive_search_view')
          .select('item_type')
          .ilike('search_text', '%$query%');

      final stats = <String, int>{'منتج': 0, 'تاجر': 0, 'فئة': 0};

      for (final item in response) {
        final type = item['item_type']?.toString() ?? 'منتج';
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('خطأ في الحصول على إحصائيات البحث: ${e.toString()}');
    }
  }
}
