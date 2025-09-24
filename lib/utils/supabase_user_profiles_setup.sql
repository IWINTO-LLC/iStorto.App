-- إنشاء جدول user_profiles بدلاً من users لتجنب التعارض مع auth.users
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT UNIQUE NOT NULL, -- معرف Firebase/Supabase Auth
  username TEXT UNIQUE,
  name TEXT NOT NULL DEFAULT '',
  email TEXT UNIQUE,
  phone_number TEXT,
  profile_image TEXT DEFAULT '',
  bio TEXT DEFAULT '',
  brief TEXT DEFAULT '',
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- تفعيل Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسة للسماح للمستخدمين بقراءة وإدراج ملفاتهم الشخصية
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid()::text = user_id);

-- إنشاء دالة لإنشاء ملف شخصي تلقائياً عند تسجيل مستخدم جديد
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, email, name, email_verified)
  VALUES (new.id::text, new.email, COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)), new.email_confirmed_at IS NOT NULL);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إنشاء trigger لاستدعاء الدالة عند إدراج مستخدم جديد
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
