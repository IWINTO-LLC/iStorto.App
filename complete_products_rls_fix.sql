-- إصلاح شامل لسياسات RLS لجميع جداول المنتجات
-- Complete RLS fix for all product-related tables

-- 1. إصلاح جدول products
-- Fix products table

-- حذف السياسات الموجودة
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'products'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON products';
    END LOOP;
END $$;

-- إنشاء سياسات جديدة
CREATE POLICY "products_select_policy" ON products
    FOR SELECT
    USING (is_active = true AND is_deleted = false);

CREATE POLICY "products_insert_policy" ON products
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "products_update_policy" ON products
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "products_delete_policy" ON products
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 2. إصلاح جدول vendor_categories (إذا لم يتم إصلاحه)
-- Fix vendor_categories table (if not already fixed)

-- حذف السياسات الموجودة
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

-- إنشاء سياسات جديدة
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

-- 3. إصلاح جدول vendors (إذا لزم الأمر)
-- Fix vendors table (if needed)

-- حذف السياسات الموجودة
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'vendors'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON vendors';
    END LOOP;
END $$;

-- إنشاء سياسات جديدة
CREATE POLICY "vendors_select_policy" ON vendors
    FOR SELECT
    USING (organization_activated = true AND organization_deleted = false);

CREATE POLICY "vendors_insert_policy" ON vendors
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "vendors_update_policy" ON vendors
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "vendors_delete_policy" ON vendors
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 4. التأكد من تفعيل RLS على جميع الجداول
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- 5. التحقق من النتيجة
SELECT 
    'All policies created successfully' as status,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename IN ('products', 'vendor_categories', 'vendors')
ORDER BY tablename, policyname;




