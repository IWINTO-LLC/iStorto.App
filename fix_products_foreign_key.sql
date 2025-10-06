-- إصلاح مشكلة Foreign Key في جدول products
-- Fix Foreign Key issue in products table

-- 1. التحقق من الجداول الموجودة
-- Check existing tables
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name IN ('products', 'categories', 'vendor_categories', 'major_categories')
ORDER BY table_name;

-- 2. التحقق من Foreign Key constraints
-- Check Foreign Key constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
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
AND tc.table_name = 'products';

-- 3. إصلاح Foreign Key constraint
-- Fix Foreign Key constraint

-- حذف Foreign Key constraint الموجود
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;

-- إنشاء Foreign Key constraint جديد يشير إلى vendor_categories
ALTER TABLE products 
ADD CONSTRAINT products_category_id_fkey 
FOREIGN KEY (category_id) 
REFERENCES vendor_categories(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- 4. التحقق من النتيجة
-- Check result
SELECT 
    'Foreign Key fixed successfully' as status,
    tc.constraint_name,
    tc.table_name,
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
AND tc.table_name = 'products';










