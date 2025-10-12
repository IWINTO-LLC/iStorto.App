-- إصلاح سريع لمشكلة RLS في major_categories
-- Quick fix for RLS issue in major_categories

-- 1. حذف جميع السياسات الموجودة
-- Drop all existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON major_categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON major_categories;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON major_categories;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON major_categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON major_categories;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON major_categories;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON major_categories;

-- 2. إنشاء سياسات جديدة بسيطة
-- Create new simple policies

-- سياسة القراءة: السماح للجميع بقراءة الفئات
CREATE POLICY "public_read_policy" ON major_categories
    FOR SELECT
    USING (true);

-- سياسة الإدراج: السماح للمستخدمين المصادق عليهم
CREATE POLICY "public_insert_policy" ON major_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح للمستخدمين المصادق عليهم
CREATE POLICY "public_update_policy" ON major_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة الحذف: السماح للمستخدمين المصادق عليهم
CREATE POLICY "public_delete_policy" ON major_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 3. إعطاء الصلاحيات
-- Grant permissions
GRANT ALL ON major_categories TO anon;
GRANT ALL ON major_categories TO authenticated;
GRANT ALL ON major_categories TO service_role;

-- 4. اختبار سريع
-- Quick test
SELECT 'RLS Fixed' as status, COUNT(*) as category_count FROM major_categories;
