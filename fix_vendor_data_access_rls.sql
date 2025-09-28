-- إصلاح قيود RLS لضمان سحب بيانات التاجر بشكل سليم
-- Fix RLS policies to ensure proper vendor data access

-- 1. إصلاح قيود جدول vendors
-- Fix vendors table RLS policies

-- حذف السياسات الموجودة
DROP POLICY IF EXISTS "vendors_select_policy" ON vendors;
DROP POLICY IF EXISTS "vendors_insert_policy" ON vendors;
DROP POLICY IF EXISTS "vendors_update_policy" ON vendors;
DROP POLICY IF EXISTS "vendors_delete_policy" ON vendors;

-- إنشاء سياسات جديدة للقراءة العامة والكتابة للمستخدمين المسجلين
-- Create new policies for public read and authenticated write

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة بيانات التاجر النشط
-- Read policy: Allow all users to read active vendor data
CREATE POLICY "vendors_public_read_policy" ON vendors
    FOR SELECT
    USING (
        organization_activated = true 
        AND organization_deleted = false
    );

-- سياسة القراءة الخاصة: السماح للمستخدم بقراءة بياناته الخاصة
-- Private read policy: Allow users to read their own data
CREATE POLICY "vendors_own_data_read_policy" ON vendors
    FOR SELECT
    USING (auth.uid()::text = user_id);

-- سياسة الإدراج: السماح للمستخدمين المسجلين بإنشاء تاجر
-- Insert policy: Allow authenticated users to create vendors
CREATE POLICY "vendors_authenticated_insert_policy" ON vendors
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح للمستخدم بتحديث بياناته الخاصة
-- Update policy: Allow users to update their own data
CREATE POLICY "vendors_own_data_update_policy" ON vendors
    FOR UPDATE
    USING (auth.uid()::text = user_id)
    WITH CHECK (auth.uid()::text = user_id);

-- سياسة الحذف: السماح للمستخدم بحذف بياناته الخاصة
-- Delete policy: Allow users to delete their own data
CREATE POLICY "vendors_own_data_delete_policy" ON vendors
    FOR DELETE
    USING (auth.uid()::text = user_id);

-- 2. إصلاح قيود جدول user_profiles
-- Fix user_profiles table RLS policies

-- حذف السياسات الموجودة
DROP POLICY IF EXISTS "user_profiles_select_policy" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_insert_policy" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_update_policy" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_delete_policy" ON user_profiles;

-- إنشاء سياسات جديدة
-- Create new policies

-- سياسة القراءة: السماح للمستخدم بقراءة بياناته الخاصة
-- Read policy: Allow users to read their own data
CREATE POLICY "user_profiles_own_data_read_policy" ON user_profiles
    FOR SELECT
    USING (auth.uid()::text = user_id);

-- سياسة الإدراج: السماح للمستخدمين المسجلين بإنشاء ملف شخصي
-- Insert policy: Allow authenticated users to create profiles
CREATE POLICY "user_profiles_authenticated_insert_policy" ON user_profiles
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- سياسة التحديث: السماح للمستخدم بتحديث بياناته الخاصة
-- Update policy: Allow users to update their own data
CREATE POLICY "user_profiles_own_data_update_policy" ON user_profiles
    FOR UPDATE
    USING (auth.uid()::text = user_id)
    WITH CHECK (auth.uid()::text = user_id);

-- سياسة الحذف: السماح للمستخدم بحذف بياناته الخاصة
-- Delete policy: Allow users to delete their own data
CREATE POLICY "user_profiles_own_data_delete_policy" ON user_profiles
    FOR DELETE
    USING (auth.uid()::text = user_id);

-- 3. إصلاح قيود جدول vendor_categories
-- Fix vendor_categories table RLS policies

-- حذف السياسات الموجودة
DROP POLICY IF EXISTS "vendor_categories_select_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_insert_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_update_policy" ON vendor_categories;
DROP POLICY IF EXISTS "vendor_categories_delete_policy" ON vendor_categories;

-- إنشاء سياسات جديدة
-- Create new policies

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة فئات التاجر النشط
-- Read policy: Allow all users to read active vendor categories
CREATE POLICY "vendor_categories_public_read_policy" ON vendor_categories
    FOR SELECT
    USING (
        is_active = true
        AND EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.organization_activated = true 
            AND vendors.organization_deleted = false
        )
    );

-- سياسة القراءة الخاصة: السماح للتاجر بقراءة فئاته الخاصة
-- Private read policy: Allow vendors to read their own categories
CREATE POLICY "vendor_categories_own_data_read_policy" ON vendor_categories
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الإدراج: السماح للتاجر بإضافة فئات جديدة
-- Insert policy: Allow vendors to add new categories
CREATE POLICY "vendor_categories_authenticated_insert_policy" ON vendor_categories
    FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة التحديث: السماح للتاجر بتحديث فئاته الخاصة
-- Update policy: Allow vendors to update their own categories
CREATE POLICY "vendor_categories_own_data_update_policy" ON vendor_categories
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

-- سياسة الحذف: السماح للتاجر بحذف فئاته الخاصة
-- Delete policy: Allow vendors to delete their own categories
CREATE POLICY "vendor_categories_own_data_delete_policy" ON vendor_categories
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 4. إصلاح قيود جدول products
-- Fix products table RLS policies

-- حذف السياسات الموجودة
DROP POLICY IF EXISTS "products_select_policy" ON products;
DROP POLICY IF EXISTS "products_insert_policy" ON products;
DROP POLICY IF EXISTS "products_update_policy" ON products;
DROP POLICY IF EXISTS "products_delete_policy" ON products;

-- إنشاء سياسات جديدة
-- Create new policies

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة منتجات التاجر النشط
-- Read policy: Allow all users to read active vendor products
CREATE POLICY "products_public_read_policy" ON products
    FOR SELECT
    USING (
        is_active = true
        AND EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.organization_activated = true 
            AND vendors.organization_deleted = false
        )
    );

-- سياسة القراءة الخاصة: السماح للتاجر بقراءة منتجاته الخاصة
-- Private read policy: Allow vendors to read their own products
CREATE POLICY "products_own_data_read_policy" ON products
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الإدراج: السماح للتاجر بإضافة منتجات جديدة
-- Insert policy: Allow vendors to add new products
CREATE POLICY "products_authenticated_insert_policy" ON products
    FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة التحديث: السماح للتاجر بتحديث منتجاته الخاصة
-- Update policy: Allow vendors to update their own products
CREATE POLICY "products_own_data_update_policy" ON products
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الحذف: السماح للتاجر بحذف منتجاته الخاصة
-- Delete policy: Allow vendors to delete their own products
CREATE POLICY "products_own_data_delete_policy" ON products
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = products.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 5. تفعيل RLS على جميع الجداول
-- Enable RLS on all tables

ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 6. التحقق من السياسات
-- Verify policies

-- عرض جميع السياسات
-- Show all policies
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
WHERE tablename IN ('vendors', 'user_profiles', 'vendor_categories', 'products')
ORDER BY tablename, policyname;

-- عرض حالة RLS
-- Show RLS status
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename IN ('vendors', 'user_profiles', 'vendor_categories', 'products')
ORDER BY tablename;
