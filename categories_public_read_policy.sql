-- سكريبت لإعطاء صلاحية القراءة لجميع المستخدمين في جدول categories

-- 1. إزالة السياسات الموجودة (إن وجدت)
DROP POLICY IF EXISTS "Categories are viewable by everyone" ON categories;
DROP POLICY IF EXISTS "Users can view categories" ON categories;
DROP POLICY IF EXISTS "Public read access" ON categories;

-- 2. تفعيل Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 3. إنشاء سياسة القراءة العامة
CREATE POLICY "Public read access to categories" ON categories
  FOR SELECT USING (true);

-- 4. اختبار السياسة
SELECT * FROM categories LIMIT 5;

-- 5. فحص السياسات الموجودة
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'categories';
