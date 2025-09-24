# iStoreto - متجر إيستورتو

متجر إلكتروني متعدد التجار يدعم عدة لغات باستخدام Flutter و GetX.

## المميزات

- 🌍 **دعم متعدد اللغات**: يدعم 9 لغات (العربية، الإنجليزية، الإسبانية، الهندية، الفرنسية، الكورية، الألمانية، التركية، الروسية)
- 🎯 **GetX State Management**: إدارة حالة متقدمة وسهلة
- 🎨 **تصميم حديث**: واجهة مستخدم جميلة ومتجاوبة
- 📱 **متجاوب**: يعمل على جميع المنصات (Android, iOS, Web, Desktop)

## اللغات المدعومة

| اللغة | الكود | الاسم الأصلي |
|-------|-------|-------------|
| العربية | `ar` | العربية |
| الإنجليزية | `en` | English |
| الإسبانية | `es` | Español |
| الهندية | `hi` | हिन्दी |
| الفرنسية | `fr` | Français |
| الكورية | `ko` | 한국어 |
| الألمانية | `de` | Deutsch |
| التركية | `tr` | Türkçe |
| الروسية | `ru` | Русский |

## البنية

```
lib/
├── controllers/          # GetX Controllers
│   └── translation_controller.dart
├── translations/        # ملفات الترجمة
│   ├── ar.dart         # العربية
│   ├── en.dart         # الإنجليزية
│   ├── es.dart         # الإسبانية
│   ├── hi.dart         # الهندية
│   ├── fr.dart         # الفرنسية
│   ├── ko.dart         # الكورية
│   ├── de.dart         # الألمانية
│   ├── tr.dart         # التركية
│   ├── ru.dart         # الروسية
│   └── translations.dart
├── views/              # صفحات التطبيق
├── models/             # نماذج البيانات
├── services/           # الخدمات
├── utils/              # الأدوات المساعدة
├── widgets/            # المكونات المخصصة
│   └── language_switcher.dart
└── main.dart          # الملف الرئيسي
```

## التثبيت والتشغيل

1. **تثبيت التبعيات**:
   ```bash
   flutter pub get
   ```

2. **تشغيل التطبيق**:
   ```bash
   flutter run
   ```

## استخدام الترجمة

### في الكود

```dart
// استخدام النص المترجم
Text('welcome'.tr)

// تغيير اللغة برمجياً
final translationController = Get.find<TranslationController>();
translationController.changeLanguage('en');
```

### إضافة ترجمات جديدة

1. أضف المفتاح في جميع ملفات الترجمة
2. استخدم `.tr` للحصول على النص المترجم

## المكونات المخصصة

### LanguageSwitcher
مكون لتبديل اللغة مع قائمة منسدلة جميلة:

```dart
const LanguageSwitcher()
```

### CompactLanguageSwitcher
مكون مضغوط لتبديل اللغة مع bottom sheet:

```dart
const CompactLanguageSwitcher()
```

## GetX Features المستخدمة

- **State Management**: إدارة الحالة التفاعلية
- **Dependency Injection**: حقن التبعيات
- **Routing**: التوجيه السهل
- **Snackbars**: الرسائل المنبثقة
- **Internationalization**: الترجمة المتقدمة

## التطوير المستقبلي

- [ ] إضافة صفحات المنتجات
- [ ] نظام تسجيل الدخول
- [ ] سلة التسوق
- [ ] نظام الدفع
- [ ] إدارة التجار
- [ ] الإشعارات

## المساهمة

نرحب بالمساهمات! يرجى:

1. Fork المشروع
2. إنشاء branch جديد
3. Commit التغييرات
4. Push إلى Branch
5. إنشاء Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT.