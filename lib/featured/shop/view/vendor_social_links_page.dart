import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';

class VendorSocialLinksPage extends StatefulWidget {
  final String vendorId;

  const VendorSocialLinksPage({super.key, required this.vendorId});

  @override
  State<VendorSocialLinksPage> createState() => _VendorSocialLinksPageState();
}

class _VendorSocialLinksPageState extends State<VendorSocialLinksPage> {
  // قائمة الروابط الافتراضية
  final List<Map<String, dynamic>> _defaultLinks = [
    {
      'type': 'website',
      'title': 'website',
      'icon': FontAwesomeIcons.globe,
      'placeholder': 'https://example.com',
      'color': Colors.blue,
    },
    {
      'type': 'email',
      'title': 'email',
      'icon': FontAwesomeIcons.envelope,
      'placeholder': 'contact@example.com',
      'color': Colors.red,
    },
    {
      'type': 'whatsapp',
      'title': 'whatsapp',
      'icon': FontAwesomeIcons.whatsapp,
      'placeholder': 'wa.me/123456789',
      'color': Colors.green,
    },
    {
      'type': 'phone',
      'title': 'phone',
      'icon': FontAwesomeIcons.phone,
      'placeholder': '+1234567890',
      'color': Colors.orange,
    },
    {
      'type': 'location',
      'title': 'location',
      'icon': FontAwesomeIcons.locationDot,
      'placeholder': 'google.com/maps/...',
      'color': Colors.red,
    },
    {
      'type': 'linkedin',
      'title': 'linkedin',
      'icon': FontAwesomeIcons.linkedin,
      'placeholder': 'linkedin.com/in/...',
      'color': Colors.blue,
    },
    {
      'type': 'youtube',
      'title': 'youtube',
      'icon': FontAwesomeIcons.youtube,
      'placeholder': 'youtube.com/channel/...',
      'color': Colors.red,
    },
  ];

  // Controllers للنصوص
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _toggleStates = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingLinks();
  }

  void _initializeControllers() {
    for (var link in _defaultLinks) {
      _controllers[link['type']] = TextEditingController();
      _toggleStates[link['type']] = false;
    }
  }

  void _loadExistingLinks() {
    // TODO: تحميل الروابط الموجودة من قاعدة البيانات
    // يمكن استخدام VendorSocialLinksController هنا
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'social_links_management'.tr,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveLinks),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSection(
                title: 'personal_information'.tr,
                children: [
                  _buildLinkItem(
                    type: 'website',
                    title: 'website',
                    icon: FontAwesomeIcons.globe,
                    placeholder: 'https://example.com',
                    color: Colors.blue,
                  ),
                  _buildLinkItem(
                    type: 'email',
                    title: 'email',
                    icon: FontAwesomeIcons.envelope,
                    placeholder: 'contact@example.com',
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Business Information Section
              _buildSection(
                title: 'business_information'.tr,
                children: [
                  _buildLinkItem(
                    type: 'whatsapp',
                    title: 'whatsapp',
                    icon: FontAwesomeIcons.whatsapp,
                    placeholder: 'wa.me/123456789',
                    color: Colors.green,
                  ),
                  _buildLinkItem(
                    type: 'phone',
                    title: 'phone',
                    icon: FontAwesomeIcons.phone,
                    placeholder: '+1234567890',
                    color: Colors.orange,
                  ),
                  _buildLinkItem(
                    type: 'location',
                    title: 'location',
                    icon: FontAwesomeIcons.locationDot,
                    placeholder: 'google.com/maps/...',
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social Links Section
              _buildSection(
                title: 'social_links'.tr,
                children: [
                  _buildLinkItem(
                    type: 'linkedin',
                    title: 'linkedin',
                    icon: FontAwesomeIcons.linkedin,
                    placeholder: 'linkedin.com/in/...',
                    color: Colors.blue,
                  ),
                  _buildLinkItem(
                    type: 'youtube',
                    title: 'youtube',
                    icon: FontAwesomeIcons.youtube,
                    placeholder: 'youtube.com/channel/...',
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveLinks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'save_changes'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildLinkItem({
    required String type,
    required String title,
    required IconData icon,
    required String placeholder,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers[type],
                  decoration: InputDecoration(
                    hintText: placeholder,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Toggle Switch
          Switch(
            value: _toggleStates[type] ?? false,
            onChanged: (value) {
              setState(() {
                _toggleStates[type] = value;
              });
            },
            activeColor: Colors.black,
            activeTrackColor: Colors.black.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  void _saveLinks() {
    // TODO: حفظ الروابط في قاعدة البيانات
    Get.snackbar(
      'success'.tr,
      'social_links_saved_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
}
