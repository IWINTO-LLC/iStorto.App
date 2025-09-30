-- إصلاح مفصل لسياسات RLS لجدول vendor_categories
-- Detailed fix for vendor_categories RLS policies

-- الخطوة 1: حذف جميع السياسات الموجودة
-- Step 1: Drop all existing policies
DROP POLICY IF EXISTS "vendor_categories_public_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_update_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_own_data_delete_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_read_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_insert_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_update_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_delete_policy" ON vendor_categories;

-- الخطوة 2: إنشاء سياسات جديدة مرنة
-- Step 2: Create new flexible policies

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة الفئات النشطة
-- Read policy: Allow all users to read active categories
CREATE POLICY "vendor_categories_read_all" ON vendor_categories
    FOR SELECT
    USING (is_active = true);

-- سياسة القراءة الخاصة: السماح للمستخدمين بقراءة فئاتهم الخاصة
-- Private read policy: Allow users to read their own categories
CREATE POLICY "vendor_categories_read_own" ON vendor_categories
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الإدراج: السماح للمستخدمين المسجلين بإضافة فئات جديدة
-- Insert policy: Allow authenticated users to add new categories
CREATE POLICY "vendor_categories_insert_authenticated" ON vendor_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح للمستخدمين بتحديث فئاتهم الخاصة
-- Update policy: Allow users to update their own categories
CREATE POLICY "vendor_categories_update_own" ON vendor_categories
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الحذف: السماح للمستخدمين بحذف فئاتهم الخاصة
-- Delete policy: Allow users to delete their own categories
CREATE POLICY "vendor_categories_delete_own" ON vendor_categories
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- الخطوة 3: التأكد من تفعيل RLS
-- Step 3: Ensure RLS is enabled
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- الخطوة 4: التحقق من السياسات
-- Step 4: Verify policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;

-- الخطوة 5: اختبار الإدراج
-- Step 5: Test insert
-- يمكنك تشغيل هذا الاستعلام لاختبار الإدراج
-- You can run this query to test insert
/*
INSERT INTO vendor_categories (
    id,
    vendor_id,
    title,
    icon,
    color,
    is_active,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'your-vendor-id-here',
    'Test Category',
    'test_icon',
    '#FF0000',
    true,
    NOW(),
    NOW()
);
*/
