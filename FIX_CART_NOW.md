# 🚀 إصلاح السلة الآن - خطوات بسيطة

## ⚡ الإصلاح السريع (5 دقائق)

### الخطوة 1️⃣: افتح Supabase

1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. اختر مشروعك
3. من القائمة الجانبية → **SQL Editor**
4. اضغط **"New Query"**

---

### الخطوة 2️⃣: نفذ اختبار سريع

```sql
-- الصق الكود التالي واضغط Run:

SELECT 
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ غير مسجل دخول'
        ELSE '✅ مسجل: ' || auth.email()
    END as status,
    CASE 
        WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cart_items')
        THEN '✅ الجدول موجود'
        ELSE '❌ الجدول مفقود'
    END as table_status,
    CASE 
        WHEN (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'cart_items') >= 4
        THEN '✅ السياسات موجودة'
        ELSE '❌ السياسات مفقودة'
    END as policies_status;
```

**النتيجة:**
- إذا رأيت **جميع ✅** → السلة يجب أن تعمل (المشكلة في التطبيق)
- إذا رأيت **أي ❌** → انتقل للخطوة 3

---

### الخطوة 3️⃣: نفذ الإصلاح الكامل

1. **افتح الملف:** `COMPLETE_CART_SYSTEM_FIX.sql`
2. **انسخ المحتوى بالكامل**
3. **الصقه في SQL Editor**
4. **اضغط Run**
5. **انتظر حتى ينتهي** (قد يأخذ 10-20 ثانية)

---

### الخطوة 4️⃣: تحقق من النجاح

```sql
-- الصق الكود التالي واضغط Run:

SELECT '═══════════ تقرير النظام ═══════════' as title
UNION ALL
SELECT CASE 
    WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cart_items')
    THEN '✅ 1. الجدول موجود'
    ELSE '❌ 1. الجدول مفقود'
END
UNION ALL
SELECT CASE 
    WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'cart_items')
    THEN '✅ 2. RLS مفعل'
    ELSE '❌ 2. RLS غير مفعل'
END
UNION ALL
SELECT '✅ 3. السياسات: ' || 
    (SELECT COUNT(*)::TEXT FROM pg_policies WHERE tablename = 'cart_items') || '/4'
UNION ALL
SELECT '✅ 4. الصلاحيات: ' || 
    (SELECT COUNT(DISTINCT privilege_type)::TEXT 
     FROM information_schema.table_privileges 
     WHERE table_name = 'cart_items' AND grantee = 'authenticated') || '/4'
UNION ALL
SELECT '═══════════════════════════════════════';
```

**يجب أن ترى:**
```
✅ 1. الجدول موجود
✅ 2. RLS مفعل
✅ 3. السياسات: 4/4
✅ 4. الصلاحيات: 4/4
```

---

### الخطوة 5️⃣: جرب التطبيق

1. **افتح التطبيق**
2. **سجل دخول** (إذا لم تكن مسجلاً)
3. **اختر منتج**
4. **اضغط زر السلة** (+)
5. **راقب النتيجة**

**إذا نجح:**
- ✅ يظهر العدد في أيقونة السلة
- ✅ يظهر إشعار "تمت الإضافة"
- ✅ المنتج موجود في صفحة السلة

**إذا فشل:**
- انتقل للخطوة 6

---

### الخطوة 6️⃣: فحص الأخطاء (إذا لم يعمل)

**في Supabase SQL Editor:**

```sql
-- جرب إضافة عنصر يدوياً:

INSERT INTO cart_items (
    user_id, 
    product_id, 
    vendor_id, 
    title, 
    price, 
    quantity, 
    total_price
)
VALUES (
    auth.uid(),              -- معرفك
    'test_product',          -- معرف اختباري
    'test_vendor',           -- بائع اختباري
    'منتج تجريبي',          -- الاسم
    10.50,                   -- السعر
    1,                       -- الكمية
    10.50                    -- السعر الإجمالي
);

-- التحقق من الإضافة:
SELECT * FROM cart_items WHERE user_id = auth.uid();
```

**إذا نجحت الإضافة اليدوية:**
- ✅ قاعدة البيانات تعمل
- ❌ المشكلة في كود التطبيق (Flutter)
- 👉 راجع `CartController` و `CartRepository`

**إذا فشلت الإضافة اليدوية:**
- راجع رسالة الخطأ
- نفذ الحل المقترح أدناه

---

## 🔧 حلول سريعة للأخطاء الشائعة

### خطأ: "permission denied for table cart_items"

```sql
-- نفذ هذا:
GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO authenticated;
```

---

### خطأ: "new row violates row-level security policy"

```sql
-- نفذ هذا:
DROP POLICY IF EXISTS "cart_items_insert_policy" ON cart_items;

CREATE POLICY "cart_items_insert_policy" 
ON cart_items FOR INSERT 
WITH CHECK (auth.uid() = user_id);
```

---

### خطأ: "relation cart_items does not exist"

```sql
-- الجدول غير موجود - نفذ COMPLETE_CART_SYSTEM_FIX.sql بالكامل
```

---

### خطأ: "duplicate key value violates unique constraint"

```sql
-- المنتج موجود بالفعل - جرب التحديث:
UPDATE cart_items 
SET quantity = quantity + 1,
    total_price = (quantity + 1) * price
WHERE user_id = auth.uid() 
    AND product_id = 'YOUR_PRODUCT_ID';
```

---

## 🎯 الخطوات المضمونة 100%

إذا لم يعمل أي شيء، اتبع هذا:

### 1. حذف كل شيء وإعادة البناء:

```sql
-- ⚠️ تحذير: سيحذف جميع بيانات السلة!

-- 1. حذف الجدول
DROP TABLE IF EXISTS cart_items CASCADE;

-- 2. نفذ COMPLETE_CART_SYSTEM_FIX.sql بالكامل

-- 3. تحقق من النجاح
SELECT 
    COUNT(*) as total_policies,
    (SELECT rowsecurity FROM pg_tables WHERE tablename = 'cart_items') as rls_enabled
FROM pg_policies 
WHERE tablename = 'cart_items';

-- يجب أن ترى: total_policies = 4, rls_enabled = true
```

---

### 2. تحقق من التطبيق:

**في `lib/featured/cart/data/cart_repository.dart`:**

أضف logs:

```dart
Future<void> saveCartItems(List<CartItem> cartItems) async {
  final user = _client.auth.currentUser;
  
  debugPrint('═══════════════════════════════════');
  debugPrint('💾 حفظ عناصر السلة');
  debugPrint('👤 User ID: ${user?.id}');
  debugPrint('📦 Items count: ${cartItems.length}');
  
  if (user == null) {
    debugPrint('❌ المستخدم غير مسجل دخول!');
    return;
  }
  
  if (cartItems.isEmpty) {
    debugPrint('⚠️ السلة فارغة');
    return;
  }

  try {
    debugPrint('🗑️ حذف العناصر القديمة...');
    await _client.from('cart_items').delete().eq('user_id', user.id);
    
    final cartData = cartItems.map((item) => {
      'user_id': user.id,
      'product_id': item.product.id,
      'vendor_id': item.product.vendorId,
      'title': item.product.title,
      'price': item.product.price,
      'quantity': item.quantity,
      'image': item.product.images.isNotEmpty ? item.product.images.first : null,
      'total_price': item.totalPrice,
    }).toList();
    
    debugPrint('➕ إضافة ${cartData.length} عناصر...');
    await _client.from('cart_items').insert(cartData);
    
    debugPrint('✅ تم الحفظ بنجاح!');
    debugPrint('═══════════════════════════════════');
  } catch (e) {
    debugPrint('❌ خطأ في الحفظ: $e');
    debugPrint('═══════════════════════════════════');
    throw Exception('Failed to save cart: $e');
  }
}
```

شغل التطبيق وراقب Console - ستعرف بالضبط أين المشكلة!

---

## 📞 المساعدة السريعة

### النظام لا يزال لا يعمل؟

**أرسل لي:**

1. **نتيجة هذا الاستعلام:**
```sql
SELECT * FROM pg_policies WHERE tablename = 'cart_items';
```

2. **نتيجة هذا الاستعلام:**
```sql
SELECT privilege_type FROM information_schema.table_privileges 
WHERE table_name = 'cart_items' AND grantee = 'authenticated';
```

3. **رسالة الخطأ من Console** (في Flutter)

وسأساعدك في تحديد المشكلة بالضبط!

---

## ✅ قائمة التحقق النهائية

قبل أن تقول "لا يعمل"، تأكد من:

- [ ] نفذت `COMPLETE_CART_SYSTEM_FIX.sql` بالكامل
- [ ] رأيت رسالة "Query executed successfully"
- [ ] نفذت `TEST_CART_QUICK.sql` ورأيت جميع ✅
- [ ] أنت مسجل دخول في التطبيق
- [ ] ال user_id في التطبيق يطابق auth.uid() في Supabase
- [ ] الاتصال بـ Supabase يعمل
- [ ] راجعت Console Logs في التطبيق

---

## 🎉 النجاح

عندما يعمل، ستراحا:

```
✅ في Console:
🛒 Adding to cart: Product Name
✅ Added successfully

✅ في التطبيق:
- رقم يظهر على أيقونة السلة
- إشعار أخضر: "تمت الإضافة للسلة"
- المنتج يظهر في صفحة السلة

✅ في Supabase:
- صفوف جديدة في جدول cart_items
- updated_at يتحدث تلقائياً
```

---

**حظاً موفقاً! 🍀**

إذا اتبعت الخطوات بالترتيب، السلة ستعمل 100%! 💪

