-- إصلاح قيود جدول vendors مع الاعتماديات

-- 1. حذف القيود الخارجية التي تعتمد على vendors_pkey
ALTER TABLE vendor_categories DROP CONSTRAINT IF EXISTS vendor_categories_vendor_id_fkey;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_vendor_id_fkey;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_vendor_id_fkey;
ALTER TABLE user_follows DROP CONSTRAINT IF EXISTS user_follows_vendor_id_fkey;
ALTER TABLE vendor_statistics DROP CONSTRAINT IF EXISTS vendor_statistics_vendor_id_fkey;
ALTER TABLE temp_products DROP CONSTRAINT IF EXISTS temp_products_vendor_id_fkey;

-- 2. حذف القيد الأساسي لجدول vendors
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS vendors_pkey;

-- 3. تعديل عمود id ليتولّد تلقائياً
ALTER TABLE vendors ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 4. إضافة القيد الأساسي مرة أخرى
ALTER TABLE vendors ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);

-- 5. التأكد من أن عمود id لا يقبل NULL
ALTER TABLE vendors ALTER COLUMN id SET NOT NULL;

-- 6. إعادة إنشاء القيود الخارجية
ALTER TABLE vendor_categories 
ADD CONSTRAINT vendor_categories_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

ALTER TABLE products 
ADD CONSTRAINT products_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

ALTER TABLE orders 
ADD CONSTRAINT orders_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

ALTER TABLE user_follows 
ADD CONSTRAINT user_follows_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

ALTER TABLE vendor_statistics 
ADD CONSTRAINT vendor_statistics_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

ALTER TABLE temp_products 
ADD CONSTRAINT temp_products_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

-- 7. إنشاء فهرس على عمود id
CREATE INDEX IF NOT EXISTS idx_vendors_id ON vendors(id);

-- 8. فحص إعدادات العمود
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'vendors' 
AND column_name = 'id';

-- 9. فحص القيود الخارجية
SELECT 
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'vendors'
ORDER BY tc.table_name, tc.constraint_name;
