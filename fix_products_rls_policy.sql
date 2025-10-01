-- إصلاح سياسات RLS لجدول products
-- Fix RLS policies for products table

-- 1. حذف جميع السياسات الموجودة
-- Drop all existing policies
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

-- 2. إنشاء سياسات جديدة مرنة
-- Create new flexible policies

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة المنتجات النشطة
CREATE POLICY "products_select_policy" ON products
    FOR SELECT
    USING (is_active = true AND is_deleted = false);

-- سياسة القراءة الخاصة: السماح للتاجر بقراءة منتجاته الخاصة
CREATE POLICY "products_own_select_policy" ON products
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الإدراج: السماح للمستخدمين المسجلين بإضافة منتجات
CREATE POLICY "products_insert_policy" ON products
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح للتاجر بتحديث منتجاته الخاصة
CREATE POLICY "products_update_policy" ON products
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الحذف: السماح للتاجر بحذف منتجاته الخاصة
CREATE POLICY "products_delete_policy" ON products
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 3. التأكد من تفعيل RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 4. التحقق من السياسات الجديدة
SELECT 
    'Products policies created successfully' as status,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'products'
ORDER BY policyname;




