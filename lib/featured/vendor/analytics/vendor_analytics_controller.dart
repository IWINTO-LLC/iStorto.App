import 'package:get/get.dart';
import 'package:istoreto/featured/vendor/analytics/vendor_analytics_repository.dart';

class VendorAnalyticsController extends GetxController {
  static VendorAnalyticsController get instance => Get.find();

  final _repository = VendorAnalyticsRepository.instance;

  // Observable data
  final savedProducts = <Map<String, dynamic>>[].obs;
  final cartProducts = <Map<String, dynamic>>[].obs;
  final productAnalytics = <Map<String, dynamic>>[].obs;
  final vendorSummary = Rxn<Map<String, dynamic>>();
  final recentActivity = <Map<String, dynamic>>[].obs;
  final topPerformingProducts = <Map<String, dynamic>>[].obs;
  final highSaveLowCartProducts = <Map<String, dynamic>>[].obs;
  final highCartLowSaveProducts = <Map<String, dynamic>>[].obs;
  final trendingProducts = <Map<String, dynamic>>[].obs;
  final competitorAnalysis = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoading = false.obs;
  final isLoadingSummary = false.obs;
  final isLoadingRecentActivity = false.obs;
  final isLoadingTopProducts = false.obs;

  // Current vendor ID
  String? _currentVendorId;

  @override
  void onInit() {
    super.onInit();
    // Initialize with current user's vendor ID if available
    // _currentVendorId = getCurrentVendorId();
  }

  /// Set current vendor ID
  void setVendorId(String vendorId) {
    _currentVendorId = vendorId;
  }

  /// Get current vendor ID
  String? get currentVendorId => _currentVendorId;

  /// Load all analytics for current vendor
  Future<void> loadVendorAnalytics() async {
    if (_currentVendorId == null) return;

    try {
      isLoading.value = true;
      
      // Load all analytics in parallel
      await Future.wait([
        loadSavedProducts(),
        loadCartProducts(),
        loadProductAnalytics(),
        loadVendorSummary(),
        loadRecentActivity(),
        loadTopPerformingProducts(),
      ]);

      Get.snackbar(
        'Success',
        'Analytics loaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load analytics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load saved products analytics
  Future<void> loadSavedProducts() async {
    if (_currentVendorId == null) return;

    try {
      final data = await _repository.getVendorSavedProducts(_currentVendorId!);
      savedProducts.value = data;
    } catch (e) {
      throw Exception('Failed to load saved products: $e');
    }
  }

  /// Load cart products analytics
  Future<void> loadCartProducts() async {
    if (_currentVendorId == null) return;

    try {
      final data = await _repository.getVendorCartProducts(_currentVendorId!);
      cartProducts.value = data;
    } catch (e) {
      throw Exception('Failed to load cart products: $e');
    }
  }

  /// Load product analytics
  Future<void> loadProductAnalytics() async {
    if (_currentVendorId == null) return;

    try {
      final data = await _repository.getVendorAnalytics(_currentVendorId!);
      productAnalytics.value = data;
    } catch (e) {
      throw Exception('Failed to load product analytics: $e');
    }
  }

  /// Load vendor summary
  Future<void> loadVendorSummary() async {
    if (_currentVendorId == null) return;

    try {
      isLoadingSummary.value = true;
      final data = await _repository.getVendorSummary(_currentVendorId!);
      vendorSummary.value = data;
    } catch (e) {
      throw Exception('Failed to load vendor summary: $e');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  /// Load recent activity
  Future<void> loadRecentActivity() async {
    if (_currentVendorId == null) return;

    try {
      isLoadingRecentActivity.value = true;
      final data = await _repository.getVendorRecentActivity(_currentVendorId!);
      recentActivity.value = data;
    } catch (e) {
      throw Exception('Failed to load recent activity: $e');
    } finally {
      isLoadingRecentActivity.value = false;
    }
  }

  /// Load top performing products
  Future<void> loadTopPerformingProducts({int limit = 10}) async {
    if (_currentVendorId == null) return;

    try {
      isLoadingTopProducts.value = true;
      final data = await _repository.getTopPerformingProducts(_currentVendorId!, limit: limit);
      topPerformingProducts.value = data;
    } catch (e) {
      throw Exception('Failed to load top performing products: $e');
    } finally {
      isLoadingTopProducts.value = false;
    }
  }

  /// Load high save low cart products
  Future<void> loadHighSaveLowCartProducts() async {
    if (_currentVendorId == null) return;

    try {
      final data = await _repository.getHighSaveLowCartProducts(_currentVendorId!);
      highSaveLowCartProducts.value = data;
    } catch (e) {
      throw Exception('Failed to load high save low cart products: $e');
    }
  }

  /// Load high cart low save products
  Future<void> loadHighCartLowSaveProducts() async {
    if (_currentVendorId == null) return;

    try {
      final data = await _repository.getHighCartLowSaveProducts(_currentVendorId!);
      highCartLowSaveProducts.value = data;
    } catch (e) {
      throw Exception('Failed to load high cart low save products: $e');
    }
  }

  /// Load trending products
  Future<void> loadTrendingProducts({int limit = 20}) async {
    try {
      final data = await _repository.getTrendingProducts(limit: limit);
      trendingProducts.value = data;
    } catch (e) {
      throw Exception('Failed to load trending products: $e');
    }
  }

  /// Load competitor analysis
  Future<void> loadCompetitorAnalysis() async {
    if (_currentVendorId == null) return;

    try {
      final data = await _repository.getCompetitorAnalysis(_currentVendorId!);
      competitorAnalysis.value = data;
    } catch (e) {
      throw Exception('Failed to load competitor analysis: $e');
    }
  }

  /// Get analytics for specific product
  Future<Map<String, dynamic>?> getProductAnalytics(String productId) async {
    if (_currentVendorId == null) return null;

    try {
      return await _repository.getProductAnalytics(_currentVendorId!, productId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get product analytics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await loadVendorAnalytics();
  }

  /// Get total saved products count
  int get totalSavedProducts => savedProducts.length;

  /// Get total cart products count
  int get totalCartProducts => cartProducts.length;

  /// Get total unique users who saved products
  int get totalUniqueSavers {
    return savedProducts.fold(0, (sum, product) => 
      sum + (product['unique_users_saved'] as int? ?? 0));
  }

  /// Get total unique users who added to cart
  int get totalUniqueCartUsers {
    return cartProducts.fold(0, (sum, product) => 
      sum + (product['unique_users_in_cart'] as int? ?? 0));
  }

  /// Get total potential revenue
  double get totalPotentialRevenue {
    final summary = vendorSummary.value;
    return (summary?['total_potential_revenue'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get average engagement score
  double get averageEngagementScore {
    final summary = vendorSummary.value;
    return (summary?['average_engagement_score'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get most recent activity time
  DateTime? get mostRecentActivity {
    final summary = vendorSummary.value;
    final timestamp = summary?['most_recent_activity'];
    return timestamp != null ? DateTime.parse(timestamp.toString()) : null;
  }

  /// Get products with highest engagement
  List<Map<String, dynamic>> get topEngagementProducts {
    return productAnalytics
        .where((product) => ((product['engagement_score'] as num?)?.toDouble() ?? 0) > 0)
        .toList()
      ..sort((a, b) => 
        ((b['engagement_score'] as num?)?.toDouble() ?? 0)
        .compareTo((a['engagement_score'] as num?)?.toDouble() ?? 0));
  }

  /// Get products needing attention (high save, low cart)
  List<Map<String, dynamic>> get productsNeedingAttention {
    return highSaveLowCartProducts;
  }

  /// Get products with good cart conversion
  List<Map<String, dynamic>> get productsWithGoodConversion {
    return highCartLowSaveProducts;
  }

  /// Clear all data
  void clearData() {
    savedProducts.clear();
    cartProducts.clear();
    productAnalytics.clear();
    vendorSummary.value = null;
    recentActivity.clear();
    topPerformingProducts.clear();
    highSaveLowCartProducts.clear();
    highCartLowSaveProducts.clear();
    trendingProducts.clear();
    competitorAnalysis.clear();
  }
}
