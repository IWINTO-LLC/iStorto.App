-- إصلاح مشكلة RLS Policy لجدول major_categories
-- Fix RLS Policy issue for major_categories table

-- 1. فحص السياسات الحالية
-- Check current policies
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
WHERE tablename = 'major_categories';

-- 2. حذف السياسات الموجودة (إذا كانت تسبب مشاكل)
-- Drop existing policies (if they cause issues)
DROP POLICY IF EXISTS "Enable read access for all users" ON major_categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON major_categories;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON major_categories;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON major_categories;

-- 3. إنشاء سياسات RLS صحيحة
-- Create correct RLS policies

-- سياسة القراءة: السماح للجميع بقراءة الفئات النشطة
-- Read policy: Allow everyone to read active categories
CREATE POLICY "Enable read access for all users" ON major_categories
    FOR SELECT
    USING (status = 1);

-- سياسة الإدراج: السماح للمستخدمين المصادق عليهم بإضافة فئات
-- Insert policy: Allow authenticated users to add categories
CREATE POLICY "Enable insert for authenticated users" ON major_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح للمستخدمين المصادق عليهم بتحديث الفئات
-- Update policy: Allow authenticated users to update categories
CREATE POLICY "Enable update for authenticated users" ON major_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة الحذف: السماح للمستخدمين المصادق عليهم بحذف الفئات
-- Delete policy: Allow authenticated users to delete categories
CREATE POLICY "Enable delete for authenticated users" ON major_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 4. التأكد من تفعيل RLS على الجدول
-- Ensure RLS is enabled on the table
ALTER TABLE major_categories ENABLE ROW LEVEL SECURITY;

-- 5. إعطاء الصلاحيات المناسبة للمستخدمين
-- Grant appropriate permissions to users
GRANT SELECT ON major_categories TO anon;
GRANT SELECT ON major_categories TO authenticated;
GRANT INSERT ON major_categories TO authenticated;
GRANT UPDATE ON major_categories TO authenticated;
GRANT DELETE ON major_categories TO authenticated;

-- 6. إعطاء صلاحيات للخدمات
-- Grant permissions to service role
GRANT ALL ON major_categories TO service_role;

-- 7. اختبار السياسات
-- Test the policies

-- اختبار القراءة (يجب أن يعمل)
-- Test read (should work)
SELECT COUNT(*) FROM major_categories WHERE status = 1;

-- اختبار الإدراج (يجب أن يعمل للمستخدمين المصادق عليهم)
-- Test insert (should work for authenticated users)
-- INSERT INTO major_categories (id, name, arabic_name, status, is_feature)
-- VALUES (gen_random_uuid(), 'Test Category', 'فئة تجريبية', 1, false);

-- 8. فحص النتائج
-- Check results
SELECT 
    'RLS Status' as check_type,
    CASE 
        WHEN relrowsecurity THEN 'Enabled'
        ELSE 'Disabled'
    END as status
FROM pg_class 
WHERE relname = 'major_categories'

UNION ALL

SELECT 
    'Policy Count' as check_type,
    COUNT(*)::text as status
FROM pg_policies 
WHERE tablename = 'major_categories'

UNION ALL

SELECT 
    'Permissions' as check_type,
    'Granted' as status
FROM information_schema.table_privileges 
WHERE table_name = 'major_categories' 
AND grantee IN ('anon', 'authenticated', 'service_role')
LIMIT 1;

-- 9. إضافة بيانات تجريبية إذا لم تكن موجودة
-- Add sample data if not exists
INSERT INTO major_categories (id, name, arabic_name, status, is_feature, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'Electronics',
    'إلكترونيات',
    1,
    true,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM major_categories WHERE name = 'Electronics'
);

INSERT INTO major_categories (id, name, arabic_name, status, is_feature, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'Clothing',
    'ملابس',
    1,
    true,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM major_categories WHERE name = 'Clothing'
);

INSERT INTO major_categories (id, name, arabic_name, status, is_feature, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    'Books',
    'كتب',
    1,
    false,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM major_categories WHERE name = 'Books'
);

-- 10. فحص البيانات النهائية
-- Check final data
SELECT 
    id,
    name,
    arabic_name,
    status,
    is_feature,
    created_at
FROM major_categories 
ORDER BY created_at DESC;

-- =====================================================
-- انتهاء الإصلاح
-- End of fix
