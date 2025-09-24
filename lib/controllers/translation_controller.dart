import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TranslationController extends GetxController {
  static TranslationController get instance => Get.find();

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
    // Initialize with Arabic as default
    _currentLanguage.value = 'ar';
  }

  // Change language method
  void changeLanguage(String languageCode) {
    if (_currentLanguage.value != languageCode) {
      _currentLanguage.value = languageCode;

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

  // Get language name by code
  String getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'hi':
        return 'हिन्दी';
      case 'fr':
        return 'Français';
      case 'ko':
        return '한국어';
      case 'de':
        return 'Deutsch';
      case 'tr':
        return 'Türkçe';
      case 'ru':
        return 'Русский';
      default:
        return 'English';
    }
  }

  // Get all available languages
  List<Map<String, String>> get availableLanguages => [
    {'code': 'ar', 'name': 'العربية', 'nativeName': 'العربية'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
  ];
}
