# دليل إعداد Supabase لمشروع iStoreto

## المشاكل التي تم إصلاحها

✅ **تم إصلاح مشكلة تسجيل الدخول بـ Google/Facebook/Apple**
- تم تحديث `redirectTo` URLs لتكون متوافقة مع Flutter
- تم إضافة معالجة أفضل للأخطاء

✅ **تم إصلاح مشكلة استعادة كلمة المرور**
- تم إضافة `redirectTo` URL لصفحة إعادة تعيين كلمة المرور
- تم تحسين رسائل الخطأ

✅ **تم إصلاح مشكلة تسجيل الدخول كضيف**
- تم إضافة دوال لسحب البيانات من قاعدة البيانات
- تم إضافة اختبار الاتصال بقاعدة البيانات

✅ **تم تحسين معالجة الأخطاء**
- رسائل خطأ أكثر وضوحاً
- معالجة أفضل لأخطاء الشبكة والتحقق من صحة البيانات

## إعدادات Supabase المطلوبة

### 1. إعداد البريد الإلكتروني (Email Settings)

اذهب إلى لوحة تحكم Supabase → Authentication → Settings → Email:

1. **تفعيل Email Confirmation:**
   - ✅ Enable email confirmations
   - ✅ Enable email change confirmations

2. **إعداد SMTP (اختياري ولكن مُوصى به):**
   - استخدم خدمة SMTP خارجية مثل SendGrid أو Mailgun
   - أو استخدم الإعدادات الافتراضية لـ Supabase

3. **تخصيص قوالب البريد الإلكتروني:**
   - Customize email templates
   - أضف redirect URLs الصحيحة

### 2. إعداد OAuth Providers

اذهب إلى Authentication → Providers:

#### Google OAuth:
1. ✅ Enable Google provider
2. أضف Client ID و Client Secret من Google Console
3. أضف Redirect URL: `io.supabase.flutterquickstart://login-callback/`

#### Facebook OAuth:
1. ✅ Enable Facebook provider  
2. أضف App ID و App Secret من Facebook Developers
3. أضف Redirect URL: `io.supabase.flutterquickstart://login-callback/`

#### Apple OAuth:
1. ✅ Enable Apple provider
2. أضف Service ID و Team ID من Apple Developer
3. أضف Redirect URL: `io.supabase.flutterquickstart://login-callback/`

### 3. إعداد Redirect URLs

اذهب إلى Authentication → URL Configuration:

**Site URL:**
```
io.supabase.flutterquickstart://
```

**Redirect URLs:**
```
io.supabase.flutterquickstart://login-callback
io.supabase.flutterquickstart://reset-password
io.supabase.flutterquickstart://email-verification
```

⚠️ **مهم:** تأكد من إزالة الشرطة المائلة `/` من نهاية الروابط في لوحة تحكم Supabase!

### 4. إعداد قاعدة البيانات

تأكد من وجود الجداول التالية:

#### جدول user_profiles:
```sql
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
```

#### جدول products (للمتجر):
```sql
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2),
  image_url TEXT,
  category_id UUID,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### جدول categories:
```sql
CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 5. إعداد Row Level Security (RLS)

```sql
-- تفعيل RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان للجدول user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- سياسات الأمان للجدول products (مفتوح للجميع)
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (is_active = true);

-- سياسات الأمان للجدول categories (مفتوح للجميع)
CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (is_active = true);
```

## اختبار التطبيق

### 1. اختبار التسجيل:
- جرب إنشاء حساب جديد
- تحقق من وصول بريد التحقق

### 2. اختبار تسجيل الدخول:
- جرب تسجيل الدخول بالبريد الإلكتروني
- جرب تسجيل الدخول بـ Google/Facebook/Apple

### 3. اختبار تسجيل الدخول كضيف:
- جرب تسجيل الدخول كضيف
- تحقق من ظهور المنتجات والفئات

### 4. اختبار استعادة كلمة المرور:
- جرب نسيان كلمة المرور
- تحقق من وصول بريد إعادة التعيين

## استكشاف الأخطاء

### إذا ظهر رابط localhost بدلاً من رابط التطبيق:
**المشكلة:** `http://localhost:3000/?code=...`

**الحل:**
1. اذهب إلى Supabase Dashboard → Authentication → URL Configuration
2. تأكد من أن **Site URL** هو: `io.supabase.flutterquickstart://`
3. تأكد من أن **Redirect URLs** تحتوي على:
   - `io.supabase.flutterquickstart://login-callback`
   - `io.supabase.flutterquickstart://reset-password`
   - `io.supabase.flutterquickstart://email-verification`
4. **مهم:** لا تضع `/` في نهاية الروابط!
5. احفظ التغييرات وانتظر دقيقة واحدة

### إذا لم تصل رسائل البريد الإلكتروني:
1. تحقق من مجلد Spam
2. تأكد من تفعيل Email Confirmation في Supabase
3. تحقق من إعدادات SMTP

### إذا فشل تسجيل الدخول بـ Google/Facebook/Apple:
1. تحقق من Client ID و Client Secret
2. تأكد من صحة Redirect URLs
3. تحقق من إعدادات OAuth في لوحة التحكم

### إذا لم تظهر البيانات عند تسجيل الدخول كضيف:
1. تحقق من وجود الجداول في قاعدة البيانات
2. تأكد من صحة RLS policies
3. تحقق من اتصال الإنترنت

## ملاحظات مهمة

- تأكد من تحديث `supabaseUrl` و `supabaseAnonKey` في `lib/utils/constants/constant.dart`
- اختبر التطبيق على أجهزة حقيقية وليس فقط المحاكي
- احتفظ بنسخة احتياطية من قاعدة البيانات
- راقب logs في لوحة تحكم Supabase لاستكشاف الأخطاء

## الدعم

إذا واجهت أي مشاكل، تحقق من:
1. Console logs في التطبيق
2. Network logs في لوحة تحكم Supabase
3. Authentication logs في Supabase
