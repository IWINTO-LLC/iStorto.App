-- إصلاح شامل لجدول vendor_categories
-- Complete fix for vendor_categories table

-- 1. التحقق من هيكل الجدول الحالي
-- Check current table structure
SELECT 
    'Current table structure:' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendor_categories'
ORDER BY ordinal_position;

-- 2. إصلاح عمود ID
-- Fix ID column

-- إضافة DEFAULT value للعمود ID
ALTER TABLE vendor_categories 
ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- التأكد من أن العمود ID مطلوب
ALTER TABLE vendor_categories 
ALTER COLUMN id SET NOT NULL;

-- إضافة PRIMARY KEY إذا لم يكن موجوداً
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'vendor_categories' 
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
        ALTER TABLE vendor_categories ADD PRIMARY KEY (id);
    END IF;
END $$;

-- 3. إصلاح RLS policies
-- Fix RLS policies

-- حذف السياسات الموجودة
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'vendor_categories'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON vendor_categories';
    END LOOP;
END $$;

-- إنشاء سياسات جديدة
CREATE POLICY "vendor_categories_select_policy" ON vendor_categories
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "vendor_categories_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "vendor_categories_update_policy" ON vendor_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "vendor_categories_delete_policy" ON vendor_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 4. التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- 5. إضافة قيم افتراضية للأعمدة الأخرى
-- Add default values for other columns

-- إضافة قيم افتراضية للأعمدة المطلوبة
ALTER TABLE vendor_categories 
ALTER COLUMN vendor_id SET DEFAULT '';

ALTER TABLE vendor_categories 
ALTER COLUMN title SET DEFAULT '';

ALTER TABLE vendor_categories 
ALTER COLUMN icon SET DEFAULT '';

ALTER TABLE vendor_categories 
ALTER COLUMN color SET DEFAULT '#000000';

ALTER TABLE vendor_categories 
ALTER COLUMN is_active SET DEFAULT true;

ALTER TABLE vendor_categories 
ALTER COLUMN created_at SET DEFAULT NOW();

ALTER TABLE vendor_categories 
ALTER COLUMN updated_at SET DEFAULT NOW();

-- 6. التحقق من النتيجة النهائية
-- Check final result
SELECT 
    'Final table structure:' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendor_categories'
ORDER BY ordinal_position;

-- عرض السياسات الجديدة
SELECT 
    'New policies:' as info,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE table_name = 'vendor_categories'
ORDER BY policyname;





