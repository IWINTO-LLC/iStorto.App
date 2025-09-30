-- حل بديل لمشكلة Foreign Key في products
-- Alternative solution for products Foreign Key issue

-- 1. حذف Foreign Key constraint الموجود
-- Drop existing Foreign Key constraint
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;

-- 2. إنشاء جدول categories إذا لم يكن موجوداً
-- Create categories table if not exists
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

-- 3. إضافة بعض الفئات الافتراضية
-- Add some default categories
INSERT INTO categories (id, title, description, icon, color) VALUES
    (gen_random_uuid(), 'General', 'General products', 'category', '#FF5722'),
    (gen_random_uuid(), 'Electronics', 'Electronic products', 'devices', '#2196F3'),
    (gen_random_uuid(), 'Clothing', 'Clothing and accessories', 'shopping_bag', '#4CAF50'),
    (gen_random_uuid(), 'Books', 'Books and publications', 'book', '#9C27B0'),
    (gen_random_uuid(), 'Home', 'Home and garden', 'home', '#FF9800')
ON CONFLICT (id) DO NOTHING;

-- 4. إنشاء Foreign Key constraint جديد
-- Create new Foreign Key constraint
ALTER TABLE products 
ADD CONSTRAINT products_category_id_fkey 
FOREIGN KEY (category_id) 
REFERENCES categories(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- 5. تفعيل RLS على جدول categories
-- Enable RLS on categories table
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 6. إنشاء سياسات RLS لجدول categories
-- Create RLS policies for categories table
CREATE POLICY "categories_select_policy" ON categories
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "categories_insert_policy" ON categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "categories_update_policy" ON categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "categories_delete_policy" ON categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 7. التحقق من النتيجة
-- Check result
SELECT 
    'Categories table and Foreign Key created successfully' as status,
    COUNT(*) as categories_count
FROM categories;


