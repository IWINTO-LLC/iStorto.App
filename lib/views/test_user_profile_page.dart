import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/views/user_profile_view_page.dart';

/// صفحة اختبار لعرض الملف الشخصي للمستخدم
class TestUserProfilePage extends StatelessWidget {
  const TestUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار عرض الملف الشخصي'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر نوع المستخدم للاختبار:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),

            // زر اختبار المستخدم العادي
            ElevatedButton.icon(
              onPressed: () => _testRegularUser(),
              icon: Icon(Icons.person),
              label: Text('مستخدم عادي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 12),

            // زر اختبار المستخدم التجاري
            ElevatedButton.icon(
              onPressed: () => _testVendorUser(),
              icon: Icon(Icons.business),
              label: Text('مستخدم تجاري'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 12),

            // زر اختبار المستخدم الحالي
            ElevatedButton.icon(
              onPressed: () => _testCurrentUser(),
              icon: Icon(Icons.account_circle),
              label: Text('المستخدم الحالي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            // معلومات إضافية
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• المستخدم العادي: يعرض البيانات الأساسية فقط\n'
                    '• المستخدم التجاري: يعرض علامة الحساب التجاري ورابط المتجر\n'
                    '• المستخدم الحالي: يعرض بيانات المستخدم المسجل حالياً',
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// اختبار المستخدم العادي
  void _testRegularUser() {
    Get.to(
      () => UserProfileViewPage(
        userId: 'regular_user_123',
        userName: 'أحمد محمد',
      ),
    );
  }

  /// اختبار المستخدم التجاري
  void _testVendorUser() {
    Get.to(
      () => UserProfileViewPage(
        userId: 'vendor_user_456',
        userName: 'متجر الأزياء الحديث',
      ),
    );
  }

  /// اختبار المستخدم الحالي
  void _testCurrentUser() {
    Get.to(
      () => UserProfileViewPage(
        userId: 'current_user_789',
        userName: 'المستخدم الحالي',
      ),
    );
  }
}
