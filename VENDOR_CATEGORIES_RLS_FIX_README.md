# إصلاح مشكلة RLS في جدول vendor_categories

## المشكلة
```
PostgrestException(message: new row violates row-level security policy for table "vendor_categories", code: 42501, details: Forbidden, hint: null)
```

## السبب
السياسات الحالية لجدول `vendor_categories` تتطلب أن يكون المستخدم الحالي هو مالك التاجر، لكن هذا يمنع إضافة فئات جديدة.

## الحل

### الطريقة 1: استخدام الملف الجاهز (موصى به)
```sql
-- تشغيل هذا الملف في Supabase SQL Editor
FINAL_FIX_vendor_categories_rls.sql
```

### الطريقة 2: تشغيل الأوامر يدوياً
```sql
-- 1. حذف السياسات الموجودة
DROP POLICY IF EXISTS "vendor_categories_public_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_update_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_delete_policy" ON vendor_categories;

-- 2. إنشاء سياسات جديدة
CREATE POLICY "vendor_categories_select_policy" ON vendor_categories
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "vendor_categories_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "vendor_categories_update_policy" ON vendor_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "vendor_categories_delete_policy" ON vendor_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 3. التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;
```

## التحقق من الحل
```sql
-- عرض السياسات الجديدة
SELECT 
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;
```

## ما تم تغييره
1. **سياسة القراءة**: السماح لجميع المستخدمين بقراءة الفئات النشطة
2. **سياسة الإدراج**: السماح لجميع المستخدمين المسجلين بإضافة فئات جديدة
3. **سياسة التحديث**: السماح لجميع المستخدمين المسجلين بتحديث الفئات
4. **سياسة الحذف**: السماح لجميع المستخدمين المسجلين بحذف الفئات

## ملاحظات
- هذا الحل يسمح لجميع المستخدمين المسجلين بإدارة الفئات
- إذا كنت تريد قيود أكثر صرامة، يمكن تعديل السياسات لاحقاً
- تأكد من تشغيل هذا الحل في Supabase SQL Editor
