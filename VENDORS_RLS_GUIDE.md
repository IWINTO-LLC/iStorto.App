# دليل إصلاح سياسات الأمان لجدول vendors

## المشكلة
```
forbidden for table vendor add new row
```

## السبب
- جدول `vendors` مفعل عليه Row Level Security (RLS)
- لا توجد سياسات أمان تسمح بإدراج صفوف جديدة
- المستخدم لا يملك صلاحية إدراج بيانات في الجدول

## الحل

### 1. تنفيذ SQL لإصلاح السياسات

#### من خلال Supabase Dashboard
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ والصق محتوى `fix_vendors_table_rls.sql`
5. اضغط **Run**

### 2. السياسات المُنشأة

#### سياسة القراءة
```sql
CREATE POLICY "Users can view their own vendor" ON vendors
FOR SELECT USING (auth.uid() = user_id);
```
- **الغرض**: المستخدمون يمكنهم رؤية vendor الخاص بهم فقط
- **الشرط**: `auth.uid() = user_id`

#### سياسة الإدراج
```sql
CREATE POLICY "Users can insert their own vendor" ON vendors
FOR INSERT WITH CHECK (auth.uid() = user_id);
```
- **الغرض**: المستخدمون يمكنهم إدراج vendor جديد
- **الشرط**: `auth.uid() = user_id`

#### سياسة التحديث
```sql
CREATE POLICY "Users can update their own vendor" ON vendors
FOR UPDATE USING (auth.uid() = user_id);
```
- **الغرض**: المستخدمون يمكنهم تحديث vendor الخاص بهم
- **الشرط**: `auth.uid() = user_id`

#### سياسة الحذف
```sql
CREATE POLICY "Users can delete their own vendor" ON vendors
FOR DELETE USING (auth.uid() = user_id);
```
- **الغرض**: المستخدمون يمكنهم حذف vendor الخاص بهم
- **الشرط**: `auth.uid() = user_id`

### 3. التحقق من الإعداد

#### من خلال Dashboard
1. اذهب إلى **Authentication** > **Policies**
2. ابحث عن جدول `vendors`
3. تأكد من وجود السياسات الأربع

#### من خلال SQL
```sql
-- عرض جميع السياسات لجدول vendors
SELECT * FROM pg_policies WHERE tablename = 'vendors';
```

### 4. اختبار الوظيفة

#### في التطبيق
1. شغل التطبيق
2. سجل دخول بحساب صحيح
3. اذهب إلى صفحة إنشاء الحساب التجاري
4. املأ البيانات
5. اضغط "Create Account"

#### النتيجة المتوقعة
- ✅ يتم إنشاء vendor بنجاح
- ✅ يتم تحديث `account_type` في `user_profiles`
- ✅ لا تظهر أخطاء "forbidden"

### 5. استكشاف الأخطاء

#### إذا ظهر "forbidden" مرة أخرى
- تأكد من تسجيل دخول المستخدم
- تأكد من أن `user_id` في البيانات يطابق `auth.uid()`
- تحقق من وجود السياسات

#### إذا ظهر "relation does not exist"
- تأكد من وجود جدول `vendors`
- تحقق من اسم الجدول (case-sensitive)

#### إذا ظهر "permission denied"
- تأكد من تفعيل RLS على الجدول
- تحقق من صحة السياسات

### 6. إعدادات إضافية

#### للقراءة العامة (اختياري)
```sql
-- إذا كنت تريد عرض vendors للجميع
CREATE POLICY "Public can view active vendors" ON vendors
FOR SELECT USING (organization_activated = true);
```

#### للقراءة المحدودة
```sql
-- إذا كنت تريد عرض vendors للمستخدمين المسجلين فقط
CREATE POLICY "Authenticated users can view vendors" ON vendors
FOR SELECT USING (auth.role() = 'authenticated');
```

### 7. ملاحظات مهمة

1. **الأمان**: تأكد من أن السياسات تحمي البيانات
2. **الأداء**: استخدم فهارس على `user_id` لتحسين الأداء
3. **الاختبار**: اختبر جميع العمليات (إدراج، تحديث، حذف)
4. **المراقبة**: راقب سجلات الأخطاء

## الدعم

إذا واجهت مشاكل:
1. تحقق من [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
2. راجع [RLS Examples](https://supabase.com/docs/guides/auth/row-level-security#examples)
3. تحقق من إعدادات المشروع في Dashboard
