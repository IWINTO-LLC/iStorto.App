-- إنشاء جدول user_profiles
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

-- إنشاء فهرس للبريد الإلكتروني
CREATE INDEX idx_user_profiles_email ON user_profiles(email);

-- إنشاء فهرس للاسم المستخدم
CREATE INDEX idx_user_profiles_username ON user_profiles(username);

-- إنشاء فهرس للتاريخ
CREATE INDEX idx_user_profiles_created_at ON user_profiles(created_at);

-- تفعيل Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- سياسة الأمان: المستخدمون يمكنهم رؤية وتحديث ملفاتهم الشخصية فقط
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء trigger لتحديث updated_at
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- إدراج بيانات تجريبية (اختياري)
INSERT INTO user_profiles (id, email, name, username, is_active, email_verified) 
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'admin@istoreto.com', 'Admin User', 'admin', true, true),
  ('00000000-0000-0000-0000-000000000002', 'test@istoreto.com', 'Test User', 'testuser', true, false);
