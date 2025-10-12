# إصلاح مشكلة RLS في جدول products

## المشكلة
```
PostgrestException(message: new row violates row-level security policy for table "products", code: 42501, details: Forbidden, hint: null)
```

## السبب
السياسات الحالية لجدول `products` تمنع المستخدمين من إدراج منتجات جديدة.

## الحلول المتاحة

### الحل السريع (موصى به)
```sql
-- تشغيل هذا الملف في Supabase SQL Editor
quick_fix_products_rls.sql
```

### الحل المفصل
```sql
-- تشغيل هذا الملف لإصلاح سياسات products بالتفصيل
fix_products_rls_policy.sql
```

### الحل الشامل
```sql
-- تشغيل هذا الملف لإصلاح جميع الجداول المرتبطة
complete_products_rls_fix.sql
```

## خطوات التطبيق

### الطريقة 1: الحل السريع
1. اذهب إلى **Supabase Dashboard**
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ محتوى `quick_fix_products_rls.sql`
5. شغل الاستعلام

### الطريقة 2: الحل الشامل
1. استخدم `complete_products_rls_fix.sql`
2. هذا الملف يصلح جميع الجداول المرتبطة

## التحقق من النجاح
```sql
-- تشغيل هذا الاستعلام للتحقق
SELECT 
    tablename,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'products'
ORDER BY policyname;
```

## ما سيتم إصلاحه
- ✅ **جدول products**: سياسات مرنة للإدراج والتحديث
- ✅ **جدول vendor_categories**: سياسات مرنة (إذا لم يتم إصلاحها)
- ✅ **جدول vendors**: سياسات مرنة (إذا لزم الأمر)
- ✅ **إزالة القيود المعقدة**: التي تمنع إدراج المنتجات

## السياسات الجديدة

### جدول products
- **SELECT**: السماح لجميع المستخدمين بقراءة المنتجات النشطة
- **INSERT**: السماح للمستخدمين المسجلين بإضافة منتجات
- **UPDATE**: السماح للمستخدمين المسجلين بتحديث المنتجات
- **DELETE**: السماح للمستخدمين المسجلين بحذف المنتجات

## ملاحظات مهمة
- جرب الحل السريع أولاً
- إذا فشل، استخدم الحل الشامل
- تأكد من تشغيل الاستعلام كاملاً
- بعد الإصلاح، ستتمكن من إضافة منتجات جديدة

## الملفات المطلوبة
- `quick_fix_products_rls.sql` - الحل السريع
- `fix_products_rls_policy.sql` - الحل المفصل
- `complete_products_rls_fix.sql` - الحل الشامل
















