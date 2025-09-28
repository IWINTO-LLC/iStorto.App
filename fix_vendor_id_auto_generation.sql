-- إصلاح عمود id في جدول vendors ليتولّد تلقائياً

-- 1. حذف القيود الموجودة على عمود id
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS vendors_pkey;

-- 2. تعديل عمود id ليتولّد تلقائياً
ALTER TABLE vendors ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. إضافة القيد الأساسي مرة أخرى
ALTER TABLE vendors ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);

-- 4. التأكد من أن عمود id لا يقبل NULL
ALTER TABLE vendors ALTER COLUMN id SET NOT NULL;

-- 5. إنشاء فهرس على عمود id (اختياري)
CREATE INDEX IF NOT EXISTS idx_vendors_id ON vendors(id);

-- 6. فحص إعدادات العمود
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'vendors' 
AND column_name = 'id';
