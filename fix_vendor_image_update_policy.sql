-- إصلاح سياسات RLS لتحديث صور المتاجر (اللوغو والغلاف)
-- هذا السكريبت يضمن أن البائعين يمكنهم تحديث صور متاجرهم

-- 1. حذف السياسة القديمة إذا كانت موجودة
DROP POLICY IF EXISTS "vendors_update_own" ON vendors;

-- 2. إنشاء سياسة جديدة للسماح للبائعين بتحديث متاجرهم
CREATE POLICY "vendors_update_own" 
ON vendors 
FOR UPDATE 
USING (
  auth.uid() = user_id
)
WITH CHECK (
  auth.uid() = user_id
);

-- 3. التأكد من تفعيل RLS على جدول vendors
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- 4. منح صلاحيات التحديث للمستخدمين المصادق عليهم
GRANT UPDATE ON vendors TO authenticated;

-- 5. إنشاء سياسة للقراءة (إذا لم تكن موجودة)
DROP POLICY IF EXISTS "vendors_select_all" ON vendors;

CREATE POLICY "vendors_select_all" 
ON vendors 
FOR SELECT 
USING (
  organization_activated = true 
  AND organization_deleted = false
);

-- 6. السماح للبائع بقراءة بياناته حتى لو كان غير مفعل
DROP POLICY IF EXISTS "vendors_select_own" ON vendors;

CREATE POLICY "vendors_select_own" 
ON vendors 
FOR SELECT 
USING (
  auth.uid() = user_id
);

-- التحقق من السياسات
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
WHERE tablename = 'vendors'
ORDER BY policyname;

-- تأكيد تفعيل RLS
SELECT 
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename = 'vendors';

