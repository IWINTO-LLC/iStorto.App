-- سكريبت تصحيح أخطاء تحديث صور المتاجر
-- استخدم هذا السكريبت للتحقق من البيانات والسياسات

-- 1. فحص بيانات المتجر
-- استبدل 'YOUR_VENDOR_ID' بالـ ID الفعلي للمتجر
SELECT 
  id,
  user_id,
  organization_name,
  organization_logo,
  organization_cover,
  organization_activated,
  organization_deleted,
  created_at,
  updated_at
FROM vendors
WHERE id = 'YOUR_VENDOR_ID'; -- ضع vendor id هنا

-- 2. التحقق من المستخدم الحالي
SELECT 
  auth.uid() as current_user_id,
  auth.email() as current_user_email;

-- 3. التحقق من تطابق user_id
-- استبدل 'YOUR_VENDOR_ID' بالـ ID الفعلي
SELECT 
  v.id as vendor_id,
  v.user_id as vendor_user_id,
  auth.uid() as current_user_id,
  v.user_id = auth.uid() as "is_owner"
FROM vendors v
WHERE v.id = 'YOUR_VENDOR_ID'; -- ضع vendor id هنا

-- 4. فحص سياسات RLS
SELECT 
  policyname,
  permissive,
  roles,
  cmd,
  qual as "using_condition",
  with_check as "with_check_condition"
FROM pg_policies
WHERE tablename = 'vendors' 
  AND cmd = 'UPDATE'
ORDER BY policyname;

-- 5. تجربة التحديث يدوياً
-- استبدل القيم التالية:
-- - YOUR_VENDOR_ID: معرف المتجر
-- - YOUR_IMAGE_URL: رابط الصورة الجديدة
/*
UPDATE vendors 
SET organization_logo = 'YOUR_IMAGE_URL',
    updated_at = NOW()
WHERE id = 'YOUR_VENDOR_ID' 
  AND user_id = auth.uid();
*/

-- 6. التحقق من الأعمدة المتاحة
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'vendors'
  AND column_name IN ('id', 'user_id', 'organization_logo', 'organization_cover')
ORDER BY ordinal_position;

-- 7. فحص الصلاحيات
SELECT 
  grantee,
  privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'vendors'
  AND privilege_type = 'UPDATE';

-- 8. فحص آخر تحديث للمتجر
-- استبدل 'YOUR_VENDOR_ID' بالـ ID الفعلي
SELECT 
  id,
  organization_name,
  updated_at,
  NOW() - updated_at as "time_since_update"
FROM vendors
WHERE id = 'YOUR_VENDOR_ID'; -- ضع vendor id هنا

