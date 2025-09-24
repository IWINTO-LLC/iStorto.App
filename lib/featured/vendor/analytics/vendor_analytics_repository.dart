import 'package:istoreto/services/supabase_service.dart';

class VendorAnalyticsRepository {
  static VendorAnalyticsRepository get instance =>
      VendorAnalyticsRepository._();
  VendorAnalyticsRepository._();

  final _client = SupabaseService.client;

  /// Get saved products analytics for a vendor
  Future<List<Map<String, dynamic>>> getVendorSavedProducts(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('vendor_saved_products')
          .select()
          .eq('vendor_id', vendorId)
          .order('times_saved', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get vendor saved products: $e');
    }
  }

  /// Get cart products analytics for a vendor
  Future<List<Map<String, dynamic>>> getVendorCartProducts(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('vendor_cart_products')
          .select()
          .eq('vendor_id', vendorId)
          .order('times_in_cart', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get vendor cart products: $e');
    }
  }

  /// Get combined analytics for a vendor
  Future<List<Map<String, dynamic>>> getVendorAnalytics(String vendorId) async {
    try {
      final response = await _client
          .from('vendor_product_analytics')
          .select()
          .eq('vendor_id', vendorId)
          .order('engagement_score', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get vendor analytics: $e');
    }
  }

  /// Get vendor summary analytics
  Future<Map<String, dynamic>?> getVendorSummary(String vendorId) async {
    try {
      final response =
          await _client
              .from('vendor_summary_analytics')
              .select()
              .eq('vendor_id', vendorId)
              .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to get vendor summary: $e');
    }
  }

  /// Get recent activity for a vendor (last 24 hours)
  Future<List<Map<String, dynamic>>> getVendorRecentActivity(
    String vendorId,
  ) async {
    try {
      final response = await _client.rpc(
        'get_vendor_recent_activity',
        params: {'vendor_uuid': vendorId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get vendor recent activity: $e');
    }
  }

  /// Get top performing products for a vendor
  Future<List<Map<String, dynamic>>> getTopPerformingProducts(
    String vendorId, {
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('vendor_product_analytics')
          .select()
          .eq('vendor_id', vendorId)
          .order('engagement_score', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get top performing products: $e');
    }
  }

  /// Get products with high save rate but low cart conversion
  Future<List<Map<String, dynamic>>> getHighSaveLowCartProducts(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('vendor_product_analytics')
          .select()
          .eq('vendor_id', vendorId)
          .gt('times_saved', 5) // High saves
          .lt('times_in_cart', 2) // Low cart additions
          .order('times_saved', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get high save low cart products: $e');
    }
  }

  /// Get products with high cart additions but low saves
  Future<List<Map<String, dynamic>>> getHighCartLowSaveProducts(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('vendor_product_analytics')
          .select()
          .eq('vendor_id', vendorId)
          .gt('times_in_cart', 5) // High cart additions
          .lt('times_saved', 2) // Low saves
          .order('times_in_cart', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get high cart low save products: $e');
    }
  }

  /// Get analytics for a specific product
  Future<Map<String, dynamic>?> getProductAnalytics(
    String vendorId,
    String productId,
  ) async {
    try {
      final response =
          await _client
              .from('vendor_product_analytics')
              .select()
              .eq('vendor_id', vendorId)
              .eq('product_id', productId)
              .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to get product analytics: $e');
    }
  }

  /// Get daily analytics for a vendor (last 30 days)
  Future<List<Map<String, dynamic>>> getVendorDailyAnalytics(
    String vendorId,
  ) async {
    try {
      final response = await _client.rpc(
        'get_vendor_daily_analytics',
        params: {'vendor_uuid': vendorId, 'days_back': 30},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get vendor daily analytics: $e');
    }
  }

  /// Get user engagement metrics for a vendor
  Future<Map<String, dynamic>?> getUserEngagementMetrics(
    String vendorId,
  ) async {
    try {
      final response = await _client.rpc(
        'get_vendor_user_engagement',
        params: {'vendor_uuid': vendorId},
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get user engagement metrics: $e');
    }
  }

  /// Get competitor analysis (compare with other vendors)
  Future<List<Map<String, dynamic>>> getCompetitorAnalysis(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('vendor_summary_analytics')
          .select()
          .order('total_potential_revenue', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get competitor analysis: $e');
    }
  }

  /// Get trending products across all vendors
  Future<List<Map<String, dynamic>>> getTrendingProducts({
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('vendor_product_analytics')
          .select()
          .order('engagement_score', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get trending products: $e');
    }
  }

  /// Get market insights for vendors
  Future<Map<String, dynamic>?> getMarketInsights() async {
    try {
      final response = await _client.rpc('get_market_insights');

      return response;
    } catch (e) {
      throw Exception('Failed to get market insights: $e');
    }
  }
}
