-- إصلاح RLS باستخدام CASCADE (بديل آمن)
-- Fix RLS using CASCADE (safe alternative)

-- 1. محاولة حذف السياسات مع CASCADE
-- Try to drop policies with CASCADE
DROP POLICY IF EXISTS "vendor_categories_public_read_policy" ON vendor_categories CASCADE;
DROP POLICY IF EXISTS "vendor_categories_own_data_read_policy" ON vendor_categories CASCADE;
DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories CASCADE;
DROP POLICY IF EXISTS "vendor_categories_own_data_update_policy" ON vendor_categories CASCADE;
DROP POLICY IF EXISTS "vendor_categories_own_data_delete_policy" ON vendor_categories CASCADE;

-- 2. إنشاء سياسات جديدة بسيطة
-- Create new simple policies

-- سياسة القراءة
CREATE POLICY "vendor_categories_read" ON vendor_categories
    FOR SELECT
    USING (true);

-- سياسة الإدراج
CREATE POLICY "vendor_categories_insert" ON vendor_categories
    FOR INSERT
    WITH CHECK (true);

-- سياسة التحديث
CREATE POLICY "vendor_categories_update" ON vendor_categories
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- سياسة الحذف
CREATE POLICY "vendor_categories_delete" ON vendor_categories
    FOR DELETE
    USING (true);

-- 3. التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;





