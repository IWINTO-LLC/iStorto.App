import 'package:flutter/material.dart';
import 'package:istoreto/featured/banner/view/front/promo_slider.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorBannerExample extends StatefulWidget {
  final String vendorId;
  final bool isVendorOwner;

  const VendorBannerExample({
    super.key,
    required this.vendorId,
    this.isVendorOwner = false,
  });

  @override
  State<VendorBannerExample> createState() => _VendorBannerExampleState();
}

class _VendorBannerExampleState extends State<VendorBannerExample> {
  bool editMode = false;
  bool autoPlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Banner Example'),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Edit mode toggle (only for vendor owners)
          if (widget.isVendorOwner)
            IconButton(
              icon: Icon(editMode ? Icons.edit_off : Icons.edit),
              onPressed: () {
                setState(() {
                  editMode = !editMode;
                });
              },
              tooltip: editMode ? 'Exit Edit Mode' : 'Enter Edit Mode',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Configuration Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Banner Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Vendor ID', widget.vendorId),
                    _buildInfoRow(
                      'Edit Mode',
                      editMode ? 'Enabled' : 'Disabled',
                    ),
                    _buildInfoRow(
                      'Auto Play',
                      autoPlay ? 'Enabled' : 'Disabled',
                    ),
                    _buildInfoRow(
                      'Owner Access',
                      widget.isVendorOwner ? 'Yes' : 'No',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Promo Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Promotional Banners',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Auto-play toggle
                        Row(
                          children: [
                            const Text('Auto Play:'),
                            const SizedBox(width: 8),
                            Switch(
                              value: autoPlay,
                              onChanged: (value) {
                                setState(() {
                                  autoPlay = value;
                                });
                              },
                              activeColor: TColors.primary,
                            ),
                          ],
                        ),
                      ],
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
                          vendorId: widget.vendorId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Usage Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usage Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      '1. Banner Display',
                      'Banners are automatically loaded for the specified vendor ID',
                    ),
                    _buildInstructionItem(
                      '2. Edit Mode',
                      'Only vendor owners can enable edit mode to add/remove banners',
                    ),
                    _buildInstructionItem(
                      '3. Auto Play',
                      'Toggle auto-play to enable/disable automatic banner rotation',
                    ),
                    _buildInstructionItem(
                      '4. Adding Banners',
                      'In edit mode, tap the + button to add new banners from gallery or camera',
                    ),
                    _buildInstructionItem(
                      '5. Banner Management',
                      'Use the settings button to manage existing banners',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Code Example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code Example',
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
                      child: const Text('''TPromoSlider(
  editMode: isVendorOwner,
  autoPlay: true,
  vendorId: 'vendor-123',
)''', style: TextStyle(fontFamily: 'monospace', fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: TColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '•',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
