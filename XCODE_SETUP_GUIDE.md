# دليل إعداد Apple Sign-In في Xcode

## الخطوات المطلوبة:

### 1. فتح المشروع في Xcode
```bash
# افتح Terminal واكتب:
cd ios
open Runner.xcworkspace
```

### 2. إعداد Signing & Capabilities
```
1. اختر "Runner" target من القائمة الجانبية
2. اذهب إلى تبويب "Signing & Capabilities"
3. تأكد من:
   - Team: اختر فريقك من Apple Developer
   - Bundle Identifier: com.istoreto.app
   - Automatically manage signing: مفعل
```

### 3. إضافة Sign In with Apple Capability
```
1. اضغط "+ Capability"
2. ابحث عن "Sign In with Apple"
3. أضفها
4. تأكد من حفظ المشروع
```

### 4. إعداد URL Schemes
```
1. اذهب إلى تبويب "Info"
2. أضف URL Scheme جديد:
   - Identifier: apple-signin
   - URL Schemes: io.supabase.flutterquickstart
```

## ملاحظات مهمة:
- ⚠️ يجب أن تكون على جهاز Mac
- ⚠️ يجب أن يكون لديك Apple Developer Account
- ⚠️ Bundle ID يجب أن يطابق الموجود في Apple Developer Portal
