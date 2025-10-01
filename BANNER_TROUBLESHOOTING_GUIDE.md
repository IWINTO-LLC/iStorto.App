# دليل استكشاف أخطاء البنرات
## Banner Troubleshooting Guide

---

## 🔴 المشكلة: البنرات لا تظهر
### Problem: Banners not appearing

---

## 🔍 الأسباب المحتملة

### 1️⃣ سياسات RLS غير مطبقة

**الأعراض**:
- صفحة Admin Banners فارغة
- رسالة "No company banners available"
- لا أخطاء واضحة في Console

**الحل**:
```sql
-- في Supabase SQL Editor
-- نفذ السكريبت من: lib/utils/fix_banner_rls_policies.sql
```

**التحقق**:
```sql
-- تحقق من السياسات الموجودة
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'banners';
```

يجب أن ترى:
- `Everyone can view all banners` (SELECT)
- `Authenticated users can insert company banners` (INSERT)
- `Authenticated users can update company banners` (UPDATE)
- `Authenticated users can delete company banners` (DELETE)

---

### 2️⃣ جدول البنرات غير موجود

**الأعراض**:
- خطأ: `relation "banners" does not exist`
- Console يظهر خطأ SQL

**الحل**:
```sql
-- في Supabase SQL Editor
-- نفذ السكريبت من: lib/utils/supabase_banner_schema.sql
```

---

### 3️⃣ لا توجد بنرات في قاعدة البيانات

**الأعراض**:
- الصفحة تعمل لكن فارغة
- لا أخطاء
- Console يظهر: "Total Banners: 0"

**الحل**:
أضف بنر تجريبي:
```sql
INSERT INTO banners (
    image, 
    target_screen, 
    active, 
    scope, 
    title, 
    description, 
    priority
) VALUES (
    'https://picsum.photos/800/400',
    '/home',
    true,
    'company',
    'Test Banner',
    'This is a test banner',
    1
);
```

---

### 4️⃣ خطأ Null check operator

**الأعراض**:
```
Null check operator used on a null value
ListView ListView:...admin_banners_page.dart:117:25
```

**السبب**: البنر له `id` قيمتها `null`

**الحل**: تم إصلاحه في الكود - أضفنا فحص null قبل استخدام `!`:
```dart
if (banner.id == null || banner.id!.isEmpty) {
  Get.snackbar('error'.tr, 'Invalid banner ID');
  return;
}
```

---

### 5️⃣ خطأ في تحويل البيانات من JSON

**الأعراض**:
- خطأ: `type 'String' is not a subtype of type 'int'`
- أو: `Failed host lookup`

**السبب**: مشكلة في `BannerModel.fromJson()`

**الحل**: تحقق من أن الحقول في قاعدة البيانات تطابق الـ Model:
```sql
-- تحقق من بنية الجدول
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'banners';
```

يجب أن ترى:
```
id          | uuid    | NO
image       | text    | NO
target_screen | text  | NO
active      | boolean | NO
vendor_id   | text    | YES
scope       | text    | NO
title       | text    | YES
description | text    | YES
priority    | integer | YES
created_at  | timestamp | YES
updated_at  | timestamp | YES
```

---

## 🧪 صفحة التصحيح (Debug Page)

### كيفية الوصول:
```
Admin Zone → Banner Debug
```

### ماذا تعرض:
- **Total Banners**: عدد البنرات الكلي
- **Active Banners**: عدد البنرات النشطة
- **Loading**: حالة التحميل
- **Banner Details**: تفاصيل كل بنر (ID, Title, Scope, Active)

### استخدامها:

1. **اضغط Refresh** ⟳
   - يعيد تحميل البنرات
   - يعرض معلومات مفصلة

2. **Test Supabase Connection**
   - يختبر الاتصال بـ Supabase
   - يعرض أي أخطاء اتصال

3. **Show Controller State**
   - يعرض حالة BannerController
   - يظهر عدد البنرات في الذاكرة

4. **Try Add Banner**
   - يحاول إضافة بنر تجريبي
   - يختبر سياسات INSERT

---

## 📊 فحوصات التحقق

### ✅ Checklist:

#### 1. قاعدة البيانات (Supabase)

```sql
-- 1. تحقق من وجود الجدول
SELECT COUNT(*) FROM banners;

-- 2. تحقق من البيانات
SELECT id, title, scope, active FROM banners;

-- 3. تحقق من السياسات
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'banners';

-- 4. تحقق من RLS مفعل
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'banners';
-- يجب أن يكون rowsecurity = TRUE
```

---

#### 2. الكود (Flutter)

```dart
// في BannerController
print('Banners count: ${banners.length}');
print('Loading: ${isLoading.value}');

// في admin_banners_page.dart
print('Company banners: ${companyBanners.length}');
print('Vendor banners: ${vendorBanners.length}');
```

---

#### 3. الشبكة (Network)

- تحقق من اتصال الإنترنت
- تحقق من Supabase URL صحيح
- تحقق من Supabase Anon Key صحيح

```dart
// في lib/utils/constants/constant.dart
const String supabaseUrl = 'https://jfveosdooutphhjyvcis.supabase.co';
const String supabaseAnonKey = '...';
```

---

## 🔧 حلول سريعة

### حل 1: إعادة تطبيق السياسات

```sql
-- حذف جميع السياسات القديمة
DROP POLICY IF EXISTS "Admins can manage company banners" ON banners;
DROP POLICY IF EXISTS "Anyone can view active banners" ON banners;
DROP POLICY IF EXISTS "Authenticated users can view all banners" ON banners;
DROP POLICY IF EXISTS "Authenticated users can view company banners" ON banners;

-- تطبيق السياسات الجديدة
-- (من ملف fix_banner_rls_policies.sql)
```

---

### حل 2: إعادة بناء التطبيق

```bash
# توقف التطبيق
# ثم:
flutter clean
flutter pub get
flutter run
```

---

### حل 3: مسح ذاكرة التخزين المؤقت

```dart
// في BannerController
void clearCache() {
  banners.clear();
  activeBanners.clear();
  lastFetchedUserId = null;
}
```

---

### حل 4: التحقق من المصادقة

```dart
// تحقق من أن المستخدم مسجل دخول
final user = Supabase.instance.client.auth.currentUser;
if (user == null) {
  print('❌ User not authenticated');
} else {
  print('✅ User: ${user.email}');
  print('✅ User ID: ${user.id}');
}
```

---

## 🐛 أخطاء شائعة ورسائلها

### خطأ 1: Permission Denied

```
Error: new row violates row-level security policy for table "banners"
```

**السبب**: سياسات RLS تمنع العملية

**الحل**:
1. تطبيق `fix_banner_rls_policies.sql`
2. تأكد من تسجيل الدخول
3. تأكد من `scope='company'` و `vendor_id IS NULL`

---

### خطأ 2: Relation Does Not Exist

```
Error: relation "banners" does not exist
```

**السبب**: جدول البنرات غير موجود

**الحل**: تطبيق `supabase_banner_schema.sql`

---

### خطأ 3: Failed to Load Banners

```
Error: Failed to load banners: Failed host lookup
```

**السبب**: مشكلة في الاتصال بالإنترنت أو Supabase

**الحل**:
1. تحقق من الإنترنت
2. تحقق من Supabase URL
3. تحقق من Firewall

---

### خطأ 4: Null Check Operator

```
Error: Null check operator used on a null value
```

**السبب**: `banner.id` قيمتها `null`

**الحل**: تم إصلاحه - الكود الآن يفحص null قبل الاستخدام

---

## 📞 خطوات التصحيح الموصى بها

### الخطوة 1: افتح صفحة Banner Debug

```
Admin Zone → Banner Debug → Refresh
```

**انظر إلى**:
- Total Banners (يجب أن يكون > 0 إذا كان هناك بنرات)
- Error messages (إذا كان هناك أخطاء)

---

### الخطوة 2: تحقق من قاعدة البيانات

```sql
-- في Supabase SQL Editor
SELECT COUNT(*) FROM banners;
```

**إذا كانت النتيجة 0**:
- لا توجد بنرات → أضف بنر تجريبي

**إذا كانت النتيجة > 0**:
- البنرات موجودة → المشكلة في السياسات أو الكود

---

### الخطوة 3: تحقق من السياسات

```sql
SELECT policyname FROM pg_policies WHERE tablename = 'banners';
```

**إذا لم تظهر السياسات الصحيحة**:
- طبق `fix_banner_rls_policies.sql`

---

### الخطوة 4: أعد تشغيل التطبيق

```bash
flutter run
```

---

### الخطوة 5: اختبر إضافة بنر

```
Admin Zone → Banner Management → + → From Gallery
```

**إذا نجحت**:
- ✅ كل شيء يعمل الآن

**إذا فشلت**:
- راجع رسالة الخطأ
- راجع Console logs

---

## 📝 معلومات إضافية للدعم

عند طلب المساعدة، وفر هذه المعلومات:

### 1. معلومات النظام
```
- Flutter version: flutter --version
- Supabase project: [YOUR_PROJECT_ID]
- OS: Windows/Mac/Linux
```

### 2. معلومات من Debug Page
```
- Total Banners: ?
- Error message: ?
- Stack trace: ?
```

### 3. نتائج SQL
```sql
-- عدد البنرات
SELECT COUNT(*) FROM banners;

-- السياسات
SELECT policyname FROM pg_policies WHERE tablename = 'banners';

-- RLS مفعل؟
SELECT rowsecurity FROM pg_tables WHERE tablename = 'banners';
```

### 4. Console Logs
```
- أي رسائل خطأ في Flutter console
- أي رسائل خطأ في Supabase logs
```

---

## 🎯 ملخص سريع

| المشكلة | الحل السريع |
|---------|-------------|
| البنرات لا تظهر | طبق `fix_banner_rls_policies.sql` |
| خطأ Null check | تم إصلاحه في الكود |
| Permission denied | تحقق من تسجيل الدخول + السياسات |
| لا توجد بنرات | أضف بنر تجريبي |
| خطأ اتصال | تحقق من Supabase URL/Key |

---

**آخر تحديث**: 2025  
**الحالة**: نشط  
**النسخة**: 1.0

