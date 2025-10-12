# دليل البداية السريعة - نظام المشاركة
# Quick Start Guide - Share System

---

## 🚀 البداية السريعة (5 دقائق)

### 1️⃣ تنفيذ SQL في Supabase

افتح **Supabase Dashboard** → **SQL Editor** → **New Query** ثم نفذ:

```sql
-- نسخ والصق محتوى الملف التالي:
setup_share_system_supabase.sql
```

**أو** قم بتنفيذ الخطوات يدوياً:

```sql
-- 1. إنشاء الجدول
CREATE TABLE public.shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    share_type TEXT NOT NULL CHECK (share_type IN ('product', 'vendor')),
    entity_id TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    shared_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_type TEXT,
    share_method TEXT
);

-- 2. الفهارس
CREATE INDEX idx_shares_entity ON public.shares(share_type, entity_id);
CREATE INDEX idx_shares_user ON public.shares(user_id);
CREATE INDEX idx_shares_date ON public.shares(shared_at DESC);

-- 3. تفعيل RLS
ALTER TABLE public.shares ENABLE ROW LEVEL SECURITY;

-- 4. السياسات
CREATE POLICY "Allow public read access" ON public.shares FOR SELECT TO public USING (true);
CREATE POLICY "Allow authenticated insert" ON public.shares FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- 5. الدوال (انسخ من setup_share_system_supabase.sql)
```

### 2️⃣ تحديث Flutter Code

استبدل محتوى `lib/featured/share/controller/share_services.dart` بالكود من الدليل الشامل.

### 3️⃣ اختبار النظام

```dart
// في أي مكان في تطبيقك
import 'package:istoreto/featured/share/controller/share_services.dart';

// مشاركة منتج
await ShareServices.shareProduct(product);

// مشاركة متجر
await ShareServices.shareVendor(vendor);

// الحصول على عدد المشاركات
int count = await ShareServices.getProductShareCount(productId);
```

---

## ✅ التحقق من نجاح التثبيت

### في Supabase Dashboard:

1. **Table Editor** → تأكد من وجود جدول `shares`
2. **SQL Editor** → نفذ:

```sql
SELECT * FROM public.shares LIMIT 5;
SELECT public.get_share_count('product', 'any-product-id');
```

### في Flutter:

```dart
// يجب أن تعمل بدون أخطاء
await ShareServices.shareProduct(product);
print('✅ Share System Working!');
```

---

## 📋 الملفات المطلوبة

### ملفات SQL (نفذها بالترتيب):
1. ✅ `setup_share_system_supabase.sql` - الإعداد الأساسي
2. ✅ `test_share_system_supabase.sql` - الاختبارات (اختياري)

### ملفات Flutter:
1. ✅ تحديث `share_services.dart`

### ملفات التوثيق:
1. 📖 `SUPABASE_SHARE_SYSTEM_SETUP.md` - الدليل الشامل
2. 📖 `QUICK_START_SHARE_SYSTEM.md` - هذا الملف

---

## 🎯 الميزات الأساسية

### ما الذي سيعمل فوراً:

✅ **مشاركة المنتجات** مع صورة + اسم + سعر + رابط
✅ **مشاركة المتاجر** مع شعار + اسم + رابط
✅ **تتبع المشاركات** في قاعدة البيانات
✅ **عدادات تلقائية** للمشاركات
✅ **إحصائيات** للمنتجات والمتاجر الأكثر مشاركة

---

## 🔧 إصلاح المشاكل الشائعة

### المشكلة: "permission denied for function log_share"
**الحل:**
```sql
-- أعد إنشاء الدالة مع SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.log_share(...)
SECURITY DEFINER  -- هذا السطر مهم
AS $$ ... $$;
```

### المشكلة: "relation shares does not exist"
**الحل:**
```sql
-- تأكد من إنشاء الجدول في schema public
CREATE TABLE IF NOT EXISTS public.shares (...);
```

### المشكلة: ShareServices.shareProduct() لا يعمل
**الحل:**
```dart
// تأكد من تسجيل AuthController
final authController = Get.find<AuthController>();

// تأكد من تسجيل SupabaseService
await SupabaseService.client.rpc('log_share', ...);
```

---

## 📊 مثال عملي كامل

```dart
import 'package:istoreto/featured/share/controller/share_services.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // ... محتوى البطاقة
          
          // زر المشاركة
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              try {
                // إظهار مؤشر تحميل
                Get.dialog(
                  Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                
                // مشاركة المنتج
                await ShareServices.shareProduct(product);
                
                // إخفاء مؤشر التحميل
                Get.back();
                
                // رسالة نجاح
                Get.snackbar(
                  'success'.tr,
                  'تم مشاركة المنتج بنجاح',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade800,
                );
              } catch (e) {
                // إخفاء مؤشر التحميل
                Get.back();
                
                // رسالة خطأ
                Get.snackbar(
                  'error'.tr,
                  'فشلت عملية المشاركة',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                );
              }
            },
          ),
          
          // عرض عدد المشاركات
          FutureBuilder<int>(
            future: ShareServices.getProductShareCount(product.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data! > 0) {
                return Text('${snapshot.data} مشاركة');
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🎨 عرض أكثر المنتجات مشاركة

```dart
class MostSharedProductsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ShareServices.getMostSharedProducts(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('لا توجد منتجات مشاركة');
        }
        
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return ListTile(
              title: Text('Product ID: ${item['product_id']}'),
              subtitle: Text('Shares: ${item['share_count']}'),
              trailing: Text(
                'Last: ${item['last_shared']}',
                style: TextStyle(fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## 🔍 استعلامات مفيدة

### عرض آخر 10 مشاركات:
```sql
SELECT * FROM public.shares ORDER BY shared_at DESC LIMIT 10;
```

### عرض المنتجات الأكثر مشاركة:
```sql
SELECT * FROM public.top_shared_products LIMIT 10;
```

### عرض المتاجر الأكثر مشاركة:
```sql
SELECT * FROM public.top_shared_vendors LIMIT 10;
```

### عرض إحصائيات يومية:
```sql
SELECT * FROM public.daily_share_stats;
```

---

## 📱 إضافة Deep Links (اختياري)

### Android (`AndroidManifest.xml`):
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="istorto.com"
        android:pathPrefix="/product" />
</intent-filter>
```

### iOS (`Info.plist`):
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:istorto.com</string>
</array>
```

---

## 🎉 تهانينا!

✅ نظام المشاركة جاهز للعمل!

### المميزات المتاحة الآن:
- ✅ مشاركة منتجات ومتاجر
- ✅ تتبع المشاركات
- ✅ عدادات تلقائية
- ✅ إحصائيات متقدمة
- ✅ Views للتحليلات

---

## 📚 روابط مفيدة

- 📖 [الدليل الشامل](./SUPABASE_SHARE_SYSTEM_SETUP.md)
- 🧪 [ملف الاختبارات](./test_share_system_supabase.sql)
- 🔧 [ملف الإعداد](./setup_share_system_supabase.sql)

---

## 💡 نصائح للأداء

1. **Cache** عدادات المشاركة في التطبيق
2. **Batch** عمليات التسجيل عند الإمكان
3. **Monitor** استخدام قاعدة البيانات
4. **Cleanup** البيانات القديمة دورياً:

```sql
-- تنفيذ كل شهر
SELECT public.cleanup_old_shares(365);
```

---

🚀 **ابدأ الآن واستمتع بميزة المشاركة الاحترافية!**

