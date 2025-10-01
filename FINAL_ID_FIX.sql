-- الحل النهائي لمشكلة ID في vendor_categories
-- FINAL SOLUTION for vendor_categories ID issue

-- إضافة DEFAULT value للعمود ID
ALTER TABLE vendor_categories 
ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- التأكد من أن العمود ID مطلوب
ALTER TABLE vendor_categories 
ALTER COLUMN id SET NOT NULL;

-- إضافة PRIMARY KEY
ALTER TABLE vendor_categories ADD CONSTRAINT vendor_categories_pkey PRIMARY KEY (id);

-- التحقق من النتيجة
SELECT 
    'ID column fixed successfully' as status,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendor_categories'
AND column_name = 'id';





