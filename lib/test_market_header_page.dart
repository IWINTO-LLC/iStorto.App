import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/view/widgets/market_header_organization.dart';

class TestMarketHeaderPage extends StatelessWidget {
  const TestMarketHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Market Header'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Test with edit mode = true, isVendor = true
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Edit Mode = true, isVendor = true',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  marketHeaderSection(
                    'test-vendor-id',
                    true, // editMode
                    true, // isVendor
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test with edit mode = false, isVendor = true
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Edit Mode = false, isVendor = true',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  marketHeaderSection(
                    'test-vendor-id',
                    false, // editMode
                    true, // isVendor
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test with edit mode = false, isVendor = false
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Edit Mode = false, isVendor = false',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  marketHeaderSection(
                    'test-vendor-id',
                    false, // editMode
                    false, // isVendor
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Test Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      // Initialize VendorController with test data
                      final vendorController = Get.find<VendorController>();
                      vendorController.profileData.value = VendorModel(
                        id: 'test-vendor-id',
                        organizationName: 'Test Organization',
                        organizationBio: 'This is a test organization bio',
                        organizationLogo: 'https://via.placeholder.com/150',
                        organizationCover:
                            'https://via.placeholder.com/400x200',
                        slugn: 'test-organization',
                        isVerified: true,
                        isSubscriber: true,
                        isRoyal: true,
                        inExclusive: true,
                      );
                    },
                    child: const Text('Load Test Data'),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      // Clear test data
                      final vendorController = Get.find<VendorController>();
                      vendorController.profileData.value = VendorModel.empty();
                    },
                    child: const Text('Clear Test Data'),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      // Toggle loading state
                      final vendorController = Get.find<VendorController>();
                      vendorController.isLoading.value =
                          !vendorController.isLoading.value;
                    },
                    child: const Text('Toggle Loading State'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
