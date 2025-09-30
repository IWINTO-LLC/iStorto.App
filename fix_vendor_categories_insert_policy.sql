-- إصلاح سياسة الإدراج لجدول vendor_categories
-- Fix INSERT policy for vendor_categories table

-- حذف السياسة الموجودة
DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;

-- إنشاء سياسة إدراج جديدة أكثر مرونة
-- Create a more flexible insert policy
CREATE POLICY "vendor_categories_authenticated_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (
            -- السماح للمستخدمين المسجلين بإدراج فئات جديدة
            -- Allow authenticated users to insert new categories
            true
            -- أو السماح للتاجر بإضافة فئات جديدة (إذا كان موجوداً)
            -- OR allow vendors to add new categories (if vendor exists)
            OR EXISTS (
                SELECT 1 FROM vendors 
                WHERE vendors.id = vendor_categories.vendor_id 
                AND vendors.user_id = auth.uid()::text
            )
        )
    );

-- بديل: سياسة أبسط تسمح لجميع المستخدمين المسجلين
-- Alternative: Simpler policy that allows all authenticated users
-- يمكن استخدام هذا إذا كان المطلوب السماح لجميع المستخدمين بإضافة فئات
-- Use this if you want to allow all users to add categories

-- DROP POLICY IF EXISTS "vendor_categories_authenticated_insert_policy" ON vendor_categories;
-- CREATE POLICY "vendor_categories_authenticated_insert_policy" ON vendor_categories
--     FOR INSERT
--     WITH CHECK (auth.role() = 'authenticated');

-- التحقق من السياسة الجديدة
-- Verify the new policy
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
AND policyname = 'vendor_categories_authenticated_insert_policy';
