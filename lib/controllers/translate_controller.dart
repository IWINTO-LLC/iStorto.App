import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:istoreto/utils/constants/constant.dart';

class TranslateController extends GetxController {
  static TranslateController get instance => Get.find();
  RxBool enableTranslateProductDetails = false.obs;

  // كاش مركزي للترجمة
  final Map<String, String> _translationCache = {};
  static const String _cacheBox = 'translationCache';
  late Box translationBox;

  @override
  void onInit() {
    super.onInit();
    _initHiveCache();
  }

  Future<void> _initHiveCache() async {
    translationBox = await Hive.openBox(_cacheBox);
    _loadCache();
  }

  // تحميل الكاش من Hive
  void _loadCache() {
    _translationCache.clear();
    for (var key in translationBox.keys) {
      _translationCache[key] = translationBox.get(key);
    }
  }

  // حفظ مدخل جديد في الكاش
  Future<void> _saveCacheEntry(String key, String value) async {
    await translationBox.put(key, value);
  }

  // دالة ترجمة مع كاش
  Future<String> getTranslatedText({
    required String text,
    required String targetLangCode,
  }) async {
    final key = '$text|$targetLangCode';
    if (_translationCache.containsKey(key)) {
      return _translationCache[key]!;
    }
    final translated = await translateText(
      text: text,
      targetLangCode: targetLangCode,
    );
    _translationCache[key] = translated;
    await _saveCacheEntry(key, translated);
    return translated;
  }

  Future<String> translateText({
    required String text,
    required String targetLangCode,
  }) async {
    final url = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2?key=$googleTranslateApiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'q': text, 'target': targetLangCode, 'format': 'text'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Failed to translate text: ${response.body}');
    }
  }

  void translateProductDetails(
    String title,
    String description,
    String lang,
  ) async {
    try {
      String translatedTitle = await translateText(
        text: title,
        targetLangCode: lang,
      );
      String translatedDescription = await translateText(
        text: description,
        targetLangCode: lang,
      );
      // استخدم النتائج كما تريد (مثلاً: عرضها أو حفظها)
      print('العنوان المترجم: $translatedTitle');
      print('الوصف المترجم: $translatedDescription');
    } catch (e) {
      print('خطأ في الترجمة: $e');
    }
  }
}
