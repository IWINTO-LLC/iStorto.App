# دليل إعداد نظام المنتجات المفضلة
# Favorite Products System Setup Guide

## نظرة عامة | Overview

هذا الدليل يشرح كيفية إعداد وتشغيل نظام المنتجات المفضلة في تطبيق iStoreto باستخدام Supabase و GetX.

This guide explains how to set up and operate the favorite products system in iStoreto app using Supabase and GetX.

## 📋 الملفات المطلوبة | Required Files

### 1. SQL Script
- **الملف**: `favorite_products_setup.sql`
- **الوصف**: سكريبت SQL شامل لإعداد الجدول والسياسات والدوال
- **File**: `favorite_products_setup.sql`
- **Description**: Comprehensive SQL script for table, policies, and functions setup

### 2. Controller
- **الملف**: `lib/featured/product/controllers/favorite_product_controller.dart`
- **الوصف**: تحكم GetX لإدارة المنتجات المفضلة
- **File**: `lib/featured/product/controllers/favorite_product_controller.dart`
- **Description**: GetX controller for managing favorite products

## 🗄️ هيكل قاعدة البيانات | Database Structure

### جدول المنتجات المفضلة | Favorite Products Table

```sql
CREATE TABLE favorite_products (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    product_id TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);
```

### المفاتيح الأساسية | Primary Keys
- `id`: معرف فريد للسجل
- `user_id`: معرف المستخدم
- `product_id`: معرف المنتج

### القيود | Constraints
- **فريد**: منع تكرار نفس المنتج لنفس المستخدم
- **مفتاح خارجي**: ربط المستخدم (تم الاحتفاظ به)
- **Cascade Delete**: حذف تلقائي عند حذف المستخدم
- **ملاحظة**: تم إزالة Foreign Key لـ product_id بسبب عدم توافق أنواع البيانات

## 🔒 أمان قاعدة البيانات | Database Security

### Row Level Security (RLS)
تم تفعيل RLS لحماية البيانات:

```sql
-- المستخدم يرى مفضلاته فقط
CREATE POLICY "Users can view their own favorites" ON favorite_products
    FOR SELECT USING (auth.uid() = user_id);

-- المستخدم يضيف لمفضلاته فقط
CREATE POLICY "Users can add to their own favorites" ON favorite_products
    FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### الصلاحيات | Permissions
- **قراءة**: `SELECT` للمستخدمين المصادق عليهم
- **كتابة**: `INSERT, UPDATE, DELETE` للمستخدمين المصادق عليهم
- **دوال**: `EXECUTE` للدوال المساعدة

## 🛠️ الدوال المساعدة | Helper Functions

### 1. `get_user_favorites_count(user_uuid)`
```sql
-- الحصول على عدد المفضلات للمستخدم
SELECT get_user_favorites_count('user-uuid');
```

### 2. `product_exists(product_id)`
```sql
-- التحقق من وجود منتج في قاعدة البيانات
SELECT product_exists('product-id');
```

### 3. `is_product_favorite(user_uuid, product_id)`
```sql
-- التحقق من وجود منتج في المفضلة
SELECT is_product_favorite('user-uuid', 'product-id');
```

### 4. `add_to_favorites(user_uuid, product_id)`
```sql
-- إضافة منتج للمفضلة
SELECT add_to_favorites('user-uuid', 'product-id');
```

### 5. `remove_from_favorites(user_uuid, product_id)`
```sql
-- إزالة منتج من المفضلة
SELECT remove_from_favorites('user-uuid', 'product-id');
```

### 6. `clear_user_favorites(user_uuid)`
```sql
-- مسح جميع المفضلات للمستخدم
SELECT clear_user_favorites('user-uuid');
```

## 📊 العروض | Views

### `user_favorites_with_details`
عرض يجمع المفضلات مع تفاصيل المنتج والتاجر:

```sql
SELECT * FROM user_favorites_with_details 
WHERE user_id = 'user-uuid';
```

**يحتوي على**:
- تفاصيل المنتج (العنوان، الوصف، السعر، الصورة)
- معلومات التاجر (اسم المنظمة)
- تاريخ الإضافة

## ⚡ تحسين الأداء | Performance Optimization

### الفهارس | Indexes
```sql
-- فهرس للمستخدم
CREATE INDEX idx_favorite_products_user_id ON favorite_products(user_id);

-- فهرس للمنتج
CREATE INDEX idx_favorite_products_product_id ON favorite_products(product_id);

-- فهرس مركب للاستعلامات السريعة
CREATE INDEX idx_favorite_products_user_created ON favorite_products(user_id, created_at DESC);
```

### المشغلات | Triggers
```sql
-- تحديث updated_at تلقائياً
CREATE TRIGGER trigger_update_favorite_products_updated_at
    BEFORE UPDATE ON favorite_products
    FOR EACH ROW
    EXECUTE FUNCTION update_favorite_products_updated_at();
```

## 🎯 كيفية الاستخدام | How to Use

### 1. تشغيل SQL Script
```bash
# في Supabase Dashboard
# في قسم SQL Editor
# نسخ ولصق محتوى favorite_products_setup.sql
# تنفيذ السكريبت
```

### 2. استخدام Controller في Flutter
```dart
// الحصول على مثيل Controller
final controller = FavoriteProductsController.instance;

// إضافة منتج للمفضلة
await controller.saveProduct(product);

// إزالة منتج من المفضلة
await controller.removeProduct(product);

// التحقق من وجود منتج في المفضلة
bool isSaved = controller.isSaved(product.id);

// الحصول على قائمة المفضلات
List<ProductModel> favorites = controller.favoriteProducts;

// البحث في المفضلات
controller.searchController.text = "search term";
```

### 3. استخدام في الواجهة
```dart
// زر المفضلة
Obx(() => IconButton(
  icon: Icon(
    controller.isSaved(product.id) 
      ? Icons.favorite 
      : Icons.favorite_border,
    color: controller.isSaved(product.id) 
      ? Colors.red 
      : Colors.grey,
  ),
  onPressed: () {
    if (controller.isSaved(product.id)) {
      controller.removeProduct(product);
    } else {
      controller.saveProduct(product);
    }
  },
))
```

## 🔍 مراقبة الأداء | Performance Monitoring

### استعلامات مفيدة | Useful Queries

```sql
-- عدد المفضلات لكل مستخدم
SELECT 
    user_id, 
    COUNT(*) as favorites_count
FROM favorite_products 
GROUP BY user_id 
ORDER BY favorites_count DESC;

-- أكثر المنتجات إضافة للمفضلة
SELECT 
    product_id, 
    COUNT(*) as times_favorited
FROM favorite_products 
GROUP BY product_id 
ORDER BY times_favorited DESC 
LIMIT 10;

-- المفضلات الجديدة اليوم
SELECT COUNT(*) 
FROM favorite_products 
WHERE created_at >= CURRENT_DATE;
```

## 🧹 صيانة قاعدة البيانات | Database Maintenance

### دوال التنظيف | Cleanup Functions

```sql
-- حذف المفضلات للمنتجات المحذوفة
SELECT cleanup_orphaned_favorites();

-- حذف المفضلات للمستخدمين المحذوفين
SELECT cleanup_deleted_users_favorites();
```

### جدولة الصيانة | Scheduled Maintenance
```sql
-- يمكن جدولة هذه الدوال لتشغيلها دورياً
-- Using pg_cron extension (if available)
SELECT cron.schedule('cleanup-favorites', '0 2 * * *', 'SELECT cleanup_orphaned_favorites();');
```

## 🚨 استكشاف الأخطاء | Troubleshooting

### مشاكل شائعة | Common Issues

#### 1. خطأ RLS Policy
```sql
-- التحقق من السياسات
SELECT * FROM pg_policies WHERE tablename = 'favorite_products';
```

#### 2. خطأ في الفهارس
```sql
-- إعادة بناء الفهارس
REINDEX TABLE favorite_products;
```

#### 3. خطأ في الدوال
```sql
-- التحقق من وجود الدوال
SELECT proname FROM pg_proc WHERE proname LIKE '%favorite%';
```

### سجلات الأخطاء | Error Logs
```dart
// في Flutter - مراقبة الأخطاء
TLoggerHelper.error('Error in favorites: $e');
```

## 📈 إحصائيات الأداء | Performance Statistics

### مؤشرات الأداء الرئيسية | Key Performance Indicators

1. **وقت الاستجابة**: < 100ms للاستعلامات البسيطة
2. **عدد المفضلات**: متوسط 10-50 منتج لكل مستخدم
3. **معدل الإضافة**: تتبع معدل إضافة المنتجات للمفضلة
4. **معدل الحذف**: تتبع معدل حذف المنتجات من المفضلة

### مراقبة الاستعلامات | Query Monitoring
```sql
-- الاستعلامات البطيئة
SELECT query, mean_time, calls 
FROM pg_stat_statements 
WHERE query LIKE '%favorite_products%' 
ORDER BY mean_time DESC;
```

## 🔄 التحديثات المستقبلية | Future Updates

### ميزات مقترحة | Suggested Features

1. **تصنيف المفضلات**: إمكانية إنشاء مجلدات للمفضلات
2. **مشاركة المفضلات**: إمكانية مشاركة قائمة المفضلات
3. **إشعارات**: تنبيهات عند انخفاض سعر منتج مفضل
4. **تحليلات**: إحصائيات مفصلة عن المفضلات

### تحسينات الأداء | Performance Improvements

1. **تخزين مؤقت**: إضافة Redis للتحسين
2. **ضغط البيانات**: ضغط البيانات القديمة
3. **أرشفة**: نقل البيانات القديمة لأرشيف

## 📚 المراجع | References

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Indexes Guide](https://www.postgresql.org/docs/current/indexes.html)
- [GetX State Management](https://github.com/jonataslaw/getx)

## ✅ قائمة التحقق | Checklist

- [ ] تشغيل SQL script
- [ ] التحقق من إنشاء الجدول
- [ ] التحقق من تفعيل RLS
- [ ] اختبار الدوال
- [ ] اختبار Controller في Flutter
- [ ] اختبار الواجهة
- [ ] مراقبة الأداء
- [ ] إعداد النسخ الاحتياطي

---

**ملاحظة**: تأكد من نسخ احتياطي لقاعدة البيانات قبل تشغيل أي سكريبت SQL.

**Note**: Make sure to backup your database before running any SQL script.
