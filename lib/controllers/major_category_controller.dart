// lib/controllers/major_category_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/major_category_model.dart';
import '../data/repositories/major_category_repository.dart';

class MajorCategoryController extends GetxController {
  static MajorCategoryController get instance => Get.find();

  // Observable lists
  final RxList<MajorCategoryModel> _allCategories = <MajorCategoryModel>[].obs;
  final RxList<MajorCategoryModel> _hierarchicalCategories =
      <MajorCategoryModel>[].obs;
  final RxList<MajorCategoryModel> _rootCategories = <MajorCategoryModel>[].obs;
  final RxList<MajorCategoryModel> _featuredCategories =
      <MajorCategoryModel>[].obs;
  final RxList<MajorCategoryModel> _activeCategories =
      <MajorCategoryModel>[].obs;

  // Selected category
  final Rx<MajorCategoryModel?> _selectedCategory = Rx<MajorCategoryModel?>(
    null,
  );

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;

  // Search
  final RxString _searchQuery = ''.obs;
  final RxList<MajorCategoryModel> _searchResults = <MajorCategoryModel>[].obs;

  // Filters
  final RxInt _selectedStatus =
      0.obs; // 0: All, 1: Active, 2: Pending, 3: Inactive
  final RxBool _showFeaturedOnly = false.obs;

  // Getters
  List<MajorCategoryModel> get allCategories => _allCategories;
  List<MajorCategoryModel> get hierarchicalCategories =>
      _hierarchicalCategories;
  List<MajorCategoryModel> get rootCategories => _rootCategories;
  List<MajorCategoryModel> get featuredCategories => _featuredCategories;
  List<MajorCategoryModel> get activeCategories => _activeCategories;
  MajorCategoryModel? get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  List<MajorCategoryModel> get searchResults => _searchResults;
  int get selectedStatus => _selectedStatus.value;
  bool get showFeaturedOnly => _showFeaturedOnly.value;

  // Filtered categories based on current filters
  List<MajorCategoryModel> get filteredCategories {
    List<MajorCategoryModel> filtered = _allCategories;

    // Filter by status
    if (_selectedStatus.value > 0) {
      filtered =
          filtered.where((cat) => cat.status == _selectedStatus.value).toList();
    }

    // Filter by featured
    if (_showFeaturedOnly.value) {
      filtered = filtered.where((cat) => cat.isFeature).toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    print('🎯 [MajorCategoryController] Controller initialized');
    print('📊 [MajorCategoryController] Initial state:');
    print('   - All Categories: ${_allCategories.length}');
    print('   - Featured Categories: ${_featuredCategories.length}');
    print('   - Root Categories: ${_rootCategories.length}');
    print('   - Is Loading: ${_isLoading.value}');
    // Load all necessary data
    loadAllCategories();
    loadActiveCategories();
  }

  // Load all categories
  Future<void> loadAllCategories() async {
    try {
      print('🎯 [MajorCategoryController] Loading all categories...');
      _isLoading.value = true;
      final categories = await MajorCategoryRepository.getAllCategories();
      _allCategories.assignAll(categories);
      print(
        '✅ [MajorCategoryController] Loaded ${categories.length} categories into controller',
      );
      print('📋 [MajorCategoryController] Controller state:');
      print('   - All Categories: ${_allCategories.length}');
      print('   - Featured Categories: ${_featuredCategories.length}');
      print('   - Root Categories: ${_rootCategories.length}');
    } catch (e) {
      print('❌ [MajorCategoryController] Error loading categories: $e');
      Get.snackbar(
        'error'.tr,
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load hierarchical categories
  Future<void> loadHierarchicalCategories() async {
    try {
      _isLoading.value = true;
      final categories = await MajorCategoryRepository.getCategoriesHierarchy();
      _hierarchicalCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to load hierarchical categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load root categories
  Future<void> loadRootCategories() async {
    try {
      _isLoading.value = true;
      final categories = await MajorCategoryRepository.getRootCategories();
      _rootCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to load root categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load featured categories
  Future<void> loadFeaturedCategories() async {
    try {
      _isLoading.value = true;
      final categories = await MajorCategoryRepository.getFeaturedCategories();
      _featuredCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to load featured categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load active categories
  Future<void> loadActiveCategories() async {
    try {
      _isLoading.value = true;
      final categories = await MajorCategoryRepository.getActiveCategories();
      _activeCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to load active categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create new category
  Future<bool> createCategory(MajorCategoryModel category) async {
    try {
      _isCreating.value = true;
      final newCategory = await MajorCategoryRepository.createCategory(
        category.toJson(),
      );
      _allCategories.insert(0, newCategory);

      // Update other lists if needed
      if (newCategory.isRoot) {
        _rootCategories.insert(0, newCategory);
      }
      if (newCategory.isFeature) {
        _featuredCategories.insert(0, newCategory);
      }
      if (newCategory.isActive) {
        _activeCategories.insert(0, newCategory);
      }

      Get.snackbar(
        'success'.tr,
        'Category created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to create category: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Update category
  Future<bool> updateCategory(MajorCategoryModel category) async {
    try {
      _isUpdating.value = true;
      final updatedCategory = await MajorCategoryRepository.updateCategory(
        category.id!,
        category.toJson(),
      );

      // Update in all lists
      final index = _allCategories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _allCategories[index] = updatedCategory;
      }

      // Update other lists
      _updateCategoryInLists(updatedCategory);

      Get.snackbar(
        'success'.tr,
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to update category: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      _isDeleting.value = true;
      await MajorCategoryRepository.deleteCategory(id);

      // Remove from all lists
      _allCategories.removeWhere((cat) => cat.id == id);
      _rootCategories.removeWhere((cat) => cat.id == id);
      _featuredCategories.removeWhere((cat) => cat.id == id);
      _activeCategories.removeWhere((cat) => cat.id == id);
      _searchResults.removeWhere((cat) => cat.id == id);

      // Clear selection if deleted category was selected
      if (_selectedCategory.value?.id == id) {
        _selectedCategory.value = null;
      }

      Get.snackbar(
        'success'.tr,
        'Category deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to delete category: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Update category status
  Future<bool> updateCategoryStatus(String id, int status) async {
    try {
      _isUpdating.value = true;
      final updatedCategory =
          await MajorCategoryRepository.updateCategoryStatus(id, status);

      // Update in all lists
      final index = _allCategories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _allCategories[index] = updatedCategory;
      }

      _updateCategoryInLists(updatedCategory);

      Get.snackbar(
        'success'.tr,
        'Category status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to update category status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Toggle featured status
  Future<bool> toggleFeatured(String id, bool isFeatured) async {
    try {
      _isUpdating.value = true;
      final updatedCategory = await MajorCategoryRepository.toggleFeatured(
        id,
        isFeatured,
      );

      // Update in all lists
      final index = _allCategories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _allCategories[index] = updatedCategory;
      }

      _updateCategoryInLists(updatedCategory);

      Get.snackbar(
        'success'.tr,
        'Featured status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to update featured status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Search categories
  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _searchQuery.value = '';
      return;
    }

    try {
      _isLoading.value = true;
      _searchQuery.value = query;
      final results = await MajorCategoryRepository.searchCategories(query);
      _searchResults.assignAll(results);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to search categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
  }

  // Set selected category
  void selectCategory(MajorCategoryModel? category) {
    _selectedCategory.value = category;
  }

  // Set status filter
  void setStatusFilter(int status) {
    _selectedStatus.value = status;
  }

  // Toggle featured filter
  void toggleFeaturedFilter() {
    _showFeaturedOnly.value = !_showFeaturedOnly.value;
  }

  // Clear all filters
  void clearFilters() {
    _selectedStatus.value = 0;
    _showFeaturedOnly.value = false;
    clearSearch();
  }

  // Get category by ID
  MajorCategoryModel? getCategoryById(String id) {
    try {
      return _allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories by parent ID
  List<MajorCategoryModel> getCategoriesByParent(String parentId) {
    return _allCategories.where((cat) => cat.parentId == parentId).toList();
  }

  // Get category statistics
  Future<Map<String, int>> getCategoryStats() async {
    try {
      return await MajorCategoryRepository.getCategoryStats();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to load category statistics: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {};
    }
  }

  // Helper method to update category in all lists
  void _updateCategoryInLists(MajorCategoryModel updatedCategory) {
    // Update root categories
    final rootIndex = _rootCategories.indexWhere(
      (cat) => cat.id == updatedCategory.id,
    );
    if (rootIndex != -1) {
      if (updatedCategory.isRoot) {
        _rootCategories[rootIndex] = updatedCategory;
      } else {
        _rootCategories.removeAt(rootIndex);
      }
    } else if (updatedCategory.isRoot) {
      _rootCategories.insert(0, updatedCategory);
    }

    // Update featured categories
    final featuredIndex = _featuredCategories.indexWhere(
      (cat) => cat.id == updatedCategory.id,
    );
    if (featuredIndex != -1) {
      if (updatedCategory.isFeature) {
        _featuredCategories[featuredIndex] = updatedCategory;
      } else {
        _featuredCategories.removeAt(featuredIndex);
      }
    } else if (updatedCategory.isFeature) {
      _featuredCategories.insert(0, updatedCategory);
    }

    // Update active categories
    final activeIndex = _activeCategories.indexWhere(
      (cat) => cat.id == updatedCategory.id,
    );
    if (activeIndex != -1) {
      if (updatedCategory.isActive) {
        _activeCategories[activeIndex] = updatedCategory;
      } else {
        _activeCategories.removeAt(activeIndex);
      }
    } else if (updatedCategory.isActive) {
      _activeCategories.insert(0, updatedCategory);
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadAllCategories(),
      loadHierarchicalCategories(),
      loadRootCategories(),
      loadFeaturedCategories(),
      loadActiveCategories(),
    ]);
  }

  // Get category icon based on name
  IconData getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('fashion')) {
      return Icons.checkroom;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Icons.shopping_bag;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Icons.shopping_basket;
    } else if (name.contains('accessories') || name.contains('watch')) {
      return Icons.watch;
    } else if (name.contains('electronics') || name.contains('phone')) {
      return Icons.phone_android;
    } else if (name.contains('home') || name.contains('furniture')) {
      return Icons.home;
    } else if (name.contains('beauty') || name.contains('cosmetics')) {
      return Icons.face;
    } else if (name.contains('sports') || name.contains('fitness')) {
      return Icons.sports;
    } else if (name.contains('books') || name.contains('education')) {
      return Icons.book; //Office
    } else if (name.contains('toys') || name.contains('games')) {
      return Icons.toys;
    } else if (name.contains('food') || name.contains('restaurant')) {
      return Icons.restaurant;
    } else if (name.contains('office') || name.contains('library')) {
      return Icons.engineering;
    } else if (name.contains('health') || name.contains('medical')) {
      return Icons.medical_services;
    } else if (name.contains('automotive') || name.contains('car')) {
      return Icons.directions_car;
    } else if (name.contains('garden') || name.contains('outdoor')) {
      return Icons.local_florist;
    } else if (name.contains('jewelry') || name.contains('diamond')) {
      return Icons.diamond;
    } else {
      return Icons.category;
    }
  }

  // Get category color based on name
  Color getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Colors.pink;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Colors.brown;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Colors.purple;
    } else if (name.contains('accessories') || name.contains('watch')) {
      return Colors.blue;
    } else if (name.contains('electronics') || name.contains('phone')) {
      return Colors.blueGrey;
    } else if (name.contains('home') || name.contains('furniture')) {
      return Colors.green;
    } else if (name.contains('beauty') || name.contains('cosmetics')) {
      return Colors.pinkAccent;
    } else if (name.contains('sports') || name.contains('fitness')) {
      return Colors.orange;
    } else if (name.contains('books') || name.contains('education')) {
      return Colors.indigo;
    } else if (name.contains('toys') || name.contains('games')) {
      return Colors.red;
    } else if (name.contains('food') || name.contains('restaurant')) {
      return Colors.amber;
    } else if (name.contains('health') || name.contains('medical')) {
      return Colors.teal;
    } else if (name.contains('automotive') || name.contains('car')) {
      return Colors.deepOrange;
    } else if (name.contains('garden') || name.contains('outdoor')) {
      return Colors.lightGreen;
    } else if (name.contains('jewelry') || name.contains('diamond')) {
      return Colors.cyan;
    } else {
      return Colors.grey;
    }
  }
}
