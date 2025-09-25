# 🧪 Testing Database Connection

## 📁 الملفات المتاحة

### 1. **`test_supabase_connection.dart`**
كلاس يحتوي على اختبارات شاملة لاتصال Supabase:

```dart
// اختبار الاتصال الأساسي
await TestSupabaseConnection.testConnection();

// اختبار جدول الفئات
await TestSupabaseConnection.testCategoriesTable();

// اختبار إدراج البيانات
await TestSupabaseConnection.testInsertData();
```

### 2. **`test_connection_page.dart`**
صفحة واجهة مستخدم لاختبار الاتصال:

```dart
// الانتقال لصفحة الاختبار
Get.to(() => const TestConnectionPage());
```

### 3. **`test_categories_widget.dart`**
ودجت لاختبار عرض الفئات:

```dart
// اختبار عرض الفئات
Get.to(() => const TestCategoriesWidget());
```

## 🚀 كيفية الاستخدام

### الطريقة 1: استخدام صفحة الاختبار

```dart
// في main.dart أو أي مكان مناسب
import 'examples/test_connection_page.dart';

// الانتقال لصفحة الاختبار
Get.to(() => const TestConnectionPage());
```

### الطريقة 2: استخدام الاختبارات المباشرة

```dart
// في أي مكان في التطبيق
import 'examples/test_supabase_connection.dart';

// تشغيل اختبار معين
await TestSupabaseConnection.testConnection();
```

### الطريقة 3: اختبار عرض الفئات

```dart
// اختبار عرض الفئات مع بيانات تجريبية
Get.to(() => const TestCategoriesWidget());
```

## 🔍 ما يتم اختباره

### 1. **اختبار الاتصال الأساسي**
- فحص الاتصال بـ Supabase
- اختبار الوصول للجدول
- فحص البيانات الخام

### 2. **اختبار جدول الفئات**
- استعلام أساسي
- استعلام بأعمدة محددة
- استعلام مع ترتيب
- استعلام مع حد
- فلترة حسب الحالة
- فلترة حسب المميز
- البحث

### 3. **اختبار إدراج البيانات**
- إدراج فئة تجريبية
- حذف البيانات التجريبية
- فحص الصلاحيات

## 📊 النتائج المتوقعة

### ✅ **نجح الاختبار:**
```
🧪 [TestSupabaseConnection] Starting Supabase connection test...
🔗 [TestSupabaseConnection] Supabase client initialized
🔑 [TestSupabaseConnection] Testing connection...
🧪 [TestSupabaseConnection] Testing basic connection...
✅ [TestSupabaseConnection] Basic connection successful: [{count: 2}]
📊 [TestSupabaseConnection] Table access successful: 2 rows
📋 [TestSupabaseConnection] Sample data: [{id: ..., name: ..., ...}, ...]
✅ [TestSupabaseConnection] All tests completed successfully!
```

### ❌ **فشل الاختبار:**
```
❌ [TestSupabaseConnection] Connection test failed: [Error details]
🔑 [TestSupabaseConnection] JWT/Authentication issue detected
🔒 [TestSupabaseConnection] Row Level Security issue detected
🚫 [TestSupabaseConnection] Permission issue detected
🌐 [TestSupabaseConnection] Network issue detected
```

## 🛠️ حل المشاكل الشائعة

### 1. **مشكلة RLS (Row Level Security)**
```sql
-- في Supabase SQL Editor
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
```

### 2. **مشكلة الصلاحيات**
- تحقق من صحة المفتاح
- تأكد من إعدادات الصلاحيات

### 3. **مشكلة الاتصال**
- تحقق من اتصال الإنترنت
- تأكد من صحة URL

### 4. **مشكلة اسم الجدول**
- تأكد من وجود جدول `categories`
- تحقق من case sensitivity

## 📱 واجهة الاختبار

صفحة الاختبار تحتوي على:

1. **أزرار الاختبار:**
   - Basic Connection Test
   - Categories Table Test
   - Insert Test
   - Run All Tests

2. **عرض النتائج:**
   - مربع نص لعرض النتائج
   - إمكانية التمرير
   - زر مسح النتائج

3. **مؤشر التحميل:**
   - يظهر أثناء تشغيل الاختبارات
   - يختفي عند انتهاء الاختبار

## 🎯 نصائح للاستخدام

1. **ابدأ بالاختبار الأساسي** قبل اختبارات أخرى
2. **راقب Console Logs** لمعرفة التفاصيل
3. **استخدم "Run All Tests"** للحصول على صورة شاملة
4. **تحقق من Supabase Dashboard** إذا فشلت الاختبارات

## 📞 الدعم

إذا واجهت مشاكل:

1. تحقق من Console Logs
2. راجع رسائل الخطأ
3. تأكد من إعدادات Supabase
4. جرب اختبارات مختلفة

## 🔧 التخصيص

يمكنك تخصيص الاختبارات:

```dart
// إضافة اختبار مخصص
static Future<void> customTest() async {
  print('🧪 [TestSupabaseConnection] Custom test...');
  
  final client = SupabaseService.client;
  final response = await client.from('your_table').select('*');
  
  print('📊 [TestSupabaseConnection] Custom result: ${response.length} rows');
}
```
