-- الحل النهائي لمشكلة RLS في جدول vendor_categories
-- FINAL SOLUTION for vendor_categories RLS issue

-- 1. حذف جميع السياسات الموجودة
-- Drop all existing policies
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

-- 2. إنشاء سياسات جديدة بسيطة ومرنة
-- Create new simple and flexible policies

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة الفئات النشطة
CREATE POLICY "vendor_categories_select_policy" ON vendor_categories
    FOR SELECT
    USING (is_active = true);

-- سياسة الإدراج: السماح لجميع المستخدمين المسجلين بإضافة فئات
CREATE POLICY "vendor_categories_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح لجميع المستخدمين المسجلين بتحديث الفئات
CREATE POLICY "vendor_categories_update_policy" ON vendor_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة الحذف: السماح لجميع المستخدمين المسجلين بحذف الفئات
CREATE POLICY "vendor_categories_delete_policy" ON vendor_categories
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- 3. التأكد من تفعيل RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- 4. التحقق من النتيجة
SELECT 
    'Policy created successfully' as status,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;
