-- إصلاح سريع لجدول vendor_categories
-- Quick fix for vendor_categories table

-- حذف جميع السياسات الموجودة
DROP POLICY IF EXISTS "vendor_categories_public_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_update_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_delete_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_read_all" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_read_own" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_insert_authenticated" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_update_own" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_delete_own" ON vendor_categories;

-- إنشاء سياسات بسيطة جداً
-- Create very simple policies

-- السماح لجميع المستخدمين بقراءة الفئات
CREATE POLICY "allow_read_vendor_categories" ON vendor_categories
    FOR SELECT
    USING (true);

-- السماح للمستخدمين المسجلين بإدراج فئات جديدة
CREATE POLICY "allow_insert_vendor_categories" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- السماح للمستخدمين المسجلين بتحديث الفئات
CREATE POLICY "allow_update_vendor_categories" ON vendor_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- السماح للمستخدمين المسجلين بحذف الفئات
CREATE POLICY "allow_delete_vendor_categories" ON vendor_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;
