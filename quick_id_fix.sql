-- حل سريع لمشكلة ID في vendor_categories
-- Quick fix for ID issue in vendor_categories

-- 1. إضافة DEFAULT value للعمود ID
ALTER TABLE vendor_categories 
ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 2. التأكد من أن العمود ID مطلوب
ALTER TABLE vendor_categories 
ALTER COLUMN id SET NOT NULL;

-- 3. إضافة PRIMARY KEY إذا لم يكن موجوداً
ALTER TABLE vendor_categories ADD CONSTRAINT vendor_categories_pkey PRIMARY KEY (id);

-- 4. التحقق من النتيجة
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendor_categories'
AND column_name = 'id';











