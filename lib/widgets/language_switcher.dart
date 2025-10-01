import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/translation_controller.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationController translationController =
        Get.find<TranslationController>();

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'language'.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: translationController.currentLanguage,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    translationController.changeLanguage(newValue);
                  }
                },
                items:
                    translationController.availableLanguages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language['code']!,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getLanguageFlag(language['code']!),
                            const SizedBox(width: 8),
                            Text(
                              language['nativeName']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLanguageFlag(String languageCode) {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: _getFlagWidget(languageCode),
      ),
    );
  }

  Widget _getFlagWidget(String languageCode) {
    // Simple flag representations using colors
    switch (languageCode) {
      case 'ar':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.white, Colors.black],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'en':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.white, Colors.blue],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'es':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.yellow, Colors.red],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'hi':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.white, Colors.green],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'fr':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.white, Colors.red],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'ko':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.white, Colors.blue],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'de':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red, Colors.yellow],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      case 'tr':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.white],
              stops: [0.0, 1.0],
            ),
          ),
        );
      case 'ru':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue, Colors.red],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      default:
        return Container(color: Colors.grey);
    }
  }
}

// Alternative compact language switcher
class CompactLanguageSwitcher extends StatelessWidget {
  const CompactLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationController translationController =
        Get.find<TranslationController>();

    return Obx(
      () => GestureDetector(
        onTap: () => _showLanguageBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                translationController.currentLanguage.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final TranslationController translationController =
        Get.find<TranslationController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'language'.tr,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...translationController.availableLanguages.map((language) {
              final isSelected =
                  translationController.currentLanguage == language['code'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                  child: Text(
                    language['code']!.toUpperCase(),
                    style: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  language['nativeName']!,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                  ),
                ),
                subtitle: Text(language['name']!),
                trailing:
                    isSelected
                        ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : null,
                onTap: () {
                  translationController.changeLanguage(language['code']!);
                  Get.back();
                },
              );
            }),
            const SizedBox(height: 20),
          ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
