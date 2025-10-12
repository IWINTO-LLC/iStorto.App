# دليل إعداد Deep Links - Istorto App
# Deep Links Setup Guide

---

**📅 التاريخ:** October 11, 2025  
**✅ الحالة:** Complete  
**🎯 الهدف:** تفعيل فتح التطبيق من الروابط المشاركة

---

## 🎯 ما هي Deep Links؟

Deep Links تسمح بفتح التطبيق مباشرة عند النقر على رابط مشارك، بدلاً من فتح المتصفح.

### مثال:
```
❌ بدون Deep Links: 
   الرابط → المتصفح → صفحة ويب

✅ مع Deep Links:
   الرابط → التطبيق → صفحة المنتج مباشرة
```

---

## 📋 الملفات المُنشأة والمُحدثة

### ✅ ملفات جديدة:
1. **`lib/services/deep_link_service.dart`** - خدمة معالجة الروابط العميقة

### ✅ ملفات محدثة:
1. **`android/app/src/main/AndroidManifest.xml`** - إعداد Android Deep Links
2. **`lib/main.dart`** - تهيئة Deep Link Service
3. **`pubspec.yaml`** - إضافة uni_links package
4. **`lib/featured/product/controllers/product_controller.dart`** - تحديث getProductById

---

## 🔧 التحديثات في Android

### AndroidManifest.xml:

```xml
<!-- Deep Links للمنتجات -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data
        android:scheme="https"
        android:host="istorto.com"
        android:pathPrefix="/product" />
    <data
        android:scheme="http"
        android:host="istorto.com"
        android:pathPrefix="/product" />
</intent-filter>

<!-- Deep Links للمتاجر -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data
        android:scheme="https"
        android:host="istorto.com"
        android:pathPrefix="/vendor" />
    <data
        android:scheme="http"
        android:host="istorto.com"
        android:pathPrefix="/vendor" />
</intent-filter>

<!-- Custom URL Scheme (اختياري) -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data android:scheme="istoreto" />
</intent-filter>
```

---

## 📱 كيفية العمل

### سيناريو 1: مشاركة منتج

```
1. المستخدم A يشارك منتج
   ↓
2. يرسل الرابط: https://istorto.com/product/product-123
   ↓
3. المستخدم B يضغط على الرابط
   ↓
4. التطبيق يفتح تلقائياً
   ↓
5. DeepLinkService يعالج الرابط
   ↓
6. يفتح صفحة تفاصيل المنتج مباشرة
```

### سيناريو 2: مشاركة متجر

```
1. المستخدم A يشارك متجر
   ↓
2. يرسل الرابط: https://istorto.com/vendor/vendor-456
   ↓
3. المستخدم B يضغط على الرابط
   ↓
4. التطبيق يفتح تلقائياً
   ↓
5. DeepLinkService يعالج الرابط
   ↓
6. يفتح صفحة المتجر مباشرة
```

---

## 💻 التحديثات في Flutter

### 1. Deep Link Service (`deep_link_service.dart`):

```dart
class DeepLinkService {
  // تهيئة الخدمة
  Future<void> initialize() async {
    // معالجة الرابط الأولي (عند فتح التطبيق)
    final initialLink = await getInitialLink();
    
    // الاستماع للروابط الجديدة (عند التطبيق مفتوح)
    _linkSubscription = linkStream.listen((link) {
      _handleDeepLink(link);
    });
  }

  // معالجة الروابط
  Future<void> _handleDeepLink(String link) async {
    final uri = Uri.parse(link);
    
    if (uri.pathSegments[0] == 'product') {
      await _handleProductLink(uri.pathSegments);
    } else if (uri.pathSegments[0] == 'vendor') {
      await _handleVendorLink(uri.pathSegments);
    }
  }
}
```

### 2. تهيئة في main.dart:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... تهيئات أخرى
  
  // تهيئة Deep Link Service
  await DeepLinkService().initialize();
  
  runApp(const MyApp());
}
```

---

## 🧪 الاختبار

### اختبار على Android:

#### الطريقة 1: استخدام ADB

```bash
# اختبار رابط منتج
adb shell am start -W -a android.intent.action.VIEW -d "https://istorto.com/product/test-123" com.istoreto.app

# اختبار رابط متجر
adb shell am start -W -a android.intent.action.VIEW -d "https://istorto.com/vendor/vendor-456" com.istoreto.app

# اختبار Custom Scheme
adb shell am start -W -a android.intent.action.VIEW -d "istoreto://product/test-123" com.istoreto.app
```

#### الطريقة 2: من Messaging Apps

```
1. شغّل التطبيق على الهاتف
2. أرسل رابط لنفسك عبر WhatsApp/Telegram
3. اضغط على الرابط
4. التطبيق يجب أن يفتح مباشرة
```

#### الطريقة 3: من المتصفح

```
1. افتح Chrome على الهاتف
2. اكتب في Address Bar: https://istorto.com/product/test-123
3. اضغط Enter
4. اختر "Open in Istoreto App"
```

---

## 🔍 Debugging

### في Console سترى:

```
✅ Deep Link Service initialized
🔗 Deep Link received: https://istorto.com/product/test-123
   Host: istorto.com
   Path: /product/test-123
📦 Opening product: test-123
✅ Navigated to product: Product Name
```

### إذا لم يعمل:

```
❌ Deep Link Error: ...
⚠️ Invalid host: ...
⚠️ Invalid product link format
⚠️ Unknown path: ...
```

---

## 📊 أنواع الروابط المدعومة

### 1. روابط المنتجات:

```
✅ https://istorto.com/product/{product_id}
✅ http://istorto.com/product/{product_id}
✅ istoreto://product/{product_id}
```

### 2. روابط المتاجر:

```
✅ https://istorto.com/vendor/{vendor_id}
✅ http://istorto.com/vendor/{vendor_id}
✅ istoreto://vendor/{vendor_id}
```

---

## 🌐 إعداد Domain (مطلوب للإنتاج)

### لتفعيل Universal Links، تحتاج لملف `assetlinks.json`:

#### 1. إنشاء الملف:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.istoreto.app",
    "sha256_cert_fingerprints": [
      "YOUR_SHA256_FINGERPRINT_HERE"
    ]
  }
}]
```

#### 2. رفع الملف إلى:

```
https://istorto.com/.well-known/assetlinks.json
```

#### 3. الحصول على SHA256 Fingerprint:

```bash
# للتطوير (Debug)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# للإنتاج (Release)
keytool -list -v -keystore /path/to/your-release-key.jks -alias your-key-alias
```

---

## 🍎 إعداد iOS (اختياري)

### Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.istoreto.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>istoreto</string>
        </array>
    </dict>
</array>

<!-- Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:istorto.com</string>
</array>
```

### apple-app-site-association:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.istoreto.app",
        "paths": [
          "/product/*",
          "/vendor/*"
        ]
      }
    ]
  }
}
```

رفع إلى: `https://istorto.com/.well-known/apple-app-site-association`

---

## ⚠️ ملاحظات هامة

### 1. Domain Verification:

```
❗ يجب أن يكون لديك SSL Certificate صالح
❗ يجب رفع assetlinks.json على نطاقك
❗ يستغرق Android 24 ساعة للتحقق من الـ Domain
```

### 2. Testing:

```
✅ Custom Schemes (istoreto://) تعمل فوراً
⏳ Universal Links (https://istorto.com) تحتاج domain verification
```

### 3. Fallback:

```
إذا فشل فتح التطبيق → يفتح المتصفح
لذلك يُفضل إنشاء صفحات Web للروابط
```

---

## 🎯 سيناريوهات الاستخدام

### 1. المستخدم لم يثبت التطبيق:

```
الرابط → المتصفح → صفحة ويب تعرض:
   - معلومات المنتج/المتجر
   - زر "Download App"
   - رابط Google Play / App Store
```

### 2. المستخدم ثبت التطبيق:

```
الرابط → التطبيق يفتح مباشرة → الصفحة المطلوبة
```

### 3. المستخدم لديه التطبيق لكنه مغلق:

```
الرابط → التطبيق يفتح → Deep Link Service يعالج الرابط → الصفحة المطلوبة
```

### 4. المستخدم لديه التطبيق وهو مفتوح:

```
الرابط → التطبيق يستقبل الرابط → Navigation مباشرة للصفحة
```

---

## 📈 التحسينات المستقبلية

### يمكن إضافة:

1. **Analytics:**
```dart
// تتبع فتح التطبيق من Deep Links
await FirebaseAnalytics.instance.logEvent(
  name: 'deep_link_opened',
  parameters: {'link_type': 'product', 'product_id': id},
);
```

2. **Deferred Deep Links:**
```
المستخدم يضغط الرابط → يُحمل التطبيق → يثبته → يفتح على الصفحة المطلوبة
```

3. **Dynamic Links:**
```
استخدام Firebase Dynamic Links للتحكم المتقدم
```

4. **Web Fallback Pages:**
```html
<!-- https://istorto.com/product/123 -->
<!DOCTYPE html>
<html>
<head>
    <title>Product Name - Istorto</title>
    <meta property="al:android:url" content="istoreto://product/123" />
    <meta property="al:android:package" content="com.istoreto.app" />
    <meta property="al:android:app_name" content="Istorto" />
</head>
<body>
    <!-- Product info + App Store links -->
</body>
</html>
```

---

## ✅ قائمة التحقق

### إعداد Android:
- [x] تحديث AndroidManifest.xml
- [x] إضافة intent-filters للمنتجات
- [x] إضافة intent-filters للمتاجر
- [x] إضافة Custom Scheme

### إعداد Flutter:
- [x] إنشاء DeepLinkService
- [x] تهيئة في main.dart
- [x] إضافة uni_links package
- [x] تحديث getProductById

### الاختبار:
- [ ] اختبار على Android Device
- [ ] اختبار Custom Scheme
- [ ] اختبار من WhatsApp/Telegram
- [ ] اختبار من المتصفح

### الإنتاج:
- [ ] الحصول على SHA256 Fingerprint
- [ ] إنشاء assetlinks.json
- [ ] رفع على https://istorto.com/.well-known/
- [ ] انتظار Domain Verification (24 ساعة)

---

## 🎉 الخلاصة

### تم تنفيذ:
✅ **Deep Links للمنتجات والمتاجر**
✅ **معالجة الروابط تلقائياً**
✅ **Navigation مباشرة للصفحات**
✅ **رسائل خطأ واضحة**
✅ **Logging شامل للـ Debugging**

### النتيجة:
🎊 **عند مشاركة رابط، التطبيق سيفتح مباشرة على الصفحة المطلوبة!**

---

## 📚 مراجع

- [Android App Links](https://developer.android.com/training/app-links)
- [uni_links Package](https://pub.dev/packages/uni_links)
- [Deep Linking Best Practices](https://developer.android.com/training/app-links/deep-linking)

---

**🚀 Deep Links جاهزة للاستخدام!**

**⚠️ ملاحظة:** للعمل الكامل في الإنتاج، تحتاج لإعداد Domain Verification.


