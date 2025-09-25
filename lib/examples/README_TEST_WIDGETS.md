# 🧪 Test Widgets Documentation

## 📁 الملفات المتاحة

### 1. **`test_categories_widget.dart`** (الأصلي - مُصلح)
ودجت بسيط لاختبار `MajorCategorySection` مع البيانات الحقيقية:

```dart
// الاستخدام
Get.to(() => const TestCategoriesWidget());
```

**المميزات:**
- ✅ يستخدم `MajorCategorySection` الحقيقي
- ✅ يحمل البيانات من قاعدة البيانات
- ✅ لا يسبب `setState()` أثناء البناء
- ✅ بسيط وسهل الاستخدام

### 2. **`test_categories_widget_v2.dart`** (النسخة المحسنة)
ودجت متقدم مع بيانات تجريبية محلية:

```dart
// الاستخدام
Get.to(() => const TestCategoriesWidgetV2());
```

**المميزات:**
- ✅ بيانات تجريبية محلية
- ✅ عرض شبكي للفئات
- ✅ تفاصيل الفئات
- ✅ إحصائيات الحالة
- ✅ ألوان وأيقونات تلقائية

## 🚀 كيفية الاستخدام

### الطريقة 1: اختبار مع البيانات الحقيقية

```dart
// في main.dart أو أي مكان مناسب
import 'examples/test_categories_widget.dart';

// الانتقال لصفحة الاختبار
Get.to(() => const TestCategoriesWidget());
```

### الطريقة 2: اختبار مع البيانات التجريبية

```dart
// في main.dart أو أي مكان مناسب
import 'examples/test_categories_widget_v2.dart';

// الانتقال لصفحة الاختبار
Get.to(() => const TestCategoriesWidgetV2());
```

## 🔧 إصلاح مشكلة `setState() during build`

### المشكلة الأصلية:
```dart
// ❌ خطأ - يسبب setState() أثناء البناء
class TestCategoriesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MajorCategoryController());
    _addTestCategories(controller); // ❌ يحدث أثناء build()
    return Scaffold(...);
  }
}
```

### الحل المُطبق:
```dart
// ✅ صحيح - يستخدم StatefulWidget مع initState
class TestCategoriesWidget extends StatefulWidget {
  @override
  State<TestCategoriesWidget> createState() => _TestCategoriesWidgetState();
}

class _TestCategoriesWidgetState extends State<TestCategoriesWidget> {
  @override
  void initState() {
    super.initState();
    // ✅ يتم تنفيذ بعد بناء الودجت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTestData();
    });
  }
}
```

## 📊 مقارنة النسختين

| الميزة | `test_categories_widget.dart` | `test_categories_widget_v2.dart` |
|--------|------------------------------|----------------------------------|
| **نوع البيانات** | حقيقية من قاعدة البيانات | تجريبية محلية |
| **العرض** | `MajorCategorySection` | شبكة مخصصة |
| **التفاعل** | أساسي | متقدم مع تفاصيل |
| **الإحصائيات** | لا | نعم |
| **الألوان** | تلقائية | مخصصة |
| **الاستخدام** | اختبار سريع | اختبار شامل |

## 🎯 متى تستخدم كل نسخة؟

### استخدم `test_categories_widget.dart` عندما:
- ✅ تريد اختبار `MajorCategorySection` الحقيقي
- ✅ تريد التأكد من عمل قاعدة البيانات
- ✅ تريد اختبار سريع وبسيط
- ✅ تريد رؤية البيانات الحقيقية

### استخدم `test_categories_widget_v2.dart` عندما:
- ✅ تريد اختبار واجهة مخصصة
- ✅ تريد بيانات تجريبية ثابتة
- ✅ تريد اختبار تفاعلي متقدم
- ✅ تريد رؤية إحصائيات مفصلة

## 🛠️ التخصيص

### إضافة فئات تجريبية جديدة:

```dart
// في test_categories_widget_v2.dart
testCategories = [
  MajorCategoryModel(
    id: '6',
    name: 'Books',
    arabicName: 'الكتب',
    isFeature: true,
    status: 1,
    // ... باقي الخصائص
  ),
  // ... فئات أخرى
];
```

### تغيير الألوان والأيقونات:

```dart
Color _getCategoryColor(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('books')) {
    return Colors.indigo; // لون جديد للكتب
  }
  // ... باقي الألوان
}

IconData _getCategoryIcon(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('books')) {
    return Icons.book; // أيقونة جديدة للكتب
  }
  // ... باقي الأيقونات
}
```

## 🚨 نصائح مهمة

1. **لا تستدع `setState()` في `build()`** - استخدم `initState()` أو `addPostFrameCallback()`
2. **استخدم `StatefulWidget`** عند الحاجة لتعديل البيانات
3. **اختبر مع البيانات الحقيقية** قبل النشر
4. **استخدم البيانات التجريبية** للتطوير السريع

## 📞 الدعم

إذا واجهت مشاكل:

1. تحقق من Console Logs
2. تأكد من عدم استدعاء `setState()` في `build()`
3. استخدم `StatefulWidget` عند الحاجة
4. راجع أمثلة الكود المرفقة
