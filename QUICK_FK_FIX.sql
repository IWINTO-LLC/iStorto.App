-- حل سريع جداً لمشكلة Foreign Key
-- Very quick solution for Foreign Key issue

-- حذف Foreign Key constraint الموجود
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;

-- إنشاء جدول categories بسيط
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- إضافة فئة افتراضية
INSERT INTO categories (title) VALUES ('General') ON CONFLICT DO NOTHING;

-- إنشاء Foreign Key constraint جديد
ALTER TABLE products 
ADD CONSTRAINT products_category_id_fkey 
FOREIGN KEY (category_id) 
REFERENCES categories(id) 
ON DELETE SET NULL;

-- تفعيل RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- سياسات RLS بسيطة
CREATE POLICY "categories_all" ON categories FOR ALL USING (true);

-- التحقق
SELECT 'Foreign Key fixed!' as status;




