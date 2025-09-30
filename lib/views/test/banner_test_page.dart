import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/banner/data/banner_repository.dart';
import 'package:istoreto/utils/constants/color.dart';

class BannerTestPage extends StatefulWidget {
  const BannerTestPage({super.key});

  @override
  State<BannerTestPage> createState() => _BannerTestPageState();
}

class _BannerTestPageState extends State<BannerTestPage> {
  final BannerController bannerController = Get.find<BannerController>();
  final BannerRepository bannerRepository = Get.find<BannerRepository>();

  String testVendorId = 'test-vendor-123';
  List<BannerModel> testBanners = [];
  String testResults = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTestBanners();
  }

  void _loadTestBanners() {
    // Create test banners with different vendors
    testBanners = [
      BannerModel(
        id: 'banner-1',
        image: 'https://example.com/banner1.jpg',
        targetScreen: 'home',
        active: true,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'Test Banner 1',
        description: 'First test banner for vendor',
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BannerModel(
        id: 'banner-2',
        image: 'https://example.com/banner2.jpg',
        targetScreen: 'home',
        active: true,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'Test Banner 2',
        description: 'Second test banner for vendor',
        priority: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BannerModel(
        id: 'banner-3',
        image: 'https://example.com/banner3.jpg',
        targetScreen: 'home',
        active: false,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'Test Banner 3 (Inactive)',
        description: 'Inactive test banner',
        priority: 0,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      BannerModel(
        id: 'banner-4',
        image: 'https://example.com/company-banner.jpg',
        targetScreen: 'home',
        active: true,
        vendorId: null, // Company banner
        scope: BannerScope.company,
        title: 'Company Banner',
        description: 'Global company banner',
        priority: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  void _testBannerOperations() async {
    setState(() {
      isLoading = true;
      testResults = 'Testing Banner Operations:\n\n';
    });

    try {
      // Test 1: Create banner with vendorId
      testResults += '1. Testing Banner Creation with VendorId:\n';
      final newBanner = BannerModel(
        image: 'https://example.com/new-banner.jpg',
        targetScreen: 'products',
        active: true,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'New Test Banner',
        description: 'Created via test',
        priority: 3,
      );

      testResults += '   Created banner: ${newBanner.title}\n';
      testResults += '   VendorId: ${newBanner.vendorId}\n';
      testResults += '   Scope: ${newBanner.scope.name}\n';
      testResults += '   Valid: ${newBanner.isValid}\n';
      testResults += '   Is Vendor Banner: ${newBanner.isVendorBanner}\n';
      testResults +=
          '   Belongs to vendor: ${newBanner.belongsToVendor(testVendorId)}\n\n';

      // Test 2: Test banner filtering by vendor
      testResults += '2. Testing Banner Filtering by Vendor:\n';
      final vendorBanners =
          testBanners
              .where((banner) => banner.vendorId == testVendorId)
              .toList();
      testResults +=
          '   Found ${vendorBanners.length} banners for vendor $testVendorId\n';

      for (final banner in vendorBanners) {
        testResults += '   - ${banner.title} (Active: ${banner.active})\n';
      }
      testResults += '\n';

      // Test 3: Test active banners
      testResults += '3. Testing Active Banners:\n';
      final activeBanners =
          testBanners
              .where(
                (banner) => banner.active && banner.vendorId == testVendorId,
              )
              .toList();
      testResults +=
          '   Found ${activeBanners.length} active banners for vendor\n';

      for (final banner in activeBanners) {
        testResults += '   - ${banner.title} (Priority: ${banner.priority})\n';
      }
      testResults += '\n';

      // Test 4: Test banner sorting by priority
      testResults += '4. Testing Banner Sorting by Priority:\n';
      final sortedBanners = List<BannerModel>.from(testBanners);
      sortedBanners.sort((a, b) => b.sortPriority.compareTo(a.sortPriority));

      for (final banner in sortedBanners.take(3)) {
        testResults +=
            '   - ${banner.title} (Priority: ${banner.sortPriority})\n';
      }
      testResults += '\n';

      // Test 5: Test mixed banners (company + vendor)
      testResults += '5. Testing Mixed Banners:\n';
      final mixedBanners =
          testBanners
              .where(
                (banner) =>
                    banner.active &&
                    (banner.scope == BannerScope.company ||
                        (banner.scope == BannerScope.vendor &&
                            banner.vendorId == testVendorId)),
              )
              .toList();
      testResults += '   Found ${mixedBanners.length} mixed banners\n';

      for (final banner in mixedBanners) {
        testResults += '   - ${banner.title} (${banner.scope.name})\n';
      }
      testResults += '\n';

      // Test 6: Test banner validation
      testResults += '6. Testing Banner Validation:\n';
      final validBanners = testBanners.where((banner) => banner.isValid).length;
      testResults += '   Valid banners: $validBanners/${testBanners.length}\n';

      final invalidBanner = BannerModel(
        image: '',
        targetScreen: '',
        active: true,
        vendorId: testVendorId,
      );
      testResults += '   Invalid banner test: ${invalidBanner.isValid}\n\n';

      // Test 7: Test banner copyWith functionality
      testResults += '7. Testing Banner CopyWith:\n';
      final originalBanner = testBanners.first;
      final updatedBanner = originalBanner.copyWith(
        title: 'Updated ${originalBanner.title}',
        active: !originalBanner.active,
        priority: (originalBanner.priority ?? 0) + 10,
      );

      testResults += '   Original: ${originalBanner.title}\n';
      testResults += '   Updated: ${updatedBanner.title}\n';
      testResults +=
          '   Active changed: ${originalBanner.active} -> ${updatedBanner.active}\n';
      testResults +=
          '   Priority changed: ${originalBanner.priority} -> ${updatedBanner.priority}\n\n';

      testResults += '✅ All banner tests completed successfully!\n';
    } catch (e) {
      testResults += '❌ Error during testing: $e\n';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _testBannerController() async {
    setState(() {
      isLoading = true;
      testResults = 'Testing Banner Controller:\n\n';
    });

    try {
      // Test controller initialization
      testResults += '1. Testing Controller Initialization:\n';
      testResults +=
          '   Controller instance: ${bannerController.runtimeType}\n';
      testResults +=
          '   Current page index: ${bannerController.carousalCurrentIndex.value}\n';
      testResults +=
          '   Loading state: ${bannerController.isLoading.value}\n\n';

      // Test banner fetching
      testResults += '2. Testing Banner Fetching:\n';
      testResults += '   Fetching banners for vendor: $testVendorId\n';

      // Simulate fetching (without actual database call)
      bannerController.banners.value = testBanners;
      bannerController.activeBanners.assignAll(
        testBanners.where((banner) => banner.active).toList(),
      );

      testResults += '   Total banners: ${bannerController.banners.length}\n';
      testResults +=
          '   Active banners: ${bannerController.activeBanners.length}\n\n';

      // Test page indicator update
      testResults += '3. Testing Page Indicator:\n';
      bannerController.updatePageIndicator(1);
      testResults +=
          '   Updated page index to: ${bannerController.carousalCurrentIndex.value}\n\n';

      testResults += '✅ Banner controller tests completed successfully!\n';
    } catch (e) {
      testResults += '❌ Error during controller testing: $e\n';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearResults() {
    setState(() {
      testResults = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Test Page'),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Vendor ID Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Vendor ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Vendor ID',
                        border: OutlineInputBorder(),
                        hintText: 'Enter vendor ID for testing',
                      ),
                      onChanged: (value) {
                        setState(() {
                          testVendorId =
                              value.isEmpty ? 'test-vendor-123' : value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Vendor ID: $testVendorId',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Operations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _testBannerOperations,
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Test Banner Operations'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _testBannerController,
                            child: const Text('Test Controller'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _clearResults,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Clear Results'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Banners Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Banners',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...testBanners.map((banner) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              banner.active
                                  ? Colors.green[50]
                                  : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                banner.active
                                    ? Colors.green[200]!
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    banner.title ?? 'Untitled Banner',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        banner.active
                                            ? Colors.green
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    banner.active ? 'Active' : 'Inactive',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner.description ?? 'No description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoChip('Scope', banner.scope.name),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  'Vendor',
                                  banner.vendorId ?? 'Company',
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  'Priority',
                                  banner.priority?.toString() ?? '0',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Results
            if (testResults.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          testResults,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.blue[800],
        ),
      ),
    );
  }
}
