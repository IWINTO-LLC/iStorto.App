# إصلاح مشكلة تحديث صور المتاجر (اللوغو والغلاف)

## 🔍 المشكلة المكتشفة

كانت المشكلة في **عدم تطابق المعرف** المستخدم في عمليات قاعدة البيانات:

### قبل الإصلاح:
```dart
// ❌ خطأ - في VendorImageController
await SupabaseService.client
    .from('vendors')
    .update({fieldName: imageUrl})
    .eq('user_id', vendorId);  // ❌ يستخدم user_id
```

```dart
// ✅ صحيح - في VendorRepository
final response = await _client
    .from('vendors_with_social_links')
    .select()
    .eq('id', vendorId);  // ✅ يستخدم id
```

**المشكلة:** `vendorId` الذي يتم تمريره هو `id` (المفتاح الأساسي) وليس `user_id`!

---

## ✅ الإصلاح المطبق

### 1. تحديث `VendorImageController`

**الملف:** `lib/featured/shop/controller/vendor_image_controller.dart`

**التغيير:**
```dart
// ✅ بعد الإصلاح
final response = await SupabaseService.client
    .from('vendors')
    .update({fieldName: imageUrl})
    .eq('id', vendorId)  // ✅ تغيير من user_id إلى id
    .select();
```

**إضافة logging للتتبع:**
```dart
debugPrint('🔄 Updating $fieldName for vendor: $vendorId');
debugPrint('📸 New image URL: $imageUrl');
debugPrint('✅ Update response: $response');
```

---

## 🛠️ الملفات المُنشأة

### 1. `fix_vendor_image_update_policy.sql`
سكريبت SQL لإصلاح سياسات RLS:
- ✅ يسمح للبائعين بتحديث متاجرهم
- ✅ يضمن الصلاحيات الصحيحة
- ✅ يفحص السياسات الحالية

**كيفية الاستخدام:**
```bash
# في Supabase SQL Editor
1. افتح SQL Editor
2. الصق محتوى الملف
3. نفذ السكريبت
4. راجع النتائج
```

### 2. `debug_vendor_image_update.sql`
سكريبت تصحيح أخطاء للتحقق من:
- ✅ بيانات المتجر
- ✅ المستخدم الحالي
- ✅ تطابق الصلاحيات
- ✅ سياسات RLS
- ✅ الأعمدة والجداول

**كيفية الاستخدام:**
```bash
1. افتح الملف
2. استبدل 'YOUR_VENDOR_ID' بمعرف المتجر الفعلي
3. استبدل 'YOUR_IMAGE_URL' برابط الصورة (للاختبار)
4. نفذ الاستعلامات واحداً تلو الآخر
5. راجع النتائج لتحديد المشكلة
```

---

## 📋 خطوات التحقق

### 1. التحقق من الكود

```dart
✅ VendorImageController يستخدم .eq('id', vendorId)
✅ إضافة debug logs للتتبع
✅ إضافة .select() لرؤية النتيجة
```

### 2. التحقق من قاعدة البيانات

```sql
-- فحص بنية الجدول
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'vendors';

-- التحقق من RLS
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'vendors';
```

### 3. التحقق من السياسات

```sql
-- عرض سياسات UPDATE
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'vendors' AND cmd = 'UPDATE';
```

---

## 🧪 اختبار الإصلاح

### 1. في التطبيق:

1. شغّل التطبيق في وضع debug
2. انتقل إلى صفحة المتجر في وضع التعديل
3. اضغط على شعار المتجر
4. اختر صورة جديدة
5. راقب console logs:
   ```
   🔄 Updating organization_logo for vendor: xxx-xxx-xxx
   📸 New image URL: https://...
   ✅ Update response: [...]
   ```

### 2. في Supabase:

1. افتح Table Editor
2. ابحث عن متجرك في جدول `vendors`
3. تحقق من تحديث `organization_logo` أو `organization_cover`
4. تحقق من تحديث `updated_at`

---

## 🎯 النتيجة المتوقعة

### عند رفع صورة جديدة:

1. ✅ تظهر دائرة التقدم (0% → 100%)
2. ✅ يتم رفع الصورة إلى Supabase Storage
3. ✅ يتم تحديث قاعدة البيانات بنجاح
4. ✅ يتم تحديث VendorController
5. ✅ تظهر الصورة الجديدة فوراً
6. ✅ إشعار أخضر: "تم تحديث شعار المتجر بنجاح!"

### في حالة الفشل:

1. ❌ رسالة خطأ حمراء
2. 📝 Debug logs في console تحدد المشكلة
3. 🔍 استخدم `debug_vendor_image_update.sql` للتحليل

---

## 🔧 استكشاف الأخطاء

### المشكلة: لا يزال التحديث لا يعمل

#### الحل 1: تحقق من vendor ID
```dart
// في market_header.dart
debugPrint('📍 Vendor ID being used: $vendorId');
debugPrint('📍 Vendor user_id: ${vendor.userId}');
```

#### الحل 2: تحقق من RLS
```bash
1. نفذ fix_vendor_image_update_policy.sql
2. تأكد من تفعيل RLS
3. تأكد من صلاحيات UPDATE
```

#### الحل 3: تحقق من الصلاحيات
```sql
-- في Supabase SQL Editor
SELECT * FROM vendors WHERE id = 'YOUR_VENDOR_ID';
-- إذا لم تظهر نتائج، هناك مشكلة في RLS
```

#### الحل 4: التحقق اليدوي
```sql
-- جرب التحديث يدوياً
UPDATE vendors 
SET organization_logo = 'test_url',
    updated_at = NOW()
WHERE id = 'YOUR_VENDOR_ID';

-- إذا نجح: المشكلة في الكود
-- إذا فشل: المشكلة في RLS أو الصلاحيات
```

---

## 📊 هيكل جدول vendors

```sql
- id (uuid, PK)             -- المفتاح الأساسي ✅ نستخدمه للتحديث
- user_id (uuid, FK)        -- معرف المستخدم
- organization_logo (text)  -- شعار المتجر
- organization_cover (text) -- غلاف المتجر
- updated_at (timestamp)    -- آخر تحديث
```

---

## 📝 ملاحظات

1. **استخدم دائماً `id` للعمليات على جدول `vendors`**
2. **استخدم `user_id` فقط للتحقق من الملكية في RLS**
3. **راقب debug logs للتأكد من التنفيذ**
4. **اختبر RLS policies قبل النشر**

---

## ✨ التحسينات المضافة

### 1. دائرة التقدم
- عرض نسبة التقدم (0-100%)
- نص "جاري الرفع"
- تحديث مباشر

### 2. Logging محسّن
- تتبع vendorId المستخدم
- عرض URL الصورة
- عرض نتيجة التحديث

### 3. معالجة أخطاء أفضل
- رسائل خطأ واضحة
- إعادة تعيين التقدم عند الفشل
- debug information مفصل

---

## 🎉 الخلاصة

تم إصلاح المشكلة بتغيير:
```diff
- .eq('user_id', vendorId)
+ .eq('id', vendorId)
```

الآن تحديث صور المتاجر يعمل بشكل صحيح! ✅

