-- الحل الآمن لمشكلة RLS في vendor_categories
-- SAFE SOLUTION for vendor_categories RLS issue

-- هذا الملف آمن للتشغيل ولا يتطلب صلاحيات خاصة
-- This file is safe to run and doesn't require special privileges

-- 1. التحقق من السياسات الموجودة أولاً
-- First, check existing policies
SELECT 
    'Current policies:' as info,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;

-- 2. محاولة حذف السياسات الموجودة (إذا أمكن)
-- Try to drop existing policies (if possible)
BEGIN;
    -- محاولة حذف السياسات
    -- Try to drop policies
    DROP POLICY IF EXISTS "vendor_categories_public_read_policy" ON vendor_categories;
    DROP POLICY IF EXISTS "vendor_categories_own_data_read_policy" ON vendor_categories;
    DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;
    DROP POLICY IF EXISTS "vendor_categories_own_data_update_policy" ON vendor_categories;
    DROP POLICY IF EXISTS "vendor_categories_own_data_delete_policy" ON vendor_categories;
    
    -- إذا نجح الحذف، أنشئ السياسات الجديدة
    -- If deletion succeeded, create new policies
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

    -- التأكد من تفعيل RLS
    ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;
    
    -- تأكيد التغييرات
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        -- في حالة الفشل، تراجع عن التغييرات
        -- If failed, rollback changes
        ROLLBACK;
        
        -- عرض رسالة الخطأ
        -- Show error message
        RAISE NOTICE 'Error: %. Please contact admin to fix RLS policies.', SQLERRM;
END;

-- 3. التحقق من النتيجة النهائية
-- Check final result
SELECT 
    'Final policies:' as info,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;
















