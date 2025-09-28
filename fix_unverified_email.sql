-- سكريبت لحل مشكلة البريد الإلكتروني غير المؤكد

-- 1. فحص المستخدمين غير المؤكدين
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;

-- 2. تأكيد البريد الإلكتروني يدوياً (استبدل البريد ببريدك)
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email = 'your-email@example.com';

-- 3. إنشاء ملف شخصي للمستخدم إذا لم يكن موجود
INSERT INTO user_profiles (
  id,
  user_id,
  email,
  name,
  username,
  is_active,
  email_verified,
  phone_verified,
  created_at,
  updated_at
)
SELECT 
  u.id,
  u.id,
  u.email,
  split_part(u.email, '@', 1),
  split_part(u.email, '@', 1),
  true,
  u.email_confirmed_at IS NOT NULL,
  false,
  NOW(),
  NOW()
FROM auth.users u
WHERE u.email = 'your-email@example.com'
AND NOT EXISTS (
  SELECT 1 FROM user_profiles up 
  WHERE up.user_id = u.id
);

-- 4. فحص النتيجة
SELECT 
  u.id,
  u.email,
  u.email_confirmed_at,
  up.name,
  up.email_verified
FROM auth.users u
LEFT JOIN user_profiles up ON u.id = up.user_id
WHERE u.email = 'your-email@example.com';

-- 5. إذا كنت تريد حذف المستخدم وإعادة التسجيل
-- DELETE FROM auth.users WHERE email = 'your-email@example.com';
-- DELETE FROM user_profiles WHERE email = 'your-email@example.com';
