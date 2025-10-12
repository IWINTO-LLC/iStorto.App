# دليل إصلاح نظام السلة الشامل

## 🚨 المشكلة

**السلة لا تعمل إطلاقاً** - لا يمكن إضافة منتجات للسلة.

---

## 🔍 الأسباب المحتملة

1. ❌ جدول `cart_items` غير موجود
2. ❌ RLS (Row Level Security) غير مفعل
3. ❌ سياسات RLS مفقودة أو خاطئة
4. ❌ صلاحيات (Permissions) مفقودة
5. ❌ المستخدم غير مسجل دخول
6. ❌ أخطاء في التطبيق (Flutter)

---

## ✅ الحل الكامل (خطوة بخطوة)

### الخطوة 1: التشخيص

**افتح Supabase SQL Editor ونفذ:**

```sql
-- الصق محتوى ملف DEBUG_CART_SYSTEM.sql
```

**النتيجة ستظهر لك:**
```
═══════════ تقرير نظام السلة ═══════════
1. الجدول: ✅ موجود / ❌ غير موجود
2. RLS: ✅ مفعل / ❌ غير مفعل  
3. السياسات: 4 من 4 ✅ / 0 من 4 ❌
4. الصلاحيات: 4 من 4 ✅ / 0 من 4 ❌
5. المستخدم: ✅ مسجل دخول / ❌ غير مسجل دخول
6. عدد العناصر: 0
═══════════════════════════════════════
```

---

### الخطوة 2: الإصلاح

**نفذ السكريبت الكامل:**

```sql
-- الصق محتوى ملف COMPLETE_CART_SYSTEM_FIX.sql بالكامل
```

**هذا السكريبت سيقوم بـ:**

✅ إنشاء جدول `cart_items` (إذا لم يكن موجوداً)  
✅ تفعيل RLS  
✅ إنشاء 4 سياسات (SELECT, INSERT, UPDATE, DELETE)  
✅ منح الصلاحيات المطلوبة  
✅ إنشاء الفهارس (Indexes) لتحسين الأداء  
✅ إنشاء الدوال المساعدة  
✅ إضافة قيد UNIQUE لمنع التكرار  

---

### الخطوة 3: التحقق

**نفذ مرة أخرى:**

```sql
-- الصق DEBUG_CART_SYSTEM.sql مرة أخرى
```

**يجب أن ترى:**
```
1. الجدول: ✅ موجود
2. RLS: ✅ مفعل
3. السياسات: 4 من 4 ✅
4. الصلاحيات: 4 من 4 ✅
5. المستخدم: ✅ مسجل دخول
```

---

## 📋 بنية جدول cart_items

```sql
CREATE TABLE cart_items (
  id UUID PRIMARY KEY,              -- معرف فريد
  user_id UUID NOT NULL,            -- معرف المستخدم
  product_id TEXT NOT NULL,         -- معرف المنتج
  vendor_id TEXT,                   -- معرف البائع
  title TEXT NOT NULL,              -- اسم المنتج
  price DECIMAL(10,2) NOT NULL,     -- السعر
  quantity INTEGER NOT NULL,        -- الكمية
  image TEXT,                       -- رابط الصورة
  total_price DECIMAL(10,2) NOT NULL, -- السعر الإجمالي
  created_at TIMESTAMP,             -- تاريخ الإضافة
  updated_at TIMESTAMP,             -- تاريخ التحديث
  
  UNIQUE (user_id, product_id)     -- منع التكرار
);
```

---

## 🛡️ سياسات RLS

### 1. سياسة القراءة (SELECT)
```sql
CREATE POLICY "cart_items_select_policy" 
ON cart_items FOR SELECT 
USING (auth.uid() = user_id);
```
**الوظيفة:** يسمح للمستخدم برؤية عناصر سلته فقط

### 2. سياسة الإضافة (INSERT)
```sql
CREATE POLICY "cart_items_insert_policy" 
ON cart_items FOR INSERT 
WITH CHECK (auth.uid() = user_id);
```
**الوظيفة:** يسمح للمستخدم بإضافة عناصر لسلته فقط

### 3. سياسة التحديث (UPDATE)
```sql
CREATE POLICY "cart_items_update_policy" 
ON cart_items FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```
**الوظيفة:** يسمح للمستخدم بتحديث عناصر سلته فقط

### 4. سياسة الحذف (DELETE)
```sql
CREATE POLICY "cart_items_delete_policy" 
ON cart_items FOR DELETE 
USING (auth.uid() = user_id);
```
**الوظيفة:** يسمح للمستخدم بحذف عناصر من سلته فقط

---

## 🔧 الدوال المساعدة

### 1. upsert_cart_item
**الوظيفة:** إضافة منتج جديد أو زيادة الكمية إذا كان موجوداً

```sql
SELECT upsert_cart_item(
    auth.uid(),           -- user_id
    'product_123',        -- product_id
    'vendor_456',         -- vendor_id
    'Product Name',       -- title
    19.99,                -- price
    1,                    -- quantity
    'https://...'         -- image
);
```

### 2. clear_user_cart
**الوظيفة:** مسح جميع عناصر السلة

```sql
SELECT clear_user_cart(auth.uid());
```

### 3. get_cart_items_count
**الوظيفة:** الحصول على عدد العناصر

```sql
SELECT get_cart_items_count(auth.uid());
```

### 4. get_cart_total_value
**الوظيفة:** الحصول على القيمة الإجمالية

```sql
SELECT get_cart_total_value(auth.uid());
```

---

## 🧪 اختبار النظام

### اختبار من Supabase:

```sql
-- 1. إضافة عنصر
INSERT INTO cart_items (user_id, product_id, vendor_id, title, price, quantity, total_price)
VALUES (auth.uid(), 'test_prod', 'test_vendor', 'Test', 10.00, 1, 10.00);

-- 2. التحقق من الإضافة
SELECT * FROM cart_items WHERE user_id = auth.uid();

-- 3. تحديث الكمية
UPDATE cart_items 
SET quantity = 2, total_price = 20.00
WHERE user_id = auth.uid() AND product_id = 'test_prod';

-- 4. الحذف
DELETE FROM cart_items 
WHERE user_id = auth.uid() AND product_id = 'test_prod';
```

**إذا نجحت جميع العمليات:** ✅ قاعدة البيانات تعمل بشكل صحيح

**إذا فشلت:** راجع رسالة الخطأ واتبع الحل المقترح

---

## 📱 اختبار من التطبيق

### 1. تفعيل Debug Mode

في `lib/featured/cart/controller/cart_controller.dart`:

```dart
Future<void> addToCart(ProductModel product) async {
  debugPrint('🛒 Adding to cart: ${product.title}');
  debugPrint('📦 Product ID: ${product.id}');
  debugPrint('👤 User: ${SupabaseService.client.auth.currentUser?.id}');
  
  try {
    await updateQuantity(product, 1);
    debugPrint('✅ Added successfully');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
```

### 2. راقب Console Logs

عند النقر على زر السلة، يجب أن ترى:
```
🛒 Adding to cart: Product Name
📦 Product ID: xxx-xxx-xxx
👤 User: yyy-yyy-yyy
✅ Added successfully
```

**إذا رأيت خطأ:**
- `Exception: Failed to save cart` → مشكلة في قاعدة البيانات
- `null user` → المستخدم غير مسجل دخول
- `permission denied` → مشكلة في RLS

---

## 🔧 حلول المشاكل الشائعة

### المشكلة: "permission denied for table cart_items"

**الحل:**
```sql
-- منح الصلاحيات
GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO authenticated;
GRANT USAGE ON SEQUENCE cart_items_id_seq TO authenticated;

-- تفعيل RLS
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
```

---

### المشكلة: "new row violates row-level security policy"

**الحل:**
```sql
-- إعادة إنشاء سياسة INSERT
DROP POLICY IF EXISTS "cart_items_insert_policy" ON cart_items;

CREATE POLICY "cart_items_insert_policy" 
ON cart_items FOR INSERT 
WITH CHECK (auth.uid() = user_id);
```

---

### المشكلة: "duplicate key value violates unique constraint"

**الحل:**
```sql
-- المنتج موجود بالفعل - يجب تحديث الكمية بدلاً من الإضافة
-- استخدم دالة upsert_cart_item

SELECT upsert_cart_item(
    auth.uid(),
    'product_id',
    'vendor_id',
    'title',
    19.99,
    1,
    'image_url'
);
```

---

### المشكلة: "relation cart_items does not exist"

**الحل:**
```sql
-- الجدول غير موجود - نفذ COMPLETE_CART_SYSTEM_FIX.sql
```

---

### المشكلة: المستخدم غير مسجل دخول

**الحل:**
```dart
// في التطبيق - تحقق من تسجيل الدخول
final user = SupabaseService.client.auth.currentUser;
if (user == null) {
  Get.snackbar('خطأ', 'يرجى تسجيل الدخول أولاً');
  Get.toNamed('/login');
  return;
}
```

---

## 📊 فحص حالة النظام

### في Supabase Dashboard:

1. **Table Editor:**
   - افتح جدول `cart_items`
   - تحقق من وجود الأعمدة الصحيحة
   - جرب إضافة صف يدوياً

2. **Authentication:**
   - تحقق من وجود مستخدمين
   - تحقق من حالة تسجيل الدخول

3. **Database → Policies:**
   - افتح جدول `cart_items`
   - تحقق من وجود 4 سياسات
   - تحقق من تفعيل RLS

---

## 🎯 الخطوات السريعة

### للإصلاح السريع:

```bash
1. افتح Supabase SQL Editor
2. الصق محتوى COMPLETE_CART_SYSTEM_FIX.sql
3. اضغط Run
4. انتظر حتى تكتمل جميع العمليات
5. نفذ DEBUG_CART_SYSTEM.sql للتحقق
6. يجب أن ترى جميع ✅
7. جرب التطبيق الآن
```

---

## 📝 استعلامات مفيدة

### مسح السلة:
```sql
DELETE FROM cart_items WHERE user_id = auth.uid();
```

### عرض عناصر السلة:
```sql
SELECT * FROM cart_items WHERE user_id = auth.uid();
```

### إحصائيات السلة:
```sql
SELECT 
    COUNT(*) as items,
    SUM(quantity) as total_qty,
    SUM(total_price) as total_value
FROM cart_items 
WHERE user_id = auth.uid();
```

### البحث عن منتج معين:
```sql
SELECT * FROM cart_items 
WHERE user_id = auth.uid() 
    AND product_id = 'YOUR_PRODUCT_ID';
```

---

## 🐛 Debug من التطبيق

### إضافة Logs في CartController:

```dart
Future<void> addToCart(ProductModel product) async {
  debugPrint('═══════════════════════════════════');
  debugPrint('🛒 بدء إضافة للسلة');
  debugPrint('📦 المنتج: ${product.title}');
  debugPrint('🆔 Product ID: ${product.id}');
  debugPrint('👤 User ID: ${SupabaseService.client.auth.currentUser?.id}');
  debugPrint('💰 السعر: ${product.price}');
  
  try {
    final result = await updateQuantity(product, 1);
    debugPrint('✅ نجح! النتيجة: $result');
  } catch (e, stack) {
    debugPrint('❌ فشل! الخطأ: $e');
    debugPrint('📍 Stack trace: $stack');
  }
  
  debugPrint('═══════════════════════════════════');
}
```

---

## 🎯 التحقق النهائي

### قائمة التحقق:

- [ ] جدول `cart_items` موجود ✅
- [ ] RLS مفعل ✅
- [ ] 4 سياسات موجودة (SELECT, INSERT, UPDATE, DELETE) ✅
- [ ] صلاحيات authenticated موجودة ✅
- [ ] المستخدم مسجل دخول ✅
- [ ] الدوال المساعدة موجودة ✅
- [ ] الفهارس موجودة ✅
- [ ] التطبيق يتصل بـ Supabase بشكل صحيح ✅

**إذا كانت جميع الإجابات ✅** → النظام يجب أن يعمل الآن!

---

## 🚀 ملفات السكريبتات

### 1. `COMPLETE_CART_SYSTEM_FIX.sql` ⭐
**الوظيفة:** إصلاح شامل لجميع المشاكل

**متى تستخدمه:**
- عند إعداد نظام السلة لأول مرة
- عند حدوث مشاكل في السلة
- لإعادة تعيين النظام بالكامل

**ما يفعله:**
- ✅ ينشئ الجدول
- ✅ يضبط RLS
- ✅ ينشئ السياسات
- ✅ يمنح الصلاحيات
- ✅ ينشئ الدوال المساعدة

---

### 2. `DEBUG_CART_SYSTEM.sql` 🔍
**الوظيفة:** تشخيص المشاكل

**متى تستخدمه:**
- قبل التطبيق السكريبت الإصلاحي
- بعد التطبيق للتحقق
- عند ظهور مشاكل جديدة

**ما يفعله:**
- ✅ يفحص وجود الجدول
- ✅ يفحص RLS
- ✅ يفحص السياسات
- ✅ يفحص الصلاحيات
- ✅ يختبر العمليات
- ✅ يعطي تقرير شامل

---

### 3. `lib/utils/supabase_cart_schema.sql`
**الوظيفة:** Schema الأصلي

**متى تستخدمه:**
- للمرجعية فقط
- لفهم البنية الأساسية

**الفرق مع COMPLETE_CART_SYSTEM_FIX.sql:**
- السكريبت الجديد أشمل وأفضل
- يتضمن دالة upsert_cart_item
- يتضمن قيد UNIQUE
- يتضمن فحوصات وتقارير

---

## 💡 نصائح مهمة

### 1. قبل تنفيذ السكريبت:

⚠️ **تحذير:** السكريبت يحتوي على أمر حذف الجدول (معطّل بشكل افتراضي)

```sql
-- DROP TABLE IF EXISTS cart_items CASCADE;  ← مُعطّل
```

**لتفعيله:** احذف `--` من بداية السطر  
**النتيجة:** سيحذف جميع بيانات السلة الحالية

### 2. في بيئة الإنتاج:

✅ **لا تحذف الجدول** إذا كان يحتوي على بيانات مستخدمين  
✅ **احفظ نسخة احتياطية** قبل التنفيذ  
✅ **نفذ السكريبت في وقت أقل حركة**  

### 3. بعد التنفيذ:

✅ **نفذ DEBUG_CART_SYSTEM.sql** للتحقق  
✅ **اختبر من التطبيق**  
✅ **راقب Console Logs**  

---

## 📞 استكشاف الأخطاء

### إذا لم يعمل بعد تنفيذ السكريبت:

#### 1. تحقق من التطبيق (Flutter):

```dart
// في cart_repository.dart
debugPrint('Saving cart items: ${cartItems.length}');
debugPrint('User ID: ${_client.auth.currentUser?.id}');
```

#### 2. تحقق من Supabase:

```sql
-- فحص البيانات
SELECT * FROM cart_items;

-- فحص السياسات
SELECT * FROM pg_policies WHERE tablename = 'cart_items';

-- فحص الصلاحيات
SELECT * FROM information_schema.table_privileges 
WHERE table_name = 'cart_items';
```

#### 3. تحقق من الاتصال:

```dart
// في التطبيق
try {
  final user = SupabaseService.client.auth.currentUser;
  debugPrint('User: ${user?.id}');
  
  final test = await SupabaseService.client
      .from('cart_items')
      .select()
      .limit(1);
  debugPrint('Connection: OK');
} catch (e) {
  debugPrint('Connection Error: $e');
}
```

---

## ✨ الميزات الإضافية

### القيد UNIQUE:
- يمنع إضافة نفس المنتج مرتين
- يجب استخدام upsert للتحديث

### الفهارس:
- تسريع البحث بـ user_id
- تسريع البحث بـ product_id
- تسريع الترتيب بـ created_at

### الدوال:
- upsert_cart_item: إضافة أو تحديث ذكي
- clear_user_cart: مسح سريع
- get_cart_items_count: عد سريع
- get_cart_total_value: مجموع سريع

---

## 🎉 النتيجة المتوقعة

بعد تطبيق الإصلاحات:

✅ **يمكنك إضافة منتجات للسلة**  
✅ **يمكنك تحديث الكميات**  
✅ **يمكنك حذف منتجات**  
✅ **يمكنك مسح السلة**  
✅ **التحديثات فورية**  
✅ **البيانات محمية (RLS)**  
✅ **الأداء ممتاز (Indexes)**  

---

## 📋 الخلاصة

### للإصلاح الكامل:

```bash
1. افتح Supabase SQL Editor
2. نفذ DEBUG_CART_SYSTEM.sql (لمعرفة المشكلة)
3. نفذ COMPLETE_CART_SYSTEM_FIX.sql (للإصلاح)
4. نفذ DEBUG_CART_SYSTEM.sql مرة أخرى (للتحقق)
5. جرب التطبيق
6. راقب Logs
7. استمتع بنظام سلة يعمل! 🎉
```

---

**آخر تحديث:** الآن  
**الحالة:** جاهز للتطبيق  
**الأولوية:** عالية جداً ⭐⭐⭐

