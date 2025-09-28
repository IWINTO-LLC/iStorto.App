# دليل إصلاح قيود جدول vendors مع الاعتماديات

## المشكلة
```
ERROR: 2BP01: cannot drop constraint vendors_pkey on table vendors because other objects depend on it

DETAIL: constraint vendor_categories_vendor_id_fkey on table vendor_categories depends on index vendors_pkey
constraint products_vendor_id_fkey on table products depends on index vendors_pkey
constraint orders_vendor_id_fkey on table orders depends on index vendors_pkey
constraint user_follows_vendor_id_fkey on table user_follows depends on index vendors_pkey
constraint vendor_statistics_vendor_id_fkey on table vendor_statistics depends on index vendors_pkey
constraint temp_products_vendor_id_fkey on table temp_products depends on index vendors_pkey
```

## السبب
- جدول `vendors` له قيد أساسي `vendors_pkey`
- جداول أخرى تعتمد على هذا القيد عبر قيود خارجية
- لا يمكن حذف القيد الأساسي بدون حذف القيود الخارجية أولاً

## الحل

### 1. تنفيذ SQL لإصلاح القيود

#### من خلال Supabase Dashboard
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ والصق محتوى `fix_vendor_constraints_with_dependencies.sql`
5. اضغط **Run**

### 2. الخطوات المُطبقة

#### حذف القيود الخارجية
```sql
ALTER TABLE vendor_categories DROP CONSTRAINT IF EXISTS vendor_categories_vendor_id_fkey;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_vendor_id_fkey;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_vendor_id_fkey;
ALTER TABLE user_follows DROP CONSTRAINT IF EXISTS user_follows_vendor_id_fkey;
ALTER TABLE vendor_statistics DROP CONSTRAINT IF EXISTS vendor_statistics_vendor_id_fkey;
ALTER TABLE temp_products DROP CONSTRAINT IF EXISTS temp_products_vendor_id_fkey;
```

#### حذف القيد الأساسي
```sql
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS vendors_pkey;
```

#### تعديل عمود id
```sql
ALTER TABLE vendors ALTER COLUMN id SET DEFAULT gen_random_uuid();
```

#### إعادة إنشاء القيد الأساسي
```sql
ALTER TABLE vendors ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);
```

#### إعادة إنشاء القيود الخارجية
```sql
ALTER TABLE vendor_categories 
ADD CONSTRAINT vendor_categories_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

ALTER TABLE products 
ADD CONSTRAINT products_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE;

-- ... باقي القيود
```

### 3. الجداول المتأثرة

#### الجداول التي تعتمد على vendors
- `vendor_categories` - فئات البائعين
- `products` - المنتجات
- `orders` - الطلبات
- `user_follows` - متابعة المستخدمين للبائعين
- `vendor_statistics` - إحصائيات البائعين
- `temp_products` - المنتجات المؤقتة

#### القيود الخارجية
- جميع القيود تستخدم `ON DELETE CASCADE`
- عند حذف vendor، يتم حذف البيانات المرتبطة تلقائياً

### 4. التحقق من الإعداد

#### فحص إعدادات عمود id
```sql
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'vendors' 
AND column_name = 'id';
```

#### فحص القيود الخارجية
```sql
SELECT 
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'vendors'
ORDER BY tc.table_name, tc.constraint_name;
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
- ✅ لا تظهر أخطاء "constraint violation"
- ✅ يتم تحديث `account_type` في `user_profiles`

### 6. استكشاف الأخطاء

#### إذا ظهر "constraint violation"
- تأكد من تنفيذ SQL بنجاح
- تحقق من وجود القيود الخارجية
- تأكد من أن البيانات متسقة

#### إذا ظهر "permission denied"
- تأكد من صلاحيات قاعدة البيانات
- تحقق من أن المستخدم لديه صلاحية ALTER TABLE

#### إذا ظهر "relation does not exist"
- تأكد من وجود جميع الجداول
- تحقق من أسماء الجداول (case-sensitive)

### 7. إعدادات إضافية

#### للتحقق من سلامة البيانات
```sql
-- فحص عدد الصفوف في كل جدول
SELECT 'vendors' as table_name, COUNT(*) as row_count FROM vendors
UNION ALL
SELECT 'vendor_categories', COUNT(*) FROM vendor_categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'user_follows', COUNT(*) FROM user_follows
UNION ALL
SELECT 'vendor_statistics', COUNT(*) FROM vendor_statistics
UNION ALL
SELECT 'temp_products', COUNT(*) FROM temp_products;
```

#### للتحقق من القيود
```sql
-- عرض جميع القيود لجدول vendors
SELECT 
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'vendors'::regclass;
```

### 8. ملاحظات مهمة

1. **الأمان**: القيود الخارجية تحافظ على سلامة البيانات
2. **الأداء**: استخدم فهارس على `vendor_id` في الجداول المرتبطة
3. **الاختبار**: اختبر إنشاء وحذف vendors
4. **المراقبة**: راقب سجلات الأخطاء

## الدعم

إذا واجهت مشاكل:
1. تحقق من [PostgreSQL Foreign Key Documentation](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK)
2. راجع [Supabase Database Documentation](https://supabase.com/docs/guides/database)
3. تحقق من إعدادات المشروع في Dashboard
