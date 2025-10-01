import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// مكون أزرار الإجراءات للملف الشخصي - للعرض فقط
class UserProfileActionsWidget extends StatelessWidget {
  final String userId;
  final bool isVendor;
  final VoidCallback onViewStore;

  const UserProfileActionsWidget({
    super.key,
    required this.userId,
    required this.isVendor,
    required this.onViewStore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // زر مشاهدة المتجر (للحسابات التجارية فقط)
          if (isVendor) ...[
            _buildActionButton(
              icon: Icons.store,
              title: 'مشاهدة المتجر',
              subtitle: 'تصفح منتجات وخدمات هذا المتجر',
              color: Colors.blue,
              onTap: onViewStore,
            ),
            SizedBox(height: 12),
          ],

          SizedBox(height: 12),

          // زر المشاركة
          _buildActionButton(
            icon: Icons.share,
            title: 'مشاركة الملف الشخصي',
            subtitle: 'شارك هذا الملف الشخصي مع الآخرين',
            color: Colors.orange,
            onTap: _shareProfile,
          ),

          // مساحة إضافية في الأسفل
          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// بناء زر الإجراء
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ),
        onTap: onTap,
      ),
    );
  }

  /// مشاركة الملف الشخصي
  void _shareProfile() {
    Get.snackbar(
      'مشاركة',
      'ميزة المشاركة قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      duration: Duration(seconds: 2),
    );
  }
}
