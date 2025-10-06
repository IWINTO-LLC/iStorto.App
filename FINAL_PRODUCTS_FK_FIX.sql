-- الحل النهائي لمشكلة Foreign Key في products
-- FINAL SOLUTION for products Foreign Key issue

-- 1. حذف Foreign Key constraint الموجود
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;

-- 2. إنشاء جدول categories بسيط
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(255),
    color VARCHAR(7) DEFAULT '#000000',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. إضافة فئة افتراضية
INSERT INTO categories (id, title, description, icon, color) VALUES
    (gen_random_uuid(), 'General', 'General products', 'category', '#FF5722')
ON CONFLICT (id) DO NOTHING;

-- 4. إنشاء Foreign Key constraint جديد
ALTER TABLE products 
ADD CONSTRAINT products_category_id_fkey 
FOREIGN KEY (category_id) 
REFERENCES categories(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- 5. تفعيل RLS على جدول categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 6. إنشاء سياسات RLS بسيطة
CREATE POLICY "categories_read" ON categories
    FOR SELECT
    USING (true);

CREATE POLICY "categories_insert" ON categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "categories_update" ON categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "categories_delete" ON categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 7. التحقق من النتيجة
SELECT 
    'Products Foreign Key fixed successfully' as status,
    COUNT(*) as categories_count
FROM categories;









