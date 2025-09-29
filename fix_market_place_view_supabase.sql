-- إصلاح شامل لصفحة MarketPlaceView مع Supabase
-- Comprehensive fix for MarketPlaceView page with Supabase

-- ==============================================
-- 1. تحديث جدول vendors
-- ==============================================

-- إضافة الحقول المفقودة إذا لم تكن موجودة
ALTER TABLE vendors 
ADD COLUMN IF NOT EXISTS selected_major_categories TEXT,
ADD COLUMN IF NOT EXISTS organization_cover TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS store_message TEXT DEFAULT '';

-- تحديث القيم الافتراضية
UPDATE vendors 
SET 
  selected_major_categories = COALESCE(selected_major_categories, ''),
  organization_cover = COALESCE(organization_cover, ''),
  store_message = COALESCE(store_message, '')
WHERE 
  selected_major_categories IS NULL 
  OR organization_cover IS NULL 
  OR store_message IS NULL;

-- ==============================================
-- 2. إضافة الفهارس للأداء
-- ==============================================

-- فهارس أساسية
CREATE INDEX IF NOT EXISTS idx_vendors_user_id ON vendors(user_id);
CREATE INDEX IF NOT EXISTS idx_vendors_organization_activated ON vendors(organization_activated);
CREATE INDEX IF NOT EXISTS idx_vendors_organization_deleted ON vendors(organization_deleted);
CREATE INDEX IF NOT EXISTS idx_vendors_is_verified ON vendors(is_verified);
CREATE INDEX IF NOT EXISTS idx_vendors_created_at ON vendors(created_at);

-- فهارس للبحث
CREATE INDEX IF NOT EXISTS idx_vendors_organization_name ON vendors USING gin(to_tsvector('english', organization_name));
CREATE INDEX IF NOT EXISTS idx_vendors_slugn ON vendors(slugn);

-- ==============================================
-- 3. إصلاح سياسات RLS
-- ==============================================

-- حذف السياسات الموجودة
DROP POLICY IF EXISTS "Users can view their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can insert their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can update their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can delete their own vendor" ON vendors;
DROP POLICY IF EXISTS "Public can view active vendors" ON vendors;
DROP POLICY IF EXISTS "Authenticated users can view vendors" ON vendors;

-- تفعيل RLS
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة - المستخدمون يمكنهم رؤية vendor الخاص بهم
CREATE POLICY "Users can view their own vendor" ON vendors
FOR SELECT USING (auth.uid() = user_id);

-- سياسة الإدراج - المستخدمون يمكنهم إدراج vendor جديد
CREATE POLICY "Users can insert their own vendor" ON vendors
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- سياسة التحديث - المستخدمون يمكنهم تحديث vendor الخاص بهم
CREATE POLICY "Users can update their own vendor" ON vendors
FOR UPDATE USING (auth.uid() = user_id);

-- سياسة الحذف - المستخدمون يمكنهم حذف vendor الخاص بهم
CREATE POLICY "Users can delete their own vendor" ON vendors
FOR DELETE USING (auth.uid() = user_id);

-- سياسة القراءة العامة - عرض vendors النشطين للجميع
CREATE POLICY "Public can view active vendors" ON vendors
FOR SELECT USING (
  organization_activated = true 
  AND organization_deleted = false
);

-- سياسة القراءة للمستخدمين المسجلين - عرض جميع vendors للمستخدمين المسجلين
CREATE POLICY "Authenticated users can view all vendors" ON vendors
FOR SELECT USING (auth.role() = 'authenticated');

-- ==============================================
-- 4. إصلاح جدول user_profiles
-- ==============================================

-- التأكد من وجود حقل account_type
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS account_type INTEGER DEFAULT 0;

-- تحديث القيم الافتراضية
UPDATE user_profiles 
SET account_type = COALESCE(account_type, 0)
WHERE account_type IS NULL;

-- إصلاح سياسات user_profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" ON user_profiles
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON user_profiles
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" ON user_profiles
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==============================================
-- 5. إصلاح جدول major_categories
-- ==============================================

-- التأكد من وجود الحقول المطلوبة
ALTER TABLE major_categories 
ADD COLUMN IF NOT EXISTS status INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS image TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- تحديث القيم الافتراضية
UPDATE major_categories 
SET 
  status = COALESCE(status, 1),
  is_featured = COALESCE(is_featured, false),
  image = COALESCE(image, ''),
  created_at = COALESCE(created_at, NOW()),
  updated_at = COALESCE(updated_at, NOW())
WHERE 
  status IS NULL 
  OR is_featured IS NULL 
  OR image IS NULL 
  OR created_at IS NULL 
  OR updated_at IS NULL;

-- إصلاح سياسات major_categories
DROP POLICY IF EXISTS "Public can view major categories" ON major_categories;
DROP POLICY IF EXISTS "Authenticated users can manage categories" ON major_categories;

ALTER TABLE major_categories ENABLE ROW LEVEL SECURITY;

-- قراءة عامة للفئات النشطة
CREATE POLICY "Public can view major categories" ON major_categories
FOR SELECT USING (status = 1);

-- إدارة الفئات للمستخدمين المسجلين (للمديرين)
CREATE POLICY "Authenticated users can manage categories" ON major_categories
FOR ALL USING (auth.role() = 'authenticated');

-- ==============================================
-- 6. إضافة دوال مساعدة
-- ==============================================

-- دالة لتحديث timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إضافة trigger لتحديث updated_at تلقائياً
DROP TRIGGER IF EXISTS update_vendors_updated_at ON vendors;
CREATE TRIGGER update_vendors_updated_at
    BEFORE UPDATE ON vendors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_major_categories_updated_at ON major_categories;
CREATE TRIGGER update_major_categories_updated_at
    BEFORE UPDATE ON major_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================
-- 7. إضافة بيانات تجريبية
-- ==============================================

-- إضافة فئات عامة تجريبية
INSERT INTO major_categories (id, name, name_ar, description, description_ar, status, is_featured, image)
VALUES 
  (gen_random_uuid(), 'Electronics', 'إلكترونيات', 'Electronic devices and gadgets', 'الأجهزة الإلكترونية والأدوات', 1, true, ''),
  (gen_random_uuid(), 'Fashion', 'أزياء', 'Clothing and fashion items', 'الملابس والأزياء', 1, true, ''),
  (gen_random_uuid(), 'Home & Garden', 'المنزل والحديقة', 'Home and garden products', 'منتجات المنزل والحديقة', 1, false, ''),
  (gen_random_uuid(), 'Sports', 'رياضة', 'Sports and fitness equipment', 'معدات الرياضة واللياقة', 1, false, ''),
  (gen_random_uuid(), 'Books', 'كتب', 'Books and educational materials', 'الكتب والمواد التعليمية', 1, false, '')
ON CONFLICT (id) DO NOTHING;

-- ==============================================
-- 8. إضافة views مفيدة
-- ==============================================

-- View للvendors النشطين مع تفاصيل المستخدم
CREATE OR REPLACE VIEW active_vendors_view AS
SELECT 
  v.*,
  up.display_name,
  up.email,
  up.phone,
  up.avatar_url
FROM vendors v
LEFT JOIN user_profiles up ON v.user_id = up.user_id
WHERE v.organization_activated = true 
  AND v.organization_deleted = false;

-- View للفئات النشطة
CREATE OR REPLACE VIEW active_categories_view AS
SELECT *
FROM major_categories
WHERE status = 1
ORDER BY is_featured DESC, name ASC;

-- ==============================================
-- 9. إضافة permissions للviews
-- ==============================================

-- صلاحيات القراءة للviews
GRANT SELECT ON active_vendors_view TO authenticated;
GRANT SELECT ON active_categories_view TO authenticated;
GRANT SELECT ON active_vendors_view TO anon;
GRANT SELECT ON active_categories_view TO anon;

-- ==============================================
-- 10. التحقق من الإعداد
-- ==============================================

-- عرض جميع السياسات
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
WHERE tablename IN ('vendors', 'user_profiles', 'major_categories')
ORDER BY tablename, policyname;

-- عرض إحصائيات الجداول
SELECT 
  'vendors' as table_name,
  COUNT(*) as total_records,
  COUNT(CASE WHEN organization_activated = true THEN 1 END) as active_vendors,
  COUNT(CASE WHEN organization_deleted = false THEN 1 END) as non_deleted_vendors
FROM vendors
UNION ALL
SELECT 
  'major_categories' as table_name,
  COUNT(*) as total_records,
  COUNT(CASE WHEN status = 1 THEN 1 END) as active_categories,
  COUNT(CASE WHEN is_featured = true THEN 1 END) as featured_categories
FROM major_categories;

-- ==============================================
-- 11. ملاحظات مهمة
-- ==============================================

/*
ملاحظات للاستخدام:

1. تأكد من تشغيل هذا السكريبت في Supabase SQL Editor
2. تحقق من أن جميع السياسات تم إنشاؤها بنجاح
3. اختبر الوظائف في التطبيق بعد التحديث
4. راقب سجلات الأخطاء في Supabase Dashboard
5. تأكد من أن المستخدمين يمكنهم الوصول للبيانات المطلوبة

Notes for usage:

1. Make sure to run this script in Supabase SQL Editor
2. Verify that all policies were created successfully
3. Test the functions in the app after the update
4. Monitor error logs in Supabase Dashboard
5. Ensure users can access the required data
*/


