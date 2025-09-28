# دليل إصلاح توليد ID تلقائياً في جدول vendors

## المشكلة
```
null value in id column
```

## السبب
- عمود `id` في جدول `vendors` لا يتولّد تلقائياً
- يتم إرسال `null` في حقل `id` عند إنشاء vendor جديد
- قاعدة البيانات ترفض إدراج صف مع `id` فارغ

## الحل

### 1. تنفيذ SQL لإصلاح التوليد التلقائي

#### من خلال Supabase Dashboard
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ والصق محتوى `fix_vendor_id_auto_generation.sql`
5. اضغط **Run**

### 2. التعديلات المُطبقة

#### إزالة القيود الموجودة
```sql
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS vendors_pkey;
```

#### تعيين التوليد التلقائي
```sql
ALTER TABLE vendors ALTER COLUMN id SET DEFAULT gen_random_uuid();
```

#### إضافة القيد الأساسي
```sql
ALTER TABLE vendors ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);
```

#### التأكد من عدم قبول NULL
```sql
ALTER TABLE vendors ALTER COLUMN id SET NOT NULL;
```

### 3. تحديث VendorModel

#### في `vendor_model.dart`
```dart
Map<String, dynamic> toJson() {
  final Map<String, dynamic> json = {
    'user_id': userId,
    'organization_name': organizationName,
    // ... باقي الحقول
  };
  
  // Only include id if it's not null
  if (id != null) {
    json['id'] = id;
  }
  
  return json;
}
```

### 4. التحقق من الإعداد

#### من خلال SQL
```sql
-- فحص إعدادات عمود id
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'vendors' 
AND column_name = 'id';
```

#### النتيجة المتوقعة
```
column_name | data_type | is_nullable | column_default
id         | uuid      | NO          | gen_random_uuid()
```

### 5. اختبار الوظيفة

#### في التطبيق
1. شغل التطبيق
2. سجل دخول بحساب صحيح
3. اذهب إلى صفحة إنشاء الحساب التجاري
4. املأ البيانات:
   - Organization Name
   - Organization Slug
   - Organization Bio
   - Organization Logo (اختياري)
   - Organization Cover (اختياري)
5. اضغط "Create Account"

#### النتيجة المتوقعة
- ✅ يتم توليد `id` تلقائياً
- ✅ يتم إنشاء vendor بنجاح
- ✅ لا تظهر أخطاء "null value in id column"
- ✅ يتم تحديث `account_type` في `user_profiles`

### 6. استكشاف الأخطاء

#### إذا ظهر "null value in id column" مرة أخرى
- تأكد من تنفيذ SQL بنجاح
- تحقق من أن `column_default` = `gen_random_uuid()`
- تأكد من أن `is_nullable` = `NO`

#### إذا ظهر "permission denied"
- تأكد من صلاحيات قاعدة البيانات
- تحقق من أن المستخدم لديه صلاحية ALTER TABLE

#### إذا ظهر "constraint violation"
- تأكد من عدم وجود بيانات مكررة
- تحقق من القيود الأخرى على الجدول

### 7. إعدادات إضافية

#### للتحقق من التوليد التلقائي
```sql
-- إدراج vendor جديد بدون تحديد id
INSERT INTO vendors (user_id, organization_name, slugn)
VALUES (
  'your-user-id-here',
  'Test Organization',
  'test-org-' || extract(epoch from now())::text
);

-- فحص الـ id المُولّد
SELECT id, organization_name FROM vendors 
WHERE organization_name = 'Test Organization';
```

#### لحذف البيانات التجريبية
```sql
-- حذف vendor تجريبي
DELETE FROM vendors WHERE organization_name = 'Test Organization';
```

### 8. ملاحظات مهمة

1. **الأمان**: UUIDs أكثر أماناً من الأرقام المتسلسلة
2. **الأداء**: استخدم فهارس على `id` لتحسين الأداء
3. **الاختبار**: اختبر إنشاء vendors متعددة
4. **المراقبة**: راقب سجلات الأخطاء

## الدعم

إذا واجهت مشاكل:
1. تحقق من [PostgreSQL UUID Documentation](https://www.postgresql.org/docs/current/datatype-uuid.html)
2. راجع [Supabase Database Documentation](https://supabase.com/docs/guides/database)
3. تحقق من إعدادات المشروع في Dashboard
