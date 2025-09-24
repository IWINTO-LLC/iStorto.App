# Save For Later - نظام حفظ المنتجات لاحقاً

تم تحديث نظام "حفظ لاحقاً" ليعمل مع Supabase بدلاً من Firestore.

## الملفات المحدثة

### 1. **SaveForLaterRepository** (`lib/featured/cart/data/save_for_later_repository.dart`)
- **الغرض**: إدارة جميع عمليات قاعدة البيانات للمنتجات المحفوظة
- **الطرق الرئيسية**:
  - `saveItem()` - حفظ منتج لاحقاً
  - `getSavedItems()` - جلب المنتجات المحفوظة
  - `removeItem()` - حذف منتج من المحفوظات
  - `clearAllSavedItems()` - مسح جميع المحفوظات
  - `isItemSaved()` - التحقق من وجود منتج في المحفوظات
  - `moveToCart()` - نقل منتج من المحفوظات للسلة
  - `moveAllToCart()` - نقل جميع المحفوظات للسلة

### 2. **SaveForLaterController** (`lib/featured/cart/controller/save_for_later.dart`)
- **تم إزالة**: جميع تبعيات Firestore
- **تم إضافة**: تكامل Supabase من خلال الـ repository
- **تم تحديث**: جميع الطرق لتصبح async مع معالجة الأخطاء
- **تم إضافة**: حالات التحميل ورسائل النجاح/الخطأ

### 3. **Database Schema** (`lib/utils/supabase_save_for_later_schema.sql`)
- **الجدول**: `save_for_later`
- **المميزات**:
  - Row Level Security (RLS) مفعل
  - تحديث تلقائي للطوابع الزمنية
  - فهارس للأداء
  - دوال مساعدة للعمليات
  - عرض ملخص المحفوظات

## إعداد قاعدة البيانات

### الخطوة 1: تشغيل SQL Schema
قم بتنفيذ أوامر SQL في `lib/utils/supabase_save_for_later_schema.sql` في محرر SQL الخاص بـ Supabase:

```sql
-- انسخ والصق المحتوى الكامل لـ supabase_save_for_later_schema.sql
-- في محرر SQL الخاص بـ Supabase وقم بتشغيله
```

### الخطوة 2: التحقق من إنشاء الجدول
بعد تشغيل SQL، تأكد من إنشاء:
- ✅ جدول `save_for_later`
- ✅ سياسات RLS
- ✅ الفهارس
- ✅ الدوال المساعدة
- ✅ عرض `saved_items_summary`

## هيكل البيانات

### جدول `save_for_later`:
```sql
CREATE TABLE save_for_later (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  product_id TEXT NOT NULL,
  vendor_id TEXT,
  title TEXT NOT NULL,
  price DECIMAL(10,2),
  quantity INTEGER,
  image TEXT,
  total_price DECIMAL(10,2),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(user_id, product_id) -- منع تكرار المنتج لنفس المستخدم
);
```

## أمثلة الاستخدام

### حفظ منتج لاحقاً
```dart
final saveController = Get.find<SaveForLaterController>();
await saveController.saveItem(cartItem);
```

### جلب المنتجات المحفوظة
```dart
await saveController.fetchSavedItems();
final savedItems = saveController.savedItems;
```

### حذف منتج من المحفوظات
```dart
await saveController.removeItem(productId);
```

### نقل منتج للسلة
```dart
await saveController.addToCart(cartItem);
```

### نقل جميع المحفوظات للسلة
```dart
await saveController.addAllToCart();
```

### التحقق من وجود منتج في المحفوظات
```dart
final isSaved = await saveController.isItemSaved(productId);
```

### الحصول على عدد المحفوظات
```dart
final count = await saveController.getSavedItemsCount();
```

### مسح جميع المحفوظات
```dart
await saveController.clearAllSavedItems();
```

## المميزات الجديدة

### 1. **أمان أفضل**
- Row Level Security يضمن أن المستخدم يرى فقط محفوظاته
- حماية على مستوى قاعدة البيانات

### 2. **أداء محسن**
- فهارس للاستعلامات السريعة
- عمليات قاعدة بيانات محسنة

### 3. **معالجة أخطاء أفضل**
- رسائل خطأ واضحة
- حالات تحميل للمستخدم

### 4. **تكامل مع السلة**
- نقل سهل من المحفوظات للسلة
- دعم الكميات المتعددة

## استعلامات مفيدة

```sql
-- عرض جميع المحفوظات لمستخدم معين
SELECT * FROM save_for_later WHERE user_id = 'user-uuid';

-- حساب إجمالي قيمة المحفوظات
SELECT SUM(total_price) as total FROM save_for_later WHERE user_id = 'user-uuid';

-- عدد المنتجات المحفوظة
SELECT COUNT(*) as count FROM save_for_later WHERE user_id = 'user-uuid';

-- حذف جميع المحفوظات
DELETE FROM save_for_later WHERE user_id = 'user-uuid';

-- نقل منتج للسلة (دالة مدمجة)
SELECT move_saved_item_to_cart('user-uuid', 'product-id', 1);
```

## استكشاف الأخطاء

### المشاكل الشائعة

1. **أخطاء RLS Policy**: تأكد من إعداد سياسات RLS بشكل صحيح
2. **أخطاء المصادقة**: تأكد من تسجيل دخول المستخدم
3. **أخطاء النوع**: تحقق من صحة معرفات المنتجات
4. **أخطاء الشبكة**: تعامل مع مشاكل الاتصال بشكل مناسب

### نصائح التصحيح

1. تحقق من سجلات Supabase للأخطاء
2. استخدم `debugPrint()` لتتبع العمليات
3. تحقق من حالة المصادقة
4. تحقق من سياسات RLS في لوحة Supabase

## التحسينات المستقبلية

1. **تحديثات فورية**: مزامنة فورية للمحفوظات
2. **إشعارات**: تنبيهات للمنتجات المحفوظة
3. **تصنيف**: تصنيف المحفوظات حسب الفئة
4. **مشاركة**: مشاركة قوائم المحفوظات
5. **تحليلات**: إحصائيات استخدام المحفوظات

## قائمة التحقق

- [x] إنشاء repository
- [x] تحديث controller
- [x] إنشاء schema قاعدة البيانات
- [x] إزالة تبعيات Firestore
- [x] إصلاح أخطاء linting
- [x] إضافة معالجة الأخطاء
- [x] إضافة حالات التحميل
- [x] اختبار الوظائف

النظام جاهز للاستخدام! 🎯✨
