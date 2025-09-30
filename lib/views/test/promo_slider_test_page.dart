import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/banner/data/banner_model.dart';
import 'package:istoreto/featured/banner/view/front/promo_slider.dart';
import 'package:istoreto/utils/constants/color.dart';

class PromoSliderTestPage extends StatefulWidget {
  const PromoSliderTestPage({super.key});

  @override
  State<PromoSliderTestPage> createState() => _PromoSliderTestPageState();
}

class _PromoSliderTestPageState extends State<PromoSliderTestPage> {
  final BannerController bannerController = Get.find<BannerController>();

  String testVendorId = 'test-vendor-promo-123';
  bool editMode = false;
  bool autoPlay = true;
  String testResults = '';

  @override
  void initState() {
    super.initState();
    _setupTestBanners();
  }

  void _setupTestBanners() {
    // Clear existing banners
    bannerController.banners.clear();
    bannerController.activeBanners.clear();

    // Create test banners for the vendor
    final testBanners = [
      BannerModel(
        id: 'promo-banner-1',
        image: 'https://picsum.photos/364/214?random=1',
        targetScreen: 'home',
        active: true,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'Promo Banner 1',
        description: 'First promotional banner',
        priority: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BannerModel(
        id: 'promo-banner-2',
        image: 'https://picsum.photos/364/214?random=2',
        targetScreen: 'home',
        active: true,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'Promo Banner 2',
        description: 'Second promotional banner',
        priority: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BannerModel(
        id: 'promo-banner-3',
        image: 'https://picsum.photos/364/214?random=3',
        targetScreen: 'home',
        active: true,
        vendorId: testVendorId,
        scope: BannerScope.vendor,
        title: 'Promo Banner 3',
        description: 'Third promotional banner',
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    // Add banners to controller
    bannerController.banners.assignAll(testBanners);
    bannerController.activeBanners.assignAll(
      testBanners.where((banner) => banner.active).toList(),
    );
  }

  void _testPromoSlider() {
    setState(() {
      testResults = 'Testing Promo Slider:\n\n';
    });

    try {
      // Test 1: Check banner controller state
      testResults += '1. Banner Controller State:\n';
      testResults += '   Total banners: ${bannerController.banners.length}\n';
      testResults +=
          '   Active banners: ${bannerController.activeBanners.length}\n';
      testResults +=
          '   Current page index: ${bannerController.carousalCurrentIndex.value}\n';
      testResults +=
          '   Loading state: ${bannerController.isLoading.value}\n\n';

      // Test 2: Check vendor-specific banners
      testResults += '2. Vendor-Specific Banners:\n';
      final vendorBanners =
          bannerController.banners
              .where((banner) => banner.vendorId == testVendorId)
              .toList();
      testResults +=
          '   Found ${vendorBanners.length} banners for vendor $testVendorId\n';

      for (final banner in vendorBanners) {
        testResults +=
            '   - ${banner.title} (Active: ${banner.active}, Priority: ${banner.priority})\n';
      }
      testResults += '\n';

      // Test 3: Test slider configuration
      testResults += '3. Slider Configuration:\n';
      testResults += '   Edit Mode: $editMode\n';
      testResults += '   Auto Play: $autoPlay\n';
      testResults += '   Vendor ID: $testVendorId\n\n';

      // Test 4: Test page indicator updates
      testResults += '4. Testing Page Indicator:\n';
      for (int i = 0; i < bannerController.activeBanners.length; i++) {
        bannerController.updatePageIndicator(i);
        testResults +=
            '   Updated to page $i: ${bannerController.carousalCurrentIndex.value}\n';
      }
      testResults += '\n';

      testResults += '✅ Promo slider tests completed successfully!\n';
    } catch (e) {
      testResults += '❌ Error during testing: $e\n';
    }
  }

  void _addTestBanner() {
    final newBanner = BannerModel(
      id: 'promo-banner-${DateTime.now().millisecondsSinceEpoch}',
      image:
          'https://picsum.photos/364/214?random=${bannerController.banners.length + 10}',
      targetScreen: 'home',
      active: true,
      vendorId: testVendorId,
      scope: BannerScope.vendor,
      title: 'Dynamic Banner ${bannerController.banners.length + 1}',
      description: 'Banner added via test',
      priority: bannerController.banners.length + 1,
      createdAt: DateTime.now(),
    );

    bannerController.banners.add(newBanner);
    bannerController.activeBanners.add(newBanner);

    setState(() {});
  }

  void _removeLastBanner() {
    if (bannerController.banners.isNotEmpty) {
      final lastBanner = bannerController.banners.last;
      bannerController.banners.remove(lastBanner);
      bannerController.activeBanners.remove(lastBanner);
      setState(() {});
    }
  }

  void _toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      autoPlay = !autoPlay;
    });
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
        title: const Text('Promo Slider Test'),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Slider Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit Mode Toggle
                    Row(
                      children: [
                        const Text('Edit Mode:'),
                        const SizedBox(width: 8),
                        Switch(
                          value: editMode,
                          onChanged: (value) => _toggleEditMode(),
                          activeColor: TColors.primary,
                        ),
                      ],
                    ),

                    // Auto Play Toggle
                    Row(
                      children: [
                        const Text('Auto Play:'),
                        const SizedBox(width: 8),
                        Switch(
                          value: autoPlay,
                          onChanged: (value) => _toggleAutoPlay(),
                          activeColor: TColors.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Vendor ID Display
                    Text(
                      'Vendor ID: $testVendorId',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Banner Management Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Banner Management',
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
                            onPressed: _addTestBanner,
                            child: const Text('Add Test Banner'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _removeLastBanner,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Remove Last'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _setupTestBanners,
                      child: const Text('Reset Test Banners'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Promo Slider Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Promo Slider Display',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current banner count
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Active Banners: ${bannerController.activeBanners.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Promo Slider Widget
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: TPromoSlider(
                          editMode: editMode,
                          autoPlay: autoPlay,
                          vendorId: testVendorId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Controls',
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
                            onPressed: _testPromoSlider,
                            child: const Text('Run Tests'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearResults,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Clear Results'),
                          ),
                        ),
                      ],
                    ),
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

            const SizedBox(height: 16),

            // Banner List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Banners',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (bannerController.activeBanners.isEmpty) {
                        return const Center(
                          child: Text(
                            'No banners available',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return Column(
                        children:
                            bannerController.activeBanners.map((banner) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        banner.image,
                                        width: 60,
                                        height: 35,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: 60,
                                            height: 35,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            banner.title ?? 'Untitled',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Priority: ${banner.priority ?? 0}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
