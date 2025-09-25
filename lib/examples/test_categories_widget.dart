// lib/examples/test_categories_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../featured/home-page/views/widgets/major_category_section.dart';
import '../controllers/major_category_controller.dart';
import '../data/models/major_category_model.dart';

class TestCategoriesWidget extends StatefulWidget {
  const TestCategoriesWidget({super.key});

  @override
  State<TestCategoriesWidget> createState() => _TestCategoriesWidgetState();
}

class _TestCategoriesWidgetState extends State<TestCategoriesWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize controller with test data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTestData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(MajorCategoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Categories Widget'),
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
            onPressed: () => _refreshData(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // Test MajorCategorySection
            MajorCategorySection(),

            SizedBox(height: 40),

            // Test info
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('This page tests the MajorCategorySection widget.'),
                      SizedBox(height: 4),
                      Text('• Tap on categories to see details'),
                      SizedBox(height: 4),
                      Text('• Tap "See All" to go to full categories page'),
                      SizedBox(height: 4),
                      Text('• Categories show with automatic icons and colors'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeTestData() {
    // Just load data from repository - no need to add test data
    // The controller will handle loading from the actual data source
    print('🧪 [TestCategoriesWidget] Initializing test data...');
  }

  void _showAddTestDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Test Data'),
            content: const Text(
              'This will add test categories to the database. Choose an option:',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addTestCategoriesToDatabase();
                },
                child: const Text('Add to Database'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadTestData();
                },
                child: const Text('Load Test Data'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _addTestCategoriesToDatabase() async {
    try {
      final controller = Get.find<MajorCategoryController>();

      // Create test categories
      final testCategories = [
        MajorCategoryModel(
          name: 'Test Clothing',
          arabicName: 'ملابس تجريبية',
          isFeature: true,
          status: 1,
        ),
        MajorCategoryModel(
          name: 'Test Electronics',
          arabicName: 'إلكترونيات تجريبية',
          isFeature: false,
          status: 1,
        ),
        MajorCategoryModel(
          name: 'Test Books',
          arabicName: 'كتب تجريبية',
          isFeature: true,
          status: 2,
        ),
      ];

      // Add each category to database
      for (final category in testCategories) {
        await controller.createCategory(category);
      }

      Get.snackbar(
        'Success',
        'Added ${testCategories.length} test categories to database',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add test data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _loadTestData() {
    final controller = Get.find<MajorCategoryController>();
    controller.loadAllCategories();

    Get.snackbar(
      'Loading',
      'Loading categories from database...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _refreshData() {
    final controller = Get.find<MajorCategoryController>();
    controller.refreshAll();

    Get.snackbar(
      'Refreshed',
      'Data has been refreshed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
