-- سكريبت لتحديث إعدادات Supabase لإلغاء التحقق من الإيميل

-- 1. تحديث جميع المستخدمين الموجودين ليصبحوا مؤكدين
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- 2. تحديث user_profiles لتعيين email_verified = true
UPDATE user_profiles 
SET email_verified = true 
WHERE email_verified = false;

-- 3. فحص المستخدمين المحدثين
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 10;

-- 4. فحص user_profiles المحدثة
SELECT 
  id,
  email,
  email_verified,
  created_at
FROM user_profiles 
ORDER BY created_at DESC 
LIMIT 10;

-- 5. إحصائيات
SELECT 
  'Total Users' as metric,
  COUNT(*) as count
FROM auth.users
UNION ALL
SELECT 
  'Confirmed Users' as metric,
  COUNT(*) as count
FROM auth.users 
WHERE email_confirmed_at IS NOT NULL
UNION ALL
SELECT 
  'Verified Profiles' as metric,
  COUNT(*) as count
FROM user_profiles 
WHERE email_verified = true;

-- 6. تحديث السياسات (إذا كانت تعتمد على التحقق من الإيميل)
-- إزالة السياسات القديمة
DROP POLICY IF EXISTS "Users can read own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;

-- إنشاء سياسات جديدة (بدون فحص التحقق من الإيميل)
CREATE POLICY "Users can read own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 7. فحص السياسات الجديدة
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'user_profiles'
ORDER BY policyname;

-- 8. اختبار الوصول
-- اختبار قراءة الملف الشخصي
SELECT * FROM user_profiles WHERE id = auth.uid();

-- 9. ملاحظة مهمة
-- تأكد من تعطيل "Enable email confirmations" في Supabase Dashboard
-- Authentication > Settings > Email Auth > Enable email confirmations = OFF
