-- سكريبت لإنشاء جدول vendors

-- 1. إنشاء جدول vendors
CREATE TABLE IF NOT EXISTS vendors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_name VARCHAR(255) NOT NULL,
  organization_bio TEXT,
  banner_image TEXT,
  organization_logo TEXT,
  organization_cover TEXT,
  website VARCHAR(255),
  slugn VARCHAR(100) UNIQUE NOT NULL,
  exclusive_id VARCHAR(100),
  store_message TEXT,
  in_exclusive BOOLEAN DEFAULT false,
  is_subscriber BOOLEAN DEFAULT false,
  is_verified BOOLEAN DEFAULT false,
  is_royal BOOLEAN DEFAULT false,
  enable_iwinto_payment BOOLEAN DEFAULT false,
  enable_cod BOOLEAN DEFAULT false,
  organization_deleted BOOLEAN DEFAULT false,
  organization_activated BOOLEAN DEFAULT true,
  default_currency VARCHAR(3) DEFAULT 'USD',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. إضافة عمود account_type إلى جدول user_profiles
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS account_type INTEGER DEFAULT 0;

-- 3. إنشاء فهرس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_vendors_user_id ON vendors(user_id);
CREATE INDEX IF NOT EXISTS idx_vendors_slugn ON vendors(slugn);
CREATE INDEX IF NOT EXISTS idx_vendors_organization_name ON vendors(organization_name);

-- 4. تفعيل Row Level Security
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- 5. إنشاء سياسات الأمان
-- المستخدمون يمكنهم رؤية البائعين النشطين
CREATE POLICY "Vendors are viewable by everyone" ON vendors
  FOR SELECT USING (organization_activated = true AND organization_deleted = false);

-- المستخدمون يمكنهم إدارة بائعهم الخاص
CREATE POLICY "Users can manage their own vendor" ON vendors
  FOR ALL USING (auth.uid() = user_id);

-- 6. إنشاء دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_vendors_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. إنشاء trigger لتحديث updated_at
DROP TRIGGER IF EXISTS update_vendors_updated_at_trigger ON vendors;
CREATE TRIGGER update_vendors_updated_at_trigger
  BEFORE UPDATE ON vendors
  FOR EACH ROW
  EXECUTE FUNCTION update_vendors_updated_at();

-- 8. إدراج بيانات تجريبية (اختياري)
INSERT INTO vendors (
  user_id,
  organization_name,
  organization_bio,
  slugn,
  organization_activated,
  default_currency
) VALUES (
  (SELECT id FROM auth.users LIMIT 1), -- استبدل بـ user_id حقيقي
  'Sample Organization',
  'This is a sample organization for testing',
  'sample-org',
  true,
  'USD'
) ON CONFLICT (slugn) DO NOTHING;

-- 9. فحص الجدول
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'vendors' 
ORDER BY ordinal_position;

-- 10. فحص السياسات
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'vendors';
