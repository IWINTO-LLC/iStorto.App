import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// مكون محتوى الملف الشخصي - يعرض قسم "حول" والاهتمامات
class ProfileContentWidget extends StatelessWidget {
  const ProfileContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم "حول"
            _buildAboutSection(),

            SizedBox(height: 24),

            // قسم الاهتمامات (مخفي حالياً)
            _buildInterestsSection(),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// بناء قسم "حول"
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'about'.tr,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'about_description'.tr,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// بناء قسم الاهتمامات
  Widget _buildInterestsSection() {
    return Visibility(
      visible: false, // مخفي حالياً
      child: _buildSection(
        title: 'interests'.tr,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildInterestChip('science'.tr, Icons.science, Colors.blue),
            _buildInterestChip('technology'.tr, Icons.computer, Colors.pink),
            _buildInterestChip('design'.tr, Icons.palette, Colors.green),
          ],
        ),
      ),
    );
  }

  /// بناء قسم عام
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  /// بناء شريحة الاهتمام
  Widget _buildInterestChip(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
