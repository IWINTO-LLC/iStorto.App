// lib/examples/test_categories_widget_v2.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/major_category_controller.dart';
import '../data/models/major_category_model.dart';

class TestCategoriesWidgetV2 extends StatefulWidget {
  const TestCategoriesWidgetV2({super.key});

  @override
  State<TestCategoriesWidgetV2> createState() => _TestCategoriesWidgetV2State();
}

class _TestCategoriesWidgetV2State extends State<TestCategoriesWidgetV2> {
  late MajorCategoryController controller;
  List<MajorCategoryModel> testCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeTestData();
  }

  void _initializeTestData() {
    // Create test categories
    testCategories = [
      MajorCategoryModel(
        id: '1',
        name: 'Clothing',
        arabicName: 'الملابس',
        image: null,
        isFeature: true,
        status: 1, // Active
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MajorCategoryModel(
        id: '2',
        name: 'Shoes',
        arabicName: 'الأحذية',
        image: null,
        isFeature: true,
        status: 1, // Active
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MajorCategoryModel(
        id: '3',
        name: 'Bags',
        arabicName: 'الحقائب',
        image: null,
        isFeature: false,
        status: 1, // Active
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MajorCategoryModel(
        id: '4',
        name: 'Accessories',
        arabicName: 'الإكسسوارات',
        image: null,
        isFeature: true,
        status: 1, // Active
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MajorCategoryModel(
        id: '5',
        name: 'Electronics',
        arabicName: 'الإلكترونيات',
        image: null,
        isFeature: false,
        status: 2, // Pending
        parentId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Initialize controller
    controller = Get.put(MajorCategoryController());

    // Simulate loading data
    _simulateDataLoading();
  }

  void _simulateDataLoading() {
    // Simulate loading data into controller
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          // This simulates the controller having data
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Categories Widget V2'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTestDataDialog(),
            tooltip: 'Add Test Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _simulateDataLoading();
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Add Test Data Button
            _buildAddTestDataButton(),

            const SizedBox(height: 20),

            // Test Categories Display
            _buildTestCategoriesDisplay(),

            const SizedBox(height: 40),

            // Test info
            _buildTestInfo(),

            const SizedBox(height: 20),

            // Controller Status
            _buildControllerStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCategoriesDisplay() {
    return Column(
      children: [
        const Text(
          'Test Categories Display',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Categories Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: testCategories.length,
          itemBuilder: (context, index) {
            final category = testCategories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(MajorCategoryModel category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCategoryDetails(category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: _getCategoryColor(category.name),
                  size: 30,
                ),
              ),

              const SizedBox(height: 8),

              // Category Name
              Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(category.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(category.status).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(category.status),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(category.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (category.isFeature) ...[
                const SizedBox(height: 4),
                const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Test Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('This widget displays test categories locally.'),
              const SizedBox(height: 4),
              const Text('• Tap on categories to see details'),
              const SizedBox(height: 4),
              const Text('• Categories show with automatic icons and colors'),
              const SizedBox(height: 4),
              const Text('• Status indicators show category state'),
              const SizedBox(height: 4),
              const Text('• Featured categories show star icon'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControllerStatus() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Controller Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Test Categories: ${testCategories.length}'),
              Text(
                'Featured: ${testCategories.where((cat) => cat.isFeature).length}',
              ),
              Text(
                'Active: ${testCategories.where((cat) => cat.status == 1).length}',
              ),
              Text(
                'Pending: ${testCategories.where((cat) => cat.status == 2).length}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(MajorCategoryModel category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(category.displayName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${category.id}'),
                Text('Name: ${category.name}'),
                if (category.arabicName != null)
                  Text('Arabic Name: ${category.arabicName}'),
                Text('Status: ${_getStatusText(category.status)}'),
                Text('Featured: ${category.isFeature ? 'Yes' : 'No'}'),
                Text('Parent ID: ${category.parentId ?? 'None'}'),
                Text(
                  'Created: ${category.createdAt?.toString().split('.')[0] ?? 'Unknown'}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Colors.pink;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Colors.brown;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Colors.purple;
    } else if (name.contains('accessories')) {
      return Colors.blue;
    } else if (name.contains('electronics')) {
      return Colors.blueGrey;
    } else {
      return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Icons.checkroom;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Icons.shopping_bag;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Icons.shopping_basket;
    } else if (name.contains('accessories')) {
      return Icons.watch;
    } else if (name.contains('electronics')) {
      return Icons.phone_android;
    } else {
      return Icons.category;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Active';
      case 2:
        return 'Pending';
      case 3:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  Widget _buildAddTestDataButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Test Data Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _addMoreTestCategories(),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Add More'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _clearAllTestData(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _resetToDefault(),
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTestDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Test Data'),
            content: const Text('Choose how you want to add test data:'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addMoreTestCategories();
                },
                child: const Text('Add More Categories'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addRandomTestData();
                },
                child: const Text('Add Random Data'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetToDefault();
                },
                child: const Text('Reset to Default'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _addMoreTestCategories() {
    setState(() {
      final newCategories = [
        MajorCategoryModel(
          id: '${testCategories.length + 1}',
          name: 'Books',
          arabicName: 'الكتب',
          image: null,
          isFeature: false,
          status: 1,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MajorCategoryModel(
          id: '${testCategories.length + 2}',
          name: 'Sports',
          arabicName: 'الرياضة',
          image: null,
          isFeature: true,
          status: 1,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MajorCategoryModel(
          id: '${testCategories.length + 3}',
          name: 'Beauty',
          arabicName: 'الجمال',
          image: null,
          isFeature: false,
          status: 2,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MajorCategoryModel(
          id: '${testCategories.length + 4}',
          name: 'Home & Garden',
          arabicName: 'المنزل والحديقة',
          image: null,
          isFeature: true,
          status: 1,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      testCategories.addAll(newCategories);
    });

    Get.snackbar(
      'Success',
      'Added ${4} new test categories',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _addRandomTestData() {
    setState(() {
      final randomCategories = [
        MajorCategoryModel(
          id: 'random_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Gaming',
          arabicName: 'الألعاب',
          image: null,
          isFeature: true,
          status: 1,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MajorCategoryModel(
          id: 'random_${DateTime.now().millisecondsSinceEpoch + 1}',
          name: 'Fitness',
          arabicName: 'اللياقة البدنية',
          image: null,
          isFeature: false,
          status: 2,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MajorCategoryModel(
          id: 'random_${DateTime.now().millisecondsSinceEpoch + 2}',
          name: 'Toys',
          arabicName: 'الألعاب',
          image: null,
          isFeature: true,
          status: 1,
          parentId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      testCategories.addAll(randomCategories);
    });

    Get.snackbar(
      'Success',
      'Added ${3} random test categories',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _clearAllTestData() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'Are you sure you want to clear all test categories? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    testCategories.clear();
                  });
                  Get.snackbar(
                    'Cleared',
                    'All test data has been cleared',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _initializeTestData();
    });

    Get.snackbar(
      'Reset',
      'Test data has been reset to default',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
