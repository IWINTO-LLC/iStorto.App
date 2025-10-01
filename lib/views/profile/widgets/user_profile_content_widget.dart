import 'package:flutter/material.dart';

/// مكون محتوى الملف الشخصي للمستخدم - للعرض فقط
class UserProfileContentWidget extends StatelessWidget {
  final String bio;
  final String brief;
  final bool isVendor;

  const UserProfileContentWidget({
    super.key,
    required this.bio,
    required this.brief,
    required this.isVendor,
  });

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

            // قسم الوصف المختصر
            if (brief.isNotEmpty) ...[
              _buildBriefSection(),
              SizedBox(height: 24),
            ],

            // قسم معلومات إضافية للحساب التجاري
            if (isVendor) _buildVendorInfoSection(),
          ],
        ),
      ),
    );
  }

  /// بناء قسم "حول"
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'حول',
      icon: Icons.info_outline,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          bio.isNotEmpty ? bio : 'لا توجد معلومات متاحة',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// بناء قسم الوصف المختصر
  Widget _buildBriefSection() {
    return _buildSection(
      title: 'نبذة مختصرة',
      icon: Icons.short_text,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Text(
          brief,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue.shade800,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// بناء قسم معلومات الحساب التجاري
  Widget _buildVendorInfoSection() {
    return _buildSection(
      title: 'معلومات المتجر',
      icon: Icons.store,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.orange.shade700, size: 20),
                SizedBox(width: 8),
                Text(
                  'حساب تجاري معتمد',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'هذا المستخدم يمتلك حساب تجاري ويمكنك مشاهدة منتجاته وخدماته',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قسم عام
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }
}
