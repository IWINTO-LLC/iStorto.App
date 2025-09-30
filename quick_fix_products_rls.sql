-- حل سريع لسياسات RLS في جدول products
-- Quick fix for products RLS policies

-- حذف جميع السياسات الموجودة
DROP POLICY IF EXISTS "products_public_read_policy" ON products;
DROP POLICY IF EXISTS "products_own_data_read_policy" ON products;
DROP POLICY IF EXISTS "products_authenticated_insert_policy" ON products;
DROP POLICY IF EXISTS "products_own_data_update_policy" ON products;
DROP POLICY IF EXISTS "products_own_data_delete_policy" ON products;
DROP POLICY IF EXISTS "products_select_policy" ON products;
DROP POLICY IF EXISTS "products_own_select_policy" ON products;
DROP POLICY IF EXISTS "products_insert_policy" ON products;
DROP POLICY IF EXISTS "products_update_policy" ON products;
DROP POLICY IF EXISTS "products_delete_policy" ON products;

-- إنشاء سياسات بسيطة
CREATE POLICY "products_read" ON products
    FOR SELECT
    USING (true);

CREATE POLICY "products_insert" ON products
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "products_update" ON products
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "products_delete" ON products
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- التأكد من تفعيل RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
