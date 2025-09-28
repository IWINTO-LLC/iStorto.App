-- سكريبت اختبار إرسال البريد الإلكتروني في Supabase

-- 1. اختبار إرسال بريد التحقق
SELECT auth.send_confirmation_email('test@example.com');

-- 2. اختبار إرسال بريد إعادة تعيين كلمة المرور
SELECT auth.send_password_reset_email('test@example.com');

-- 3. اختبار إرسال بريد تغيير البريد الإلكتروني
SELECT auth.send_email_change_email('test@example.com', 'newemail@example.com');

-- 4. فحص إعدادات البريد الإلكتروني
SELECT 
  raw_app_meta_data->>'email_confirm' as email_confirm_enabled,
  raw_app_meta_data->>'email_change' as email_change_enabled
FROM auth.users 
LIMIT 1;

-- 5. فحص المستخدمين غير المفعلين
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;

-- 6. فحص آخر محاولات إرسال البريد
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at
FROM auth.users 
ORDER BY created_at DESC
LIMIT 10;

-- 7. اختبار إنشاء مستخدم جديد (لاختبار التسجيل)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'test@example.com',
  crypt('password123', gen_salt('bf')),
  NULL, -- غير مفعل
  NOW(),
  NOW(),
  encode(gen_random_bytes(32), 'base64'),
  '',
  '',
  encode(gen_random_bytes(32), 'base64')
);

-- 8. إرسال بريد التحقق للمستخدم الجديد
SELECT auth.send_confirmation_email('test@example.com');

-- 9. فحص حالة المستخدم
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'test@example.com';
