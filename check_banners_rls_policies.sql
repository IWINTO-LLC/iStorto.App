-- فحص سياسات RLS لجدول banners
-- Check RLS policies for banners table

-- 1. فحص حالة RLS
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'banners';

-- 2. عرض جميع السياسات
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
WHERE tablename = 'banners';

-- 3. فحص الصلاحيات
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges 
WHERE table_name = 'banners' 
AND table_schema = 'public';

-- 4. فحص المستخدم الحالي
SELECT current_user, session_user;
