# دليل إعداد البريد الإلكتروني في Supabase

## المشاكل الشائعة مع إرسال البريد الإلكتروني

### 1. البريد الإلكتروني لا يصل
### 2. البريد يذهب إلى مجلد Spam
### 3. رسائل خطأ عند الإرسال

## الإعدادات المطلوبة في Supabase

### 1. تفعيل Email Confirmation

**الخطوات:**
1. اذهب إلى Supabase Dashboard
2. اختر مشروعك
3. اذهب إلى **Authentication** → **Settings**
4. في قسم **User Signups**:
   - ✅ **Enable email confirmations**
   - ✅ **Enable email change confirmations**

### 2. إعداد Site URL و Redirect URLs

**الخطوات:**
1. اذهب إلى **Authentication** → **URL Configuration**
2. تأكد من الإعدادات التالية:

```
Site URL: io.supabase.flutterquickstart://

Redirect URLs:
- io.supabase.flutterquickstart://login-callback
- io.supabase.flutterquickstart://reset-password
- io.supabase.flutterquickstart://email-verification
```

### 3. إعداد SMTP (مُوصى به)

**الخيار 1: استخدام SMTP خارجي (مُوصى به)**

1. اذهب إلى **Authentication** → **Settings** → **SMTP Settings**
2. فعّل **Enable custom SMTP**
3. أضف إعدادات SMTP:

**لـ Gmail:**
```
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP User: your-email@gmail.com
SMTP Pass: your-app-password
SMTP Admin Email: your-email@gmail.com
SMTP Sender Name: Your App Name
```

**لـ SendGrid:**
```
SMTP Host: smtp.sendgrid.net
SMTP Port: 587
SMTP User: apikey
SMTP Pass: your-sendgrid-api-key
SMTP Admin Email: your-email@domain.com
SMTP Sender Name: Your App Name
```

**لـ Mailgun:**
```
SMTP Host: smtp.mailgun.org
SMTP Port: 587
SMTP User: postmaster@your-domain.mailgun.org
SMTP Pass: your-mailgun-password
SMTP Admin Email: your-email@domain.com
SMTP Sender Name: Your App Name
```

### 4. تخصيص قوالب البريد الإلكتروني

**الخطوات:**
1. اذهب إلى **Authentication** → **Email Templates**
2. اختر القالب المطلوب (Confirm signup, Reset password, etc.)
3. اضغط **Edit**
4. أضف `{{ .ConfirmationURL }}` في المكان المناسب
5. احفظ التغييرات

**مثال لقالب Confirm signup:**
```html
<h2>Confirm your signup</h2>
<p>Follow this link to confirm your user:</p>
<p><a href="{{ .ConfirmationURL }}">Confirm your email</a></p>
```

### 5. إعدادات إضافية مهمة

**Rate Limiting:**
1. اذهب إلى **Authentication** → **Settings**
2. في قسم **Rate Limiting**:
   - تأكد من أن القيم معقولة (مثل 10 emails per hour)

**Email Security:**
1. تأكد من تفعيل **Enable email confirmations**
2. تأكد من تفعيل **Enable email change confirmations**

## اختبار إعدادات البريد الإلكتروني

### 1. اختبار من SQL Editor

```sql
-- اختبار إرسال بريد التحقق
SELECT auth.send_confirmation_email('test@example.com');

-- اختبار إرسال بريد إعادة تعيين كلمة المرور
SELECT auth.send_password_reset_email('test@example.com');
```

### 2. اختبار من التطبيق

1. جرب التسجيل بحساب جديد
2. تحقق من وصول البريد الإلكتروني
3. جرب "نسيان كلمة المرور"
4. تحقق من وصول بريد إعادة التعيين

### 3. فحص Logs

1. اذهب إلى **Logs** → **Auth**
2. ابحث عن رسائل الخطأ المتعلقة بالبريد الإلكتروني
3. تحقق من حالة الإرسال

## استكشاف الأخطاء

### المشكلة: البريد لا يصل
**الحلول:**
1. تحقق من مجلد Spam
2. تأكد من تفعيل Email Confirmation
3. تحقق من إعدادات SMTP
4. تأكد من صحة Site URL

### المشكلة: رسالة خطأ "Rate limit exceeded"
**الحلول:**
1. انتظر ساعة واحدة
2. تحقق من إعدادات Rate Limiting
3. استخدم SMTP خارجي

### المشكلة: رسالة خطأ "Invalid redirect URL"
**الحلول:**
1. تأكد من إضافة Redirect URLs الصحيحة
2. تأكد من عدم وجود `/` في نهاية الروابط
3. تأكد من تطابق الروابط في الكود

### المشكلة: رسالة خطأ "SMTP authentication failed"
**الحلول:**
1. تحقق من صحة بيانات SMTP
2. تأكد من تفعيل "Less secure app access" في Gmail
3. استخدم App Password بدلاً من كلمة المرور العادية

## نصائح مهمة

### 1. استخدام App Password مع Gmail
1. اذهب إلى Google Account Settings
2. Security → 2-Step Verification → App passwords
3. أنشئ App Password جديد
4. استخدمه في إعدادات SMTP

### 2. إعداد Domain Authentication
1. أضف SPF record في DNS
2. أضف DKIM record في DNS
3. أضف DMARC record في DNS

### 3. مراقبة إحصائيات البريد
1. استخدم خدمات مثل SendGrid أو Mailgun
2. راقب معدل التسليم
3. راقب معدل الفتح

## اختبار شامل

### 1. اختبار التسجيل
```bash
# جرب التسجيل بحساب جديد
# تحقق من وصول بريد التحقق
# اضغط على الرابط
# تأكد من تفعيل الحساب
```

### 2. اختبار نسيان كلمة المرور
```bash
# جرب نسيان كلمة المرور
# تحقق من وصول بريد إعادة التعيين
# اضغط على الرابط
# تأكد من إعادة تعيين كلمة المرور
```

### 3. اختبار تغيير البريد الإلكتروني
```bash
# جرب تغيير البريد الإلكتروني
# تحقق من وصول بريد التحقق
# اضغط على الرابط
# تأكد من تحديث البريد الإلكتروني
```

## الدعم

إذا استمرت المشاكل:
1. تحقق من Console logs في التطبيق
2. تحقق من Auth logs في Supabase
3. تحقق من إعدادات SMTP
4. جرب استخدام SMTP خارجي
