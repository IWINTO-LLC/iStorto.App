# إعداد نظام المشاركة مع Supabase
# Supabase Share System Setup Guide

---

## 📋 نظرة عامة | Overview

تحويل نظام المشاركة من Firebase إلى Supabase يتطلب إعداد بنية URLs وسياسات الوصول في Supabase لدعم الروابط العميقة (Deep Links) ومشاركة المنتجات والمتاجر.

---

## 🎯 المتطلبات الحالية | Current Requirements

### الكود الموجود يعمل على:
```dart
1. مشاركة المنتج:
   - صورة المنتج (مضغوطة)
   - اسم المنتج
   - السعر بالعملة المحلية
   - رابط: https://istorto.com/product/{product_id}

2. مشاركة المتجر:
   - شعار المتجر
   - اسم المتجر
   - رابط: https://istorto.com/vendor/{vendor_id}
```

---

## 🔧 الخطوات المطلوبة في Supabase

### الخطوة 1️⃣: إنشاء جدول لتتبع المشاركات (اختياري ولكن موصى به)

```sql
-- إنشاء جدول لتتبع المشاركات
CREATE TABLE IF NOT EXISTS public.shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    share_type TEXT NOT NULL CHECK (share_type IN ('product', 'vendor')),
    entity_id TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    shared_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_type TEXT,
    share_method TEXT,
    
    -- Indexes
    CONSTRAINT shares_unique UNIQUE (share_type, entity_id, user_id, shared_at)
);

-- إنشاء فهارس للأداء
CREATE INDEX idx_shares_entity ON public.shares(share_type, entity_id);
CREATE INDEX idx_shares_user ON public.shares(user_id);
CREATE INDEX idx_shares_date ON public.shares(shared_at DESC);

-- تعليق على الجدول
COMMENT ON TABLE public.shares IS 'تتبع عمليات مشاركة المنتجات والمتاجر';
```

### الخطوة 2️⃣: إعداد RLS (Row Level Security) لجدول المشاركات

```sql
-- تفعيل RLS
ALTER TABLE public.shares ENABLE ROW LEVEL SECURITY;

-- سياسة: السماح لأي مستخدم بقراءة إحصائيات المشاركة
CREATE POLICY "Allow public read access to share counts"
ON public.shares
FOR SELECT
TO public
USING (true);

-- سياسة: السماح للمستخدمين المصادقين بإضافة مشاركات
CREATE POLICY "Allow authenticated users to insert shares"
ON public.shares
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- سياسة: السماح للمستخدمين برؤية مشاركاتهم فقط
CREATE POLICY "Users can view their own shares"
ON public.shares
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
```

### الخطوة 3️⃣: إنشاء دالة لتسجيل المشاركة

```sql
-- دالة لتسجيل عملية المشاركة
CREATE OR REPLACE FUNCTION public.log_share(
    p_share_type TEXT,
    p_entity_id TEXT,
    p_user_id UUID DEFAULT NULL,
    p_device_type TEXT DEFAULT NULL,
    p_share_method TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_share_id UUID;
BEGIN
    -- إدراج سجل المشاركة
    INSERT INTO public.shares (
        share_type,
        entity_id,
        user_id,
        device_type,
        share_method
    )
    VALUES (
        p_share_type,
        p_entity_id,
        COALESCE(p_user_id, auth.uid()),
        p_device_type,
        p_share_method
    )
    RETURNING id INTO v_share_id;
    
    RETURN v_share_id;
EXCEPTION
    WHEN OTHERS THEN
        -- تسجيل الخطأ وإرجاع NULL
        RAISE WARNING 'Error logging share: %', SQLERRM;
        RETURN NULL;
END;
$$;

-- تعليق على الدالة
COMMENT ON FUNCTION public.log_share IS 'تسجيل عملية مشاركة منتج أو متجر';
```

### الخطوة 4️⃣: إنشاء دالة لإحصاءات المشاركة

```sql
-- دالة للحصول على عدد المشاركات لمنتج أو متجر
CREATE OR REPLACE FUNCTION public.get_share_count(
    p_share_type TEXT,
    p_entity_id TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM public.shares
    WHERE share_type = p_share_type
      AND entity_id = p_entity_id;
    
    RETURN COALESCE(v_count, 0);
END;
$$;

-- دالة للحصول على أكثر المنتجات مشاركة
CREATE OR REPLACE FUNCTION public.get_most_shared_products(
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    product_id TEXT,
    share_count BIGINT,
    last_shared TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.entity_id AS product_id,
        COUNT(*) AS share_count,
        MAX(s.shared_at) AS last_shared
    FROM public.shares s
    WHERE s.share_type = 'product'
    GROUP BY s.entity_id
    ORDER BY share_count DESC, last_shared DESC
    LIMIT p_limit;
END;
$$;

-- دالة للحصول على أكثر المتاجر مشاركة
CREATE OR REPLACE FUNCTION public.get_most_shared_vendors(
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    vendor_id TEXT,
    share_count BIGINT,
    last_shared TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.entity_id AS vendor_id,
        COUNT(*) AS share_count,
        MAX(s.shared_at) AS last_shared
    FROM public.shares s
    WHERE s.share_type = 'vendor'
    GROUP BY s.entity_id
    ORDER BY share_count DESC, last_shared DESC
    LIMIT p_limit;
END;
$$;
```

### الخطوة 5️⃣: إضافة عمود لعدد المشاركات في جدول المنتجات (اختياري)

```sql
-- إضافة عمود share_count في جدول products
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;

-- إنشاء فهرس
CREATE INDEX IF NOT EXISTS idx_products_share_count 
ON public.products(share_count DESC);

-- إضافة عمود share_count في جدول vendors
ALTER TABLE public.vendors
ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;

-- إنشاء فهرس
CREATE INDEX IF NOT EXISTS idx_vendors_share_count 
ON public.vendors(share_count DESC);
```

### الخطوة 6️⃣: إنشاء Trigger لتحديث عدد المشاركات تلقائياً

```sql
-- دالة لتحديث عداد المشاركات
CREATE OR REPLACE FUNCTION public.update_share_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.share_type = 'product' THEN
        -- تحديث عداد المشاركات للمنتج
        UPDATE public.products
        SET share_count = share_count + 1
        WHERE id = NEW.entity_id;
    ELSIF NEW.share_type = 'vendor' THEN
        -- تحديث عداد المشاركات للمتجر
        UPDATE public.vendors
        SET id = NEW.entity_id
        AND share_count = share_count + 1;
    END IF;
    
    RETURN NEW;
END;
$$;

-- إنشاء Trigger
CREATE TRIGGER trigger_update_share_count
AFTER INSERT ON public.shares
FOR EACH ROW
EXECUTE FUNCTION public.update_share_count();
```

### الخطوة 7️⃣: إعداد Deep Links (الروابط العميقة)

#### أ) إنشاء دالة Edge Function للتعامل مع الروابط

```sql
-- إنشاء view للمنتجات الظاهرة في الروابط المشاركة
CREATE OR REPLACE VIEW public.product_share_view AS
SELECT 
    p.id,
    p.title,
    p.description,
    p.price,
    p.old_price,
    p.images,
    p.vendor_id,
    v.organization_name AS vendor_name,
    v.organization_logo AS vendor_logo,
    p.share_count
FROM public.products p
LEFT JOIN public.vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false;

-- السماح بالوصول العام للـ view
ALTER VIEW public.product_share_view OWNER TO postgres;
GRANT SELECT ON public.product_share_view TO anon, authenticated;
---from here stop
-- إنشاء view للمتاجر الظاهرة في الروابط المشاركة
CREATE OR REPLACE VIEW public.vendor_share_view AS
SELECT 
    v.id,
    v.user_id,
    v.organization_name,
    v.organization_logo,
    v.organization_cover,
    v.organization_bio,
    v.brief,
    v.share_count,
    COUNT(DISTINCT p.id) AS products_count,
    COUNT(DISTINCT uf.follower_id) AS followers_count
FROM public.vendors v
LEFT JOIN public.products p ON v.id = p.vendor_id AND p.is_deleted = false
LEFT JOIN public.user_follows uf ON v.id = uf.vendor_id
WHERE v.is_deleted = false
GROUP BY v.id, v.user_id, v.organization_name, v.organization_logo, 
         v.organization_cover, v.organization_bio, v.brief, v.share_count;

-- السماح بالوصول العام للـ view
ALTER VIEW public.vendor_share_view OWNER TO postgres;
GRANT SELECT ON public.vendor_share_view TO anon, authenticated;
```

---

## 📱 تحديث Flutter Code

### الخطوة 8️⃣: تحديث `share_services.dart`

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/formatters/formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareServices {
  /// مشاركة منتج
  static Future<void> shareProduct(ProductModel product) async {
    try {
      // تسجيل المشاركة في قاعدة البيانات أولاً
      await _logShare('product', product.id);

      // تحميل الصورة
      XFile? image;
      if (product.images.isNotEmpty) {
        try {
          final imageUrl = Uri.parse(product.images.first);
          final response = await http.get(imageUrl);
          
          if (response.statusCode == 200) {
            final compressedBytes = await FlutterImageCompress.compressWithList(
              response.bodyBytes,
              quality: 60,
              minWidth: 600,
              minHeight: 600,
            );

            // كتابة الصورة المضغوطة إلى ملف
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/${product.id}_compressed.jpg';
            final file = File(filePath);
            await file.writeAsBytes(compressedBytes);
            image = XFile(file.path);
          }
        } catch (imageError) {
          if (kDebugMode) print("Error loading product image: $imageError");
        }
      }

      // إنشاء رابط المنتج
      final link = Uri.parse("https://istorto.com/product/${product.id}");
      
      // حساب السعر بالعملة المحلية
      final price = TFormatter.formateNumber(
        CurrencyController.instance.convertToDefaultCurrency(product.price),
      );
      final currency = CurrencyController.instance.currentUserCurrency;

      // إنشاء رسالة المشاركة
      final message = '''
شاهد هذا المنتج!
${product.title}
السعر: $price $currency
$link
''';

      // مشاركة المنتج
      if (image != null) {
        await Share.shareXFiles([image], text: message.trim());
      } else {
        await Share.share(message.trim());
      }

      // تحديث عداد المشاركات محلياً (اختياري)
      await _incrementShareCount('product', product.id);
      
    } catch (e) {
      if (kDebugMode) print("shareProduct error: $e");
      rethrow;
    }
  }

  /// مشاركة متجر
  static Future<void> shareVendor(VendorModel vendor) async {
    try {
      // فحص البيانات الأساسية
      if (vendor.id.isEmpty) {
        throw Exception('معرف المتجر غير متوفر');
      }

      // تسجيل المشاركة في قاعدة البيانات
      await _logShare('vendor', vendor.id);

      XFile? image;
      final imageUrl = vendor.organizationLogo.isNotEmpty 
          ? vendor.organizationLogo 
          : null;

      // محاولة تحميل الصورة إذا كانت متوفرة
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/${vendor.id}_vendor.jpg';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            image = XFile(file.path);
          }
        } catch (imageError) {
          if (kDebugMode) print("Error loading vendor image: $imageError");
        }
      }

      // إنشاء رابط المتجر (استخدم vendor.id بدلاً من userId)
      final link = "https://istorto.com/vendor/${vendor.id}";
      final vendorName = vendor.organizationName.isNotEmpty 
          ? vendor.organizationName 
          : 'متجر';
      
      final message = '''
تعرّف على المتجر:
$vendorName

🌐 زوروا الحساب:
$link
''';

      // مشاركة المتجر
      if (image != null) {
        await Share.shareXFiles([image], text: message.trim());
      } else {
        await Share.share(message.trim());
      }

      // تحديث عداد المشاركات محلياً (اختياري)
      await _incrementShareCount('vendor', vendor.id);
      
    } catch (e) {
      if (kDebugMode) print("shareVendor error: $e");
      rethrow;
    }
  }

  /// تسجيل المشاركة في قاعدة البيانات
  static Future<void> _logShare(String shareType, String entityId) async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.userId;

      // استدعاء دالة log_share في Supabase
      await SupabaseService.client.rpc('log_share', params: {
        'p_share_type': shareType,
        'p_entity_id': entityId,
        'p_user_id': userId,
        'p_device_type': Platform.operatingSystem,
        'p_share_method': 'share_plus',
      });

      if (kDebugMode) {
        print('✅ Share logged: $shareType - $entityId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to log share: $e');
      }
      // لا نرمي الخطأ لأن فشل التسجيل لا يجب أن يمنع المشاركة
    }
  }

  /// تحديث عداد المشاركات (اختياري - يتم عبر Trigger)
  static Future<void> _incrementShareCount(
    String shareType, 
    String entityId,
  ) async {
    try {
      if (shareType == 'product') {
        await SupabaseService.client
            .from('products')
            .update({'share_count': 1})
            .eq('id', entityId)
            .select('share_count');
      } else if (shareType == 'vendor') {
        await SupabaseService.client
            .from('vendors')
            .update({'share_count': 1})
            .eq('id', entityId)
            .select('share_count');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to increment share count: $e');
      }
    }
  }

  /// الحصول على عدد المشاركات لمنتج
  static Future<int> getProductShareCount(String productId) async {
    try {
      final result = await SupabaseService.client
          .rpc('get_share_count', params: {
            'p_share_type': 'product',
            'p_entity_id': productId,
          });
      
      return result as int? ?? 0;
    } catch (e) {
      if (kDebugMode) print('Error getting product share count: $e');
      return 0;
    }
  }

  /// الحصول على عدد المشاركات لمتجر
  static Future<int> getVendorShareCount(String vendorId) async {
    try {
      final result = await SupabaseService.client
          .rpc('get_share_count', params: {
            'p_share_type': 'vendor',
            'p_entity_id': vendorId,
          });
      
      return result as int? ?? 0;
    } catch (e) {
      if (kDebugMode) print('Error getting vendor share count: $e');
      return 0;
    }
  }

  /// الحصول على أكثر المنتجات مشاركة
  static Future<List<Map<String, dynamic>>> getMostSharedProducts({
    int limit = 10,
  }) async {
    try {
      final result = await SupabaseService.client
          .rpc('get_most_shared_products', params: {
            'p_limit': limit,
          }) as List;
      
      return result.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) print('Error getting most shared products: $e');
      return [];
    }
  }

  /// الحصول على أكثر المتاجر مشاركة
  static Future<List<Map<String, dynamic>>> getMostSharedVendors({
    int limit = 10,
  }) async {
    try {
      final result = await SupabaseService.client
          .rpc('get_most_shared_vendors', params: {
            'p_limit': limit,
          }) as List;
      
      return result.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) print('Error getting most shared vendors: $e');
      return [];
    }
  }
}
```

---

## 🔗 إعداد Deep Links في Flutter

### الخطوة 9️⃣: تكوين Android

#### ملف `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop">
            
            <!-- Deep Links للمنتجات -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                
                <!-- HTTP and HTTPS -->
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
        </activity>
    </application>
</manifest>
```

### الخطوة 🔟: تكوين iOS

#### ملف `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Universal Links -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.iwinto.istoreto</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>istoreto</string>
        </array>
    </dict>
</array>

<!-- Associated Domains -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:istorto.com</string>
</array>
```

---

## 🧪 الخطوة 1️⃣1️⃣: سكريبت اختبار

```sql
-- اختبار إضافة مشاركة
SELECT public.log_share('product', 'product-123', NULL, 'android', 'share_plus');

-- اختبار الحصول على عدد المشاركات
SELECT public.get_share_count('product', 'product-123');

-- اختبار الحصول على أكثر المنتجات مشاركة
SELECT * FROM public.get_most_shared_products(5);

-- اختبار الحصول على أكثر المتاجر مشاركة
SELECT * FROM public.get_most_shared_vendors(5);

-- عرض جميع المشاركات
SELECT * FROM public.shares ORDER BY shared_at DESC LIMIT 10;

-- عرض إحصائيات المشاركة حسب النوع
SELECT 
    share_type,
    COUNT(*) AS total_shares,
    COUNT(DISTINCT entity_id) AS unique_entities,
    COUNT(DISTINCT user_id) AS unique_users
FROM public.shares
GROUP BY share_type;
```

---

## 📊 الخطوة 1️⃣2️⃣: Views للإحصائيات

```sql
-- View لإحصائيات المشاركة اليومية
CREATE OR REPLACE VIEW public.daily_share_stats AS
SELECT 
    DATE(shared_at) AS share_date,
    share_type,
    COUNT(*) AS total_shares,
    COUNT(DISTINCT entity_id) AS unique_entities,
    COUNT(DISTINCT user_id) AS unique_users
FROM public.shares
GROUP BY DATE(shared_at), share_type
ORDER BY share_date DESC;

-- View لأفضل المنتجات حسب المشاركة
CREATE OR REPLACE VIEW public.top_shared_products AS
SELECT 
    p.id,
    p.title,
    p.price,
    p.images[1] AS thumbnail,
    v.organization_name AS vendor_name,
    COUNT(s.id) AS share_count
FROM public.products p
LEFT JOIN public.shares s ON s.entity_id = p.id AND s.share_type = 'product'
LEFT JOIN public.vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false
GROUP BY p.id, p.title, p.price, p.images, v.organization_name
HAVING COUNT(s.id) > 0
ORDER BY share_count DESC;

-- View لأفضل المتاجر حسب المشاركة
CREATE OR REPLACE VIEW public.top_shared_vendors AS
SELECT 
    v.id,
    v.organization_name,
    v.organization_logo,
    COUNT(s.id) AS share_count
FROM public.vendors v
LEFT JOIN public.shares s ON s.entity_id = v.id AND s.share_type = 'vendor'
WHERE v.is_deleted = false
GROUP BY v.id, v.organization_name, v.organization_logo
HAVING COUNT(s.id) > 0
ORDER BY share_count DESC;
```

---

## ✅ ملخص الخطوات | Steps Summary

### في Supabase Dashboard:

1. ✅ **الخطوة 1:** إنشاء جدول `shares`
2. ✅ **الخطوة 2:** إعداد RLS Policies
3. ✅ **الخطوة 3:** إنشاء دالة `log_share()`
4. ✅ **الخطوة 4:** إنشاء دوال الإحصائيات
5. ✅ **الخطوة 5:** إضافة عمود `share_count`
6. ✅ **الخطوة 6:** إنشاء Triggers
7. ✅ **الخطوة 7:** إنشاء Views للمشاركة

### في Flutter:

8. ✅ **الخطوة 8:** تحديث `share_services.dart`
9. ✅ **الخطوة 9:** تكوين AndroidManifest.xml
10. ✅ **الخطوة 10:** تكوين iOS Info.plist
11. ✅ **الخطوة 11:** اختبار النظام
12. ✅ **الخطوة 12:** مراقبة الإحصائيات

---

## 🎯 الفوائد | Benefits

### مع هذا النظام ستحصل على:

✅ **تتبع دقيق** لعمليات المشاركة
✅ **إحصائيات فورية** للمنتجات والمتاجر الأكثر مشاركة
✅ **Deep Links** للعودة للتطبيق
✅ **عدادات تلقائية** للمشاركات
✅ **تحليلات متقدمة** لسلوك المستخدمين
✅ **أداء محسّن** مع Indexes
✅ **أمان عالي** مع RLS Policies

---

## 🔧 استكشاف الأخطاء | Troubleshooting

### المشكلة: دالة log_share تفشل
**الحل:**
```sql
-- تحقق من الصلاحيات
SELECT * FROM information_schema.routine_privileges 
WHERE routine_name = 'log_share';

-- أعد إنشاء الدالة مع SECURITY DEFINER
```

### المشكلة: Trigger لا يعمل
**الحل:**
```sql
-- تحقق من وجود Trigger
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_share_count';

-- أعد إنشاء Trigger
```

### المشكلة: RLS يمنع الإدراج
**الحل:**
```sql
-- تحقق من Policies
SELECT * FROM pg_policies WHERE tablename = 'shares';

-- أعد إنشاء Policy للإدراج
```

---

## 📝 ملاحظات هامة | Important Notes

1. **Domain Verification:** تحتاج للتحقق من ملكية النطاق `istorto.com` لـ Universal Links
2. **SSL Certificate:** يجب أن يكون لديك شهادة SSL صالحة
3. **AASA File:** (Apple App Site Association) مطلوب لـ iOS
4. **assetlinks.json:** مطلوب لـ Android

---

🎉 **بعد تطبيق جميع الخطوات، سيكون نظام المشاركة جاهزاً للعمل مع Supabase بالكامل!**

