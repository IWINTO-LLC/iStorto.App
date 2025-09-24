import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';
import 'es.dart';
import 'hi.dart';
import 'fr.dart';
import 'ko.dart';
import 'de.dart';
import 'tr.dart';
import 'ru.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': Ar.translations,
    'en': En.translations,
    'es': Es.translations,
    'hi': Hi.translations,
    'fr': Fr.translations,
    'ko': Ko.translations,
    'de': De.translations,
    'tr': Tr.translations,
    'ru': Ru.translations,
  };
}

// Language codes and names for language selection
class AppLanguages {
  static const List<Map<String, String>> languages = [
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

  static String getLanguageName(String code) {
    final language = languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'English', 'nativeName': 'English'},
    );
    return language['nativeName']!;
  }
}
