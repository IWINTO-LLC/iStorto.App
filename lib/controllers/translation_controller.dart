import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:istoreto/services/storage_service.dart';
import 'package:istoreto/translations/translations.dart';

class TranslationController extends GetxController {
  static TranslationController get instance => Get.find();

  // مفتاح تخزين اللغة
  static const String _languageKey = 'app_language';

  // Current language code
  final RxString _currentLanguage = 'ar'.obs;

  // Getter for current language
  String get currentLanguage => _currentLanguage.value;

  // Getter for current locale
  Locale get currentLocale => Locale(_currentLanguage.value);

  // Check if current language is RTL
  bool get isRTL =>
      _currentLanguage.value == 'ar' || _currentLanguage.value == 'hi';

  @override
  void onInit() {
    super.onInit();
    // استعادة اللغة المحفوظة أو استخدام العربية كلغة افتراضية
    _loadSavedLanguage();
  }

  // تحميل اللغة المحفوظة
  void _loadSavedLanguage() {
    final savedLanguage = StorageService.instance.read(_languageKey);
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      _currentLanguage.value = savedLanguage;
      // تحديث اللغة في GetX
      Get.updateLocale(Locale(savedLanguage));
    } else {
      // استخدام العربية كلغة افتراضية
      _currentLanguage.value = 'ar';
    }
  }

  // Change language method
  void changeLanguage(String languageCode) {
    if (_currentLanguage.value != languageCode) {
      _currentLanguage.value = languageCode;

      // حفظ اللغة في التخزين المحلي
      StorageService.instance.write(_languageKey, languageCode);

      // Update GetX locale
      Get.updateLocale(Locale(languageCode));

      // Update app direction based on language
      _updateAppDirection();

      // Force rebuild of the entire app
      Get.forceAppUpdate();

      // Show success message
    }
  }

  // Update app direction based on language
  void _updateAppDirection() {
    if (isRTL) {
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  // الحصول على اسم اللغة من الكود - Get language name by code
  String getLanguageName(String code) {
    return AppLanguages.getLanguageName(code);
  }

  // الحصول على جميع اللغات المتاحة - Get all available languages
  List<Map<String, String>> get availableLanguages => AppLanguages.languages;
}
