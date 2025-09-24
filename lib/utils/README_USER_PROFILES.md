# إعداد جدول User Profiles في Supabase

## 📋 **التغيير المطلوب:**

تم تغيير اسم الجدول من `users` إلى `user_profiles` لتجنب التعارض مع الجدول الأساسي `auth.users` في Supabase.

## 🗄️ **الخطوات المطلوبة:**

### **1. تشغيل SQL في Supabase Dashboard:**

```sql
-- انسخ والصق محتوى الملف:
-- lib/utils/supabase_user_profiles_setup.sql
```

### **2. أو تشغيل الأوامر يدوياً:**

#### **أ) حذف الجدول القديم (إذا كان موجود):**
```sql
DROP TABLE IF EXISTS users CASCADE;
```

#### **ب) إنشاء الجدول الجديد:**
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT UNIQUE NOT NULL,
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
```

#### **ج) تفعيل RLS:**
```sql
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
```

#### **د) إنشاء السياسات:**
```sql
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid()::text = user_id);
```

#### **هـ) إنشاء الدالة والـ Trigger:**
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, email, name, email_verified)
  VALUES (new.id::text, new.email, COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)), new.email_confirmed_at IS NOT NULL);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

## ✅ **المميزات:**

### **1. تجنب التعارض:**
- لا يتعارض مع `auth.users` الأساسي
- أسماء واضحة ومميزة

### **2. الأمان:**
- Row Level Security مفعل
- سياسات محددة للمستخدمين

### **3. التلقائية:**
- إنشاء ملف شخصي تلقائياً عند التسجيل
- تحديث حالة التوثيق تلقائياً

## 🔄 **البيانات الموجودة:**

إذا كان لديك بيانات في الجدول القديم:
```sql
-- نسخ البيانات من الجدول القديم
INSERT INTO user_profiles (user_id, email, name, phone_number, profile_image, bio, brief, is_active, email_verified, phone_verified, created_at, updated_at)
SELECT user_id, email, name, phone_number, profile_image, bio, brief, is_active, email_verified, phone_verified, created_at, updated_at
FROM users;
```

## 🎯 **النتيجة:**

بعد تطبيق هذه التغييرات:
- ✅ لا توجد تعارضات مع الجداول الأساسية
- ✅ أسماء واضحة ومهنية
- ✅ أمان محسن
- ✅ إنشاء تلقائي للملفات الشخصية
