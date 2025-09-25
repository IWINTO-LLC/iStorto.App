# 🔍 Debugging Database Connection Issues

## 🚨 المشكلة: `Raw response: 0 categories found`

إذا كنت تحصل على `Raw response: 0 categories found` رغم وجود بيانات في الجدول، فإليك خطوات التشخيص:

## 🔧 خطوات التشخيص

### 1. **تشغيل اختبار الاتصال**

```dart
// في main.dart أو أي مكان مناسب
import 'examples/test_connection_page.dart';

// للانتقال لصفحة الاختبار
Get.to(() => const TestConnectionPage());
```

### 2. **فحص إعدادات Supabase**

تأكد من أن ملف `lib/services/supabase_service.dart` يحتوي على:

```dart
class SupabaseService {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static SupabaseClient get client => Supabase.instance.client;
}
```

### 3. **فحص الجدول في Supabase Dashboard**

1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **Table Editor**
4. تأكد من وجود جدول `categories`
5. تحقق من وجود البيانات

### 4. **فحص Row Level Security (RLS)**

إذا كان RLS مفعل:

```sql
-- في SQL Editor في Supabase
-- تعطيل RLS مؤقتاً للاختبار
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;

-- أو إنشاء policy للوصول العام
CREATE POLICY "Allow all operations on categories" ON categories
FOR ALL USING (true);
```

### 5. **فحص الصلاحيات**

تأكد من أن المفتاح المستخدم له صلاحيات القراءة:

```dart
// في test_supabase_connection.dart
print('🔑 [TestSupabaseConnection] Supabase Key: ${client.supabaseKey.substring(0, 20)}...');
```

### 6. **فحص اسم الجدول**

تأكد من أن اسم الجدول صحيح:

```dart
// في major_category_repository.dart
final response = await _client
    .from('categories')  // تأكد من أن هذا هو الاسم الصحيح
    .select()
    .order('created_at', ascending: false);
```

## 🧪 اختبارات التشخيص

### اختبار 1: الاتصال الأساسي

```dart
final response = await client.from('categories').select('count').execute();
print('Count: ${response.count}');
```

### اختبار 2: فحص البيانات الخام

```dart
final response = await client.from('categories').select('*');
print('Raw data: $response');
```

### اختبار 3: فحص الأعمدة

```dart
final response = await client.from('categories').select('id, name, status');
print('Columns: $response');
```

## 🔍 الأخطاء الشائعة وحلولها

### 1. **خطأ RLS (Row Level Security)**

**الخطأ:** `new row violates row-level security policy`

**الحل:**
```sql
-- تعطيل RLS
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;

-- أو إنشاء policy
CREATE POLICY "Enable read access for all users" ON categories
FOR SELECT USING (true);
```

### 2. **خطأ الصلاحيات**

**الخطأ:** `permission denied for table categories`

**الحل:**
- تأكد من استخدام المفتاح الصحيح
- تحقق من إعدادات الصلاحيات في Supabase

### 3. **خطأ اسم الجدول**

**الخطأ:** `relation "categories" does not exist`

**الحل:**
- تأكد من وجود الجدول
- تحقق من اسم الجدول (case-sensitive)

### 4. **خطأ الاتصال**

**الخطأ:** `Connection refused` أو `Network error`

**الحل:**
- تحقق من اتصال الإنترنت
- تأكد من صحة URL
- تحقق من إعدادات Firewall

## 📊 فحص البيانات

### في Supabase Dashboard:

1. **Table Editor:**
   - اذهب إلى `Table Editor`
   - اختر جدول `categories`
   - تحقق من وجود البيانات

2. **SQL Editor:**
   ```sql
   -- فحص البيانات
   SELECT * FROM categories;
   
   -- فحص العدد
   SELECT COUNT(*) FROM categories;
   
   -- فحص الأعمدة
   SELECT column_name, data_type 
   FROM information_schema.columns 
   WHERE table_name = 'categories';
   ```

3. **API Logs:**
   - اذهب إلى `Logs` > `API`
   - ابحث عن طلبات `categories`
   - تحقق من الأخطاء

## 🛠️ حلول سريعة

### 1. **إعادة تشغيل التطبيق**

```bash
flutter clean
flutter pub get
flutter run
```

### 2. **فحص Console Logs**

ابحث في console عن:
- `🔍 [MajorCategoryRepository]`
- `📊 [MajorCategoryRepository]`
- `❌ [MajorCategoryRepository]`

### 3. **اختبار مباشر**

```dart
// في أي مكان في التطبيق
import 'examples/test_supabase_connection.dart';

// تشغيل الاختبار
await TestSupabaseConnection.testConnection();
```

## 📱 استخدام صفحة الاختبار

1. **إضافة إلى التطبيق:**
```dart
// في main.dart
import 'examples/test_connection_page.dart';

// في أي مكان
Get.to(() => const TestConnectionPage());
```

2. **تشغيل الاختبارات:**
   - اضغط على "Basic Connection Test"
   - اضغط على "Categories Table Test"
   - اضغط على "Run All Tests"

3. **مراقبة النتائج:**
   - ستظهر النتائج في المربع السفلي
   - ابحث عن الأخطاء في النتائج

## 🎯 النتيجة المتوقعة

إذا كان كل شيء يعمل بشكل صحيح، يجب أن ترى:

```
🔍 [MajorCategoryRepository] Fetching all categories...
🔗 [MajorCategoryRepository] Supabase URL: https://your-project.supabase.co
🔑 [MajorCategoryRepository] Supabase Key: eyJhbGciOiJIUzI1NiIs...
🧪 [MajorCategoryRepository] Testing Supabase connection...
✅ [MajorCategoryRepository] Connection test successful: {count: 2}
📊 [MajorCategoryRepository] Raw response: 2 categories found
📋 [MajorCategoryRepository] Response data: [{id: ..., name: ..., ...}, ...]
✅ [MajorCategoryRepository] Successfully parsed 2 categories
```

إذا لم تر هذه الرسائل، فالمشكلة في الاتصال أو الإعدادات.
