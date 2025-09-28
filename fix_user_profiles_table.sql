-- سكريبت إصلاح جدول user_profiles

-- 1. حذف الجدول الموجود (إذا كان موجود)
DROP TABLE IF EXISTS user_profiles CASCADE;

-- 2. إنشاء الجدول بالهيكل الصحيح
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL, -- مرجع إلى auth.users
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  username TEXT UNIQUE,
  phone_number TEXT,
  profile_image TEXT,
  bio TEXT,
  brief TEXT,
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false,
  default_currency TEXT DEFAULT 'USD',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. إنشاء الفهارس
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_profiles_created_at ON user_profiles(created_at);

-- 4. تفعيل Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 5. إنشاء السياسات
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile" ON user_profiles
  FOR DELETE USING (auth.uid() = user_id);

-- 6. دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 7. إنشاء trigger لتحديث updated_at
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 8. اختبار الإدراج
INSERT INTO user_profiles (id, user_id, email, name, username, is_active) 
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  'test@example.com', 
  'Test User', 
  'testuser',
  true
);

-- 9. التحقق من البيانات
SELECT * FROM user_profiles;
