# حل مشكلة صلاحيات RLS في Supabase

## المشكلة
```
ERROR: 42501: must be owner of table vendor_categories
```

## السبب
المستخدم الحالي ليس مالك جدول `vendor_categories` ولا يملك صلاحيات حذف السياسات.

## الحلول المتاحة

### الحل 1: استخدام الملف الآمن (موصى به)
```sql
-- تشغيل هذا الملف في Supabase SQL Editor
SAFE_FIX_vendor_categories_rls.sql
```

### الحل 2: تعطيل RLS مؤقتاً
```sql
-- تشغيل هذا الملف
disable_rls_temporarily.sql
```

### الحل 3: استخدام CASCADE
```sql
-- تشغيل هذا الملف
cascade_fix_vendor_categories.sql
```

### الحل 4: طلب من المشرف (إذا فشلت الحلول السابقة)
```sql
-- تشغيل هذا الملف بواسطة المشرف
admin_fix_vendor_categories_rls.sql
```

## خطوات التطبيق

### الطريقة 1: في Supabase Dashboard
1. اذهب إلى **Supabase Dashboard**
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ محتوى `SAFE_FIX_vendor_categories_rls.sql`
5. شغل الاستعلام

### الطريقة 2: إذا فشل الحل الأول
1. جرب `disable_rls_temporarily.sql`
2. إذا فشل، جرب `cascade_fix_vendor_categories.sql`
3. إذا فشل كل شيء، اتصل بالمشرف ليشغل `admin_fix_vendor_categories_rls.sql`

## التحقق من النجاح
```sql
-- تشغيل هذا الاستعلام للتحقق
SELECT 
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendor_categories'
ORDER BY policyname;
```

## ما سيتم إصلاحه
- ✅ إزالة القيود المعقدة على الإدراج
- ✅ السماح للمستخدمين المسجلين بإضافة فئات جديدة
- ✅ السماح لجميع المستخدمين بقراءة الفئات النشطة
- ✅ حل مشكلة "must be owner of table"

## ملاحظات مهمة
- جرب الحلول بالترتيب المذكور
- إذا فشل كل شيء، قد تحتاج لطلب مساعدة المشرف
- تأكد من نسخ الاستعلام كاملاً قبل التشغيل



