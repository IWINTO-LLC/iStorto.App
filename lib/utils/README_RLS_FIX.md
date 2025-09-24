# حل مشكلة Row Level Security (RLS) في Supabase

## المشكلة
عند محاولة إنشاء حساب جديد، يظهر الخطأ:
```
new row violates row level security policy for table users, code 42501 unauthorized
```

## الحلول المتاحة

### الحل الأول: تعطيل RLS مؤقتاً (للاختبار فقط)
```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

### الحل الثاني: إنشاء سياسة أكثر مرونة
```sql
-- تفعيل RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسة للسماح بإنشاء الملفات الشخصية
CREATE POLICY "Allow user profile creation" ON users
  FOR INSERT 
  WITH CHECK (true);

-- إنشاء سياسة للسماح للمستخدمين بقراءة بياناتهم
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = user_id);

-- إنشاء سياسة للسماح للمستخدمين بتحديث بياناتهم
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = user_id);
```

### الحل الثالث: استخدام Trigger تلقائي (الأفضل)
```sql
-- إنشاء دالة لإنشاء الملف الشخصي تلقائياً
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO users (user_id, email, name, username, is_active, email_verified, phone_verified)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    COALESCE(new.raw_user_meta_data->>'user_name', split_part(new.email, '@', 1)),
    true,
    new.email_confirmed_at IS NOT NULL,
    false
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إنشاء trigger على جدول auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();
```

### الحل الرابع: استخدام RPC Function
```sql
-- إنشاء دالة RPC لإنشاء الملف الشخصي
CREATE OR REPLACE FUNCTION create_user_profile(
  user_id UUID,
  user_email TEXT,
  user_phone TEXT DEFAULT NULL,
  user_name TEXT DEFAULT NULL,
  user_username TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  INSERT INTO users (
    user_id,
    email,
    phone_number,
    name,
    username,
    is_active,
    email_verified,
    phone_verified,
    created_at,
    updated_at
  ) VALUES (
    user_id,
    user_email,
    user_phone,
    COALESCE(user_name, split_part(user_email, '@', 1)),
    COALESCE(user_username, split_part(user_email, '@', 1)),
    true,
    false,
    false,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    phone_number = EXCLUDED.phone_number,
    name = EXCLUDED.name,
    username = EXCLUDED.username,
    updated_at = NOW()
  RETURNING to_json(users.*) INTO result;
  
  RETURN result;
END;
$$;

-- منح صلاحيات التنفيذ
GRANT EXECUTE ON FUNCTION create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;
```

## خطوات التطبيق

1. **افتح Supabase Dashboard**
2. **اذهب إلى SQL Editor**
3. **انسخ والصق أحد الحلول أعلاه**
4. **اضغط على Run**

## التوصية

يُنصح باستخدام **الحل الثالث (Trigger تلقائي)** لأنه:
- آمن
- تلقائي
- لا يتطلب تعديل في الكود
- يضمن إنشاء الملف الشخصي لكل مستخدم جديد

## ملاحظات مهمة

- لا تستخدم تعطيل RLS في الإنتاج
- تأكد من اختبار الحلول قبل التطبيق
- احتفظ بنسخة احتياطية من قاعدة البيانات
