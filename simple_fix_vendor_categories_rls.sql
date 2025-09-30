-- إصلاح بسيط لسياسة vendor_categories
-- Simple fix for vendor_categories RLS policy

-- حذف جميع السياسات الموجودة
DROP POLICY IF EXISTS "vendor_categories_public_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_update_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_delete_policy" ON vendor_categories;

-- إنشاء سياسات بسيطة ومرنة
-- Create simple and flexible policies

-- 1. سياسة القراءة: السماح لجميع المستخدمين بقراءة الفئات النشطة
CREATE POLICY "vendor_categories_read_policy" ON vendor_categories
    FOR SELECT
    USING (is_active = true);

-- 2. سياسة الإدراج: السماح لجميع المستخدمين المسجلين بإضافة فئات
CREATE POLICY "vendor_categories_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- 3. سياسة التحديث: السماح لجميع المستخدمين المسجلين بتحديث الفئات
CREATE POLICY "vendor_categories_update_policy" ON vendor_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- 4. سياسة الحذف: السماح لجميع المستخدمين المسجلين بحذف الفئات
CREATE POLICY "vendor_categories_delete_policy" ON vendor_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- التحقق من السياسات الجديدة
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;
