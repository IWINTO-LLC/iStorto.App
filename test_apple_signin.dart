// ملف اختبار Apple Sign-In
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';

class TestAppleSignIn extends StatelessWidget {
  const TestAppleSignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('اختبار Apple Sign-In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'اختبار Apple Sign-In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await controller.signInWithApple();
                  Get.snackbar(
                    'نجح',
                    'Apple Sign-In تم بنجاح!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'خطأ',
                    'فشل Apple Sign-In: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              icon: const Icon(Icons.apple),
              label: const Text('تسجيل الدخول عبر Apple'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ملاحظة: يجب أن تكون على جهاز iOS أو محاكي iOS',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
