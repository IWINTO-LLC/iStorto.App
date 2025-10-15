import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/views/widgets/product_widget_small.dart';
import 'package:istoreto/utils/constants/color.dart';

class ComprehensiveSearchPage extends StatefulWidget {
  const ComprehensiveSearchPage({super.key});

  @override
  State<ComprehensiveSearchPage> createState() =>
      _ComprehensiveSearchPageState();
}

class _ComprehensiveSearchPageState extends State<ComprehensiveSearchPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = Get.find<ProductController>();

  late TabController _tabController;

  // Search parameters
  String _searchQuery = '';
  String _selectedVendorId = '';
  String _selectedCategoryId = '';
  String _sortBy = 'newest';
  bool _showOnlyAvailable = false;
  bool _showOnlyFeatured = false;
  bool _showOnlyVerified = false;

  // Loading states
  final RxBool _isSearching = false.obs;
  final RxBool _isLoadingVendors = false.obs;
  final RxBool _isLoadingCategories = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    _isLoadingVendors.value = true;
    _isLoadingCategories.value = true;

    try {
      // TODO: Load vendors and categories when methods are available
      // await _vendorCategoriesController.loadAllVendors();
      // await _vendorCategoriesController.loadAllCategories();
    } finally {
      _isLoadingVendors.value = false;
      _isLoadingCategories.value = false;
    }
  }

  void _performSearch() {
    if (_searchQuery.trim().isEmpty) return;

    _isSearching.value = true;

    // TODO: Implement actual search logic
    Future.delayed(const Duration(seconds: 1), () {
      _isSearching.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    _searchQuery = value;
                    _performSearch();
                  },
                  onChanged: (value) => _searchQuery = value,
                  decoration: InputDecoration(
                    hintText: 'search_all_products'.tr,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      label: 'filter_by_vendor'.tr,
                      isSelected: _selectedVendorId.isNotEmpty,
                      onTap: _showVendorFilter,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      label: 'filter_by_category'.tr,
                      isSelected: _selectedCategoryId.isNotEmpty,
                      onTap: _showCategoryFilter,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'sort'.tr,
                    isSelected: _sortBy != 'newest',
                    onTap: _showSortOptions,
                    icon: Icons.sort,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick Filters
              Row(
                children: [
                  _buildQuickFilter(
                    label: 'available_only'.tr,
                    isSelected: _showOnlyAvailable,
                    onChanged:
                        (value) => setState(() => _showOnlyAvailable = value),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilter(
                    label: 'featured_only'.tr,
                    isSelected: _showOnlyFeatured,
                    onChanged:
                        (value) => setState(() => _showOnlyFeatured = value),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilter(
                    label: 'verified_only'.tr,
                    isSelected: _showOnlyVerified,
                    onChanged:
                        (value) => setState(() => _showOnlyVerified = value),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Results Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: TColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: TColors.primary,
            tabs: [Tab(text: 'products'.tr), Tab(text: 'vendors'.tr)],
          ),
        ),

        // Results Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildProductsTab(), _buildVendorsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilter({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? TColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? TColors.primary : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return Obx(() {
      if (_isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_searchQuery.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'start_searching'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'search_hint'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // TODO: Replace with actual search results
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductWidgetSmall(
              product:
                  _productController.products[index %
                      _productController.products.length],
              vendorId:
                  _productController
                      .products[index % _productController.products.length]
                      .vendorId ??
                  '',
            ),
          );
        },
      );
    });
  }

  Widget _buildVendorsTab() {
    return Obx(() {
      if (_isLoadingVendors.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_searchQuery.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'search_for_vendors'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'search_vendors_hint'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // TODO: Replace with actual vendors list when available
      return const Center(child: Text('No vendors available'));
    });
  }

  void _showVendorFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'filter_by_vendor'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // All vendors option
                ListTile(
                  title: Text('all_vendors'.tr),
                  leading: Radio<String>(
                    value: '',
                    groupValue: _selectedVendorId,
                    onChanged: (value) {
                      setState(() => _selectedVendorId = value!);
                      Navigator.pop(context);
                      _performSearch();
                    },
                  ),
                ),

                // Vendors list
                Expanded(
                  child: Obx(() {
                    if (_isLoadingVendors.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // TODO: Replace with actual vendors list when available
                    return const Center(child: Text('No vendors available'));
                  }),
                ),
              ],
            ),
          ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'filter_by_category'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // All categories option
                ListTile(
                  title: Text('all_categories'.tr),
                  leading: Radio<String>(
                    value: '',
                    groupValue: _selectedCategoryId,
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value!);
                      Navigator.pop(context);
                      _performSearch();
                    },
                  ),
                ),

                // Categories list
                Expanded(
                  child: Obx(() {
                    if (_isLoadingCategories.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // TODO: Replace with actual categories list when available
                    return const Center(child: Text('No categories available'));
                  }),
                ),
              ],
            ),
          ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sort_by'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildSortOption(
                  'newest',
                  'newest_first'.tr,
                  Icons.access_time,
                ),
                _buildSortOption(
                  'oldest',
                  'oldest_first'.tr,
                  Icons.access_time_filled,
                ),
                _buildSortOption(
                  'price_high',
                  'price_high_to_low'.tr,
                  Icons.keyboard_arrow_down,
                ),
                _buildSortOption(
                  'price_low',
                  'price_low_to_high'.tr,
                  Icons.keyboard_arrow_up,
                ),
                _buildSortOption('name', 'name_a_to_z'.tr, Icons.sort_by_alpha),
                _buildSortOption('rating', 'highest_rated'.tr, Icons.star),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    return ListTile(
      title: Text(label),
      leading: Icon(icon),
      trailing: Radio<String>(
        value: value,
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() => _sortBy = value!);
          Navigator.pop(context);
          _performSearch();
        },
      ),
    );
  }
}
