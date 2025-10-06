import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/search/data/search_model.dart';
import 'package:istoreto/featured/search/data/search_repository.dart';

/// متحكم البحث الشامل
class SearchController extends GetxController {
  static SearchController get instance => Get.find();
  final SearchRepository _searchRepository = SearchRepository();

  // متغيرات الحالة
  final RxList<SearchResultModel> _searchResults = <SearchResultModel>[].obs;
  final RxList<String> _searchSuggestions = <String>[].obs;
  final RxList<String> _searchHistory = <String>[].obs;
  final Rx<SearchFilters> _currentFilters = SearchFilters().obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSearching = false.obs;
  final RxString _currentQuery = ''.obs;
  final RxInt _currentPage = 0.obs;
  final RxBool _hasMoreResults = true.obs;
  final RxMap<String, int> _searchStats = <String, int>{}.obs;

  // Getters
  List<SearchResultModel> get searchResults => _searchResults;
  List<String> get searchSuggestions => _searchSuggestions;
  List<String> get searchHistory => _searchHistory;
  SearchFilters get currentFilters => _currentFilters.value;
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  String get currentQuery => _currentQuery.value;
  int get currentPage => _currentPage.value;
  bool get hasMoreResults => _hasMoreResults.value;
  Map<String, int> get searchStats => _searchStats;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
  }

  /// تنفيذ البحث الشامل
  Future<void> performSearch({
    required String query,
    SearchFilters? filters,
    bool clearPrevious = true,
  }) async {
    if (query.trim().isEmpty) return;

    try {
      _isSearching.value = true;
      _currentQuery.value = query;

      if (clearPrevious) {
        _searchResults.clear();
        _currentPage.value = 0;
        _hasMoreResults.value = true;
      }

      // تطبيق الفلاتر
      final searchFilters = filters ?? _currentFilters.value;

      // تنفيذ البحث المتقدم (يشمل العنوان، الوصف، اسم المتجر، والفئة)
      final results = await _searchRepository.advancedSearch(
        query: query,
        filters: searchFilters,
        limit: 20,
        offset: _currentPage.value * 20,
      );

      if (clearPrevious) {
        _searchResults.value = results;
      } else {
        _searchResults.addAll(results);
      }

      // تحديث حالة النتائج
      _hasMoreResults.value = results.length == 20;
      _currentPage.value++;

      // حفظ في تاريخ البحث
      _addToSearchHistory(query);

      // الحصول على إحصائيات البحث
      await _getSearchStats(query);
    } catch (e) {
      Get.snackbar(
        'خطأ في البحث',
        'حدث خطأ أثناء البحث: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  /// البحث السريع
  Future<void> quickSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      _isLoading.value = true;
      _currentQuery.value = query;

      final results = await _searchRepository.quickSearch(query: query);

      _searchResults.value = results;

      // الحصول على اقتراحات
      await _getSearchSuggestions(query);
    } catch (e) {
      Get.snackbar(
        'خطأ في البحث السريع',
        'حدث خطأ أثناء البحث: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// تحميل المزيد من النتائج
  Future<void> loadMoreResults() async {
    if (!_hasMoreResults.value || _isSearching.value) return;

    try {
      _isSearching.value = true;

      final results = await _searchRepository.searchComprehensive(
        query: _currentQuery.value,
        filters: _currentFilters.value,
        limit: 20,
        offset: _currentPage.value * 20,
      );

      _searchResults.addAll(results);
      _hasMoreResults.value = results.length == 20;
      _currentPage.value++;
    } catch (e) {
      Get.snackbar(
        'خطأ في تحميل المزيد',
        'حدث خطأ أثناء تحميل المزيد من النتائج: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  /// تطبيق فلاتر البحث
  Future<void> applyFilters(SearchFilters filters) async {
    _currentFilters.value = filters;

    // تنفيذ البحث مع الفلاتر حتى بدون كلمة بحث
    await performSearch(
      query: _currentQuery.value.isEmpty ? '' : _currentQuery.value,
      filters: filters,
      clearPrevious: true,
    );
  }

  /// إعادة تعيين الفلاتر
  Future<void> resetFilters() async {
    _currentFilters.value = SearchFilters();

    if (_currentQuery.value.isNotEmpty) {
      await performSearch(query: _currentQuery.value, clearPrevious: true);
    }
  }

  /// الحصول على اقتراحات البحث
  Future<void> _getSearchSuggestions(String query) async {
    try {
      final suggestions = await _searchRepository.getSearchSuggestions(
        query: query,
        limit: 10,
      );

      _searchSuggestions.value = suggestions;
    } catch (e) {
      // تجاهل الأخطاء في الاقتراحات
      debugPrint('خطأ في الحصول على اقتراحات البحث: $e');
    }
  }

  /// الحصول على إحصائيات البحث
  Future<void> _getSearchStats(String query) async {
    try {
      final stats = await _searchRepository.getSearchStats(query: query);
      _searchStats.value = stats;
    } catch (e) {
      // تجاهل الأخطاء في الإحصائيات
      debugPrint('خطأ في الحصول على إحصائيات البحث: $e');
    }
  }

  /// إضافة إلى تاريخ البحث
  void _addToSearchHistory(String query) {
    // إزالة إذا كان موجود مسبقاً
    _searchHistory.remove(query);
    // إضافة في البداية
    _searchHistory.insert(0, query);
    // الاحتفاظ بـ 10 عناصر فقط
    if (_searchHistory.length > 10) {
      _searchHistory.removeRange(10, _searchHistory.length);
    }
    _saveSearchHistory();
  }

  /// تحميل تاريخ البحث
  void _loadSearchHistory() {
    // يمكن تحميل من SharedPreferences أو قاعدة البيانات
    // مؤقتاً سنستخدم قائمة فارغة
    _searchHistory.value = [];
  }

  /// حفظ تاريخ البحث
  void _saveSearchHistory() {
    // يمكن حفظ في SharedPreferences أو قاعدة البيانات
    // مؤقتاً لن نفعل شيئاً
  }

  /// مسح تاريخ البحث
  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
  }

  /// مسح النتائج
  void clearResults() {
    _searchResults.clear();
    _currentQuery.value = '';
    _currentPage.value = 0;
    _hasMoreResults.value = true;
    _searchStats.clear();
  }

  /// البحث في المنتجات فقط
  Future<void> searchProducts(String query) async {
    try {
      _isSearching.value = true;
      _currentQuery.value = query;

      final results = await _searchRepository.searchProducts(
        query: query,
        filters: _currentFilters.value,
      );

      _searchResults.value = results;
    } catch (e) {
      Get.snackbar(
        'خطأ في البحث عن المنتجات',
        'حدث خطأ أثناء البحث: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  /// البحث في التجار فقط
  Future<void> searchVendors(String query) async {
    try {
      _isSearching.value = true;
      _currentQuery.value = query;

      final results = await _searchRepository.searchVendors(
        query: query,
        filters: _currentFilters.value,
      );

      _searchResults.value = results;
    } catch (e) {
      Get.snackbar(
        'خطأ في البحث عن التجار',
        'حدث خطأ أثناء البحث: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  /// البحث في الفئات فقط
  Future<void> searchCategories(String query) async {
    try {
      _isSearching.value = true;
      _currentQuery.value = query;

      final results = await _searchRepository.searchCategories(
        query: query,
        filters: _currentFilters.value,
      );

      _searchResults.value = results;
    } catch (e) {
      Get.snackbar(
        'خطأ في البحث عن الفئات',
        'حدث خطأ أثناء البحث: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  /// التنقل إلى تفاصيل العنصر
  void navigateToDetails(SearchResultModel item) {
    switch (item.type) {
      case 'منتج':
        // التنقل إلى صفحة المنتج
        Get.snackbar(
          'تنقل',
          'سيتم التنقل إلى صفحة المنتج: ${item.title}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'تاجر':
        // التنقل إلى صفحة التاجر
        Get.snackbar(
          'تنقل',
          'سيتم التنقل إلى صفحة التاجر: ${item.title}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'فئة':
        // التنقل إلى صفحة الفئة
        Get.snackbar(
          'تنقل',
          'سيتم التنقل إلى صفحة الفئة: ${item.title}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      default:
        Get.snackbar(
          'تنبيه',
          'نوع العنصر غير معروف: ${item.type}',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}
