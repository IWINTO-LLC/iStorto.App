import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/translation_controller.dart';
import '../widgets/language_switcher.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translationController = Get.find<TranslationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [const CompactLanguageSwitcher(), const SizedBox(width: 8)],
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Language: ${translationController.currentLanguage}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'welcome'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Text('app_name'.tr, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),

              Text('home'.tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              Text('categories'.tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              Text('cart'.tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              Text('profile'.tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              const LanguageSwitcher(),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'success'.tr,
                    'language_changed'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Text('test_snackbar'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
