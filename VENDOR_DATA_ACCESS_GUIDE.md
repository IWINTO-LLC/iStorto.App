# دليل إصلاح قيود الوصول لبيانات التاجر

## المشكلة
- عدم ظهور بيانات التاجر في صفحة المتجر
- فشل في سحب بيانات التاجر من قاعدة البيانات
- أخطاء RLS (Row Level Security) تمنع الوصول للبيانات

## الحل

### 1. تشغيل سكريبت إصلاح RLS

#### في Supabase SQL Editor
```sql
-- تشغيل الملف: fix_vendor_data_access_rls.sql
```

### 2. القيود المطلوب تعديلها

#### أ) جدول `vendors`
- **القراءة العامة**: السماح لجميع المستخدمين بقراءة بيانات التاجر النشط
- **القراءة الخاصة**: السماح للمستخدم بقراءة بياناته الخاصة
- **الإدراج**: السماح للمستخدمين المسجلين بإنشاء تاجر
- **التحديث**: السماح للمستخدم بتحديث بياناته الخاصة
- **الحذف**: السماح للمستخدم بحذف بياناته الخاصة

#### ب) جدول `user_profiles`
- **القراءة**: السماح للمستخدم بقراءة بياناته الخاصة
- **الإدراج**: السماح للمستخدمين المسجلين بإنشاء ملف شخصي
- **التحديث**: السماح للمستخدم بتحديث بياناته الخاصة
- **الحذف**: السماح للمستخدم بحذف بياناته الخاصة

#### ج) جدول `vendor_categories`
- **القراءة العامة**: السماح لجميع المستخدمين بقراءة فئات التاجر النشط
- **القراءة الخاصة**: السماح للتاجر بقراءة فئاته الخاصة
- **الإدراج**: السماح للتاجر بإضافة فئات جديدة
- **التحديث**: السماح للتاجر بتحديث فئاته الخاصة
- **الحذف**: السماح للتاجر بحذف فئاته الخاصة

#### د) جدول `products`
- **القراءة العامة**: السماح لجميع المستخدمين بقراءة منتجات التاجر النشط
- **القراءة الخاصة**: السماح للتاجر بقراءة منتجاته الخاصة
- **الإدراج**: السماح للتاجر بإضافة منتجات جديدة
- **التحديث**: السماح للتاجر بتحديث منتجاته الخاصة
- **الحذف**: السماح للتاجر بحذف منتجاته الخاصة

### 3. التحقق من الإصلاح

#### أ) اختبار سحب بيانات التاجر
```sql
-- اختبار سحب بيانات تاجر محدد
SELECT * FROM vendors 
WHERE id = 'vendor_id_here' 
AND organization_activated = true 
AND organization_deleted = false;
```

#### ب) اختبار سحب فئات التاجر
```sql
-- اختبار سحب فئات تاجر محدد
SELECT * FROM vendor_categories 
WHERE vendor_id = 'vendor_id_here' 
AND is_active = true;
```

#### ج) اختبار سحب منتجات التاجر
```sql
-- اختبار سحب منتجات تاجر محدد
SELECT * FROM products 
WHERE vendor_id = 'vendor_id_here' 
AND is_active = true;
```

### 4. الأخطاء الشائعة وحلولها

#### أ) خطأ "permission denied"
```sql
-- التحقق من حالة RLS
SELECT rowsecurity FROM pg_tables WHERE tablename = 'vendors';

-- التحقق من السياسات
SELECT policyname, cmd, qual FROM pg_policies WHERE tablename = 'vendors';
```

#### ب) خطأ "relation does not exist"
```sql
-- التحقق من وجود الجداول
SELECT tablename FROM pg_tables WHERE tablename IN ('vendors', 'user_profiles', 'vendor_categories', 'products');
```

#### ج) خطأ "policy does not exist"
```sql
-- حذف السياسات القديمة قبل إنشاء جديدة
DROP POLICY IF EXISTS "old_policy_name" ON table_name;
```

### 5. اختبار التطبيق

#### أ) إنشاء حساب تجاري جديد
1. سجل دخول بحساب جديد
2. اذهب إلى صفحة إنشاء الحساب التجاري
3. املأ البيانات واضغط "إنشاء الحساب"
4. تحقق من ظهور صفحة التهاني
5. تحقق من الانتقال إلى صفحة المتجر

#### ب) عرض بيانات التاجر
1. تحقق من ظهور اسم المنظمة
2. تحقق من ظهور الشعار والغلاف
3. تحقق من ظهور الفئات (إن وجدت)
4. تحقق من ظهور المنتجات (إن وجدت)

### 6. مراقبة الأخطاء

#### أ) في التطبيق
- راقب console للأخطاء
- تحقق من رسائل الخطأ في Get.snackbar
- راقب حالة التحميل في VendorController

#### ب) في Supabase
- راقب Logs للأخطاء
- تحقق من Network requests
- راقب Database queries

### 7. نصائح إضافية

#### أ) تحسين الأداء
```sql
-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_vendors_user_id ON vendors(user_id);
CREATE INDEX IF NOT EXISTS idx_vendors_activated ON vendors(organization_activated);
CREATE INDEX IF NOT EXISTS idx_vendor_categories_vendor_id ON vendor_categories(vendor_id);
CREATE INDEX IF NOT EXISTS idx_products_vendor_id ON products(vendor_id);
```

#### ب) الأمان
- تأكد من تفعيل RLS على جميع الجداول
- راجع السياسات بانتظام
- اختبر الوصول من حسابات مختلفة

#### ج) الصيانة
- احتفظ بنسخة احتياطية من السياسات
- وثق أي تغييرات على RLS
- راقب أداء الاستعلامات

## الدعم

إذا واجهت مشاكل:
1. تحقق من [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
2. راجع [PostgreSQL RLS Guide](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
3. تحقق من إعدادات المشروع
4. راجع logs للتطبيق وSupabase
