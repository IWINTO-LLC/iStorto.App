-- إصلاح RLS لجدول vendor_categories (يتطلب صلاحيات المشرف)
-- Fix RLS for vendor_categories table (requires admin privileges)

-- هذا الملف يجب تشغيله بواسطة المشرف أو مستخدم بصلاحيات SUPERUSER
-- This file must be run by admin or user with SUPERUSER privileges

-- 1. التحقق من الصلاحيات الحالية
-- Check current privileges
SELECT 
    table_name,
    privilege_type,
    grantee
FROM information_schema.table_privileges 
WHERE table_name = 'vendor_categories';

-- 2. منح الصلاحيات المطلوبة للمستخدم الحالي
-- Grant required privileges to current user
GRANT ALL ON TABLE vendor_categories TO authenticated;
GRANT ALL ON TABLE vendor_categories TO anon;

-- 3. حذف جميع السياسات الموجودة
-- Drop all existing policies
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'vendor_categories'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON vendor_categories';
    END LOOP;
END $$;

-- 4. إنشاء سياسات جديدة
-- Create new policies

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة الفئات النشطة
CREATE POLICY "vendor_categories_select_policy" ON vendor_categories
    FOR SELECT
    USING (is_active = true);

-- سياسة الإدراج: السماح لجميع المستخدمين المسجلين بإضافة فئات
CREATE POLICY "vendor_categories_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح لجميع المستخدمين المسجلين بتحديث الفئات
CREATE POLICY "vendor_categories_update_policy" ON vendor_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة الحذف: السماح لجميع المستخدمين المسجلين بحذف الفئات
CREATE POLICY "vendor_categories_delete_policy" ON vendor_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 5. التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- 6. التحقق من النتيجة
SELECT 
    'Policies created successfully' as status,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;











