# إعداد Apple Sign-In في Supabase

## الخطوات المطلوبة:

### 1. الذهاب إلى Supabase Dashboard
```
1. اذهب إلى: https://app.supabase.com/
2. اختر مشروعك
3. اذهب إلى Authentication > Providers
```

### 2. تفعيل Apple Provider
```
1. ابحث عن "Apple" في قائمة Providers
2. اضغط على أيقونة Apple
3. فعّل "Enable sign in with Apple"
```

### 3. إضافة المعلومات المطلوبة
```
Apple Client ID: com.istoreto.app
Apple Team ID: [احصل عليه من Apple Developer Portal]
Apple Key ID: [احصل عليه من Apple Developer Portal]
Apple Private Key: [احصل عليه من Apple Developer Portal]
```

### 4. الحصول على Team ID
```
1. اذهب إلى Apple Developer Portal
2. اضغط على اسمك في الأعلى
3. انسخ "Team ID"
```

### 5. إنشاء Apple Private Key
```
1. في Apple Developer Portal:
   - اذهب إلى "Keys"
   - اضغط "+" لإنشاء مفتاح جديد
   - اسم: "Supabase Apple Sign-In"
   - فعّل "Sign In with Apple"
   - اضغط "Continue" ثم "Register"
   - حمّل المفتاح (.p8 file)
   - انسخ Key ID
```

### 6. إضافة Redirect URLs
```
أضف هذه URLs في Supabase:
- io.supabase.flutterquickstart://login-callback
- https://jfveosdooutphhjyvcis.supabase.co/auth/v1/callback
```

## معلومات مهمة:
- Bundle ID: com.istoreto.app
- Redirect URL: io.supabase.flutterquickstart://login-callback
