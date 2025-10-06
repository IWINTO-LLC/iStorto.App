-- حل مؤقت: تعطيل RLS مؤقتاً ثم إعادة تفعيله
-- Temporary solution: Disable RLS temporarily then re-enable it

-- 1. تعطيل RLS مؤقتاً
-- Temporarily disable RLS
ALTER TABLE vendor_categories DISABLE ROW LEVEL SECURITY;

-- 2. حذف جميع السياسات الموجودة (بعد تعطيل RLS)
-- Drop all existing policies (after disabling RLS)
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

-- 3. إنشاء سياسات جديدة
-- Create new policies

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

-- 4. إعادة تفعيل RLS
-- Re-enable RLS
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- 5. التحقق من النتيجة
SELECT 
    'RLS fixed successfully' as status,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;











