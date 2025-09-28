# دليل إعداد Supabase Storage

## المشكلة
```
StorageException(message: bucket not found)
```

## الحل

### 1. إنشاء Storage Bucket

#### الطريقة الأولى: من خلال Supabase Dashboard
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **Storage** في القائمة الجانبية
4. اضغط على **New bucket**
5. أدخل:
   - **Name**: `images`
   - **Public bucket**: ✅ (مفعل)
   - **File size limit**: `50 MB`
   - **Allowed MIME types**: `image/jpeg, image/png, image/gif, image/webp`

#### الطريقة الثانية: من خلال SQL Editor
1. اذهب إلى **SQL Editor** في Supabase Dashboard
2. انسخ والصق محتوى `setup_storage_bucket.sql`
3. اضغط **Run**

### 2. إعداد سياسات الأمان (RLS Policies)

#### سياسات القراءة
```sql
-- القراءة العامة للصور
CREATE POLICY "Public read access for images" ON storage.objects
FOR SELECT USING (bucket_id = 'images');
```

#### سياسات الكتابة
```sql
-- رفع الصور للمستخدمين المسجلين
CREATE POLICY "Authenticated users can upload images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
```

#### سياسات التحديث
```sql
-- تحديث الصور للمستخدمين المسجلين
CREATE POLICY "Authenticated users can update their images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
```

#### سياسات الحذف
```sql
-- حذف الصور للمستخدمين المسجلين
CREATE POLICY "Authenticated users can delete their images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
```

### 3. التحقق من الإعداد

#### من خلال Dashboard
1. اذهب إلى **Storage** > **images**
2. تأكد من وجود الـ bucket
3. جرب رفع صورة تجريبية

#### من خلال التطبيق
1. شغل التطبيق
2. اذهب إلى صفحة إنشاء الحساب التجاري
3. جرب رفع صورة للوغو أو الغلاف

### 4. استكشاف الأخطاء

#### إذا ظهر خطأ "bucket not found"
- تأكد من إنشاء الـ bucket بالاسم الصحيح: `images`
- تأكد من تفعيل **Public bucket**

#### إذا ظهر خطأ "permission denied"
- تأكد من إنشاء سياسات RLS
- تأكد من تسجيل دخول المستخدم

#### إذا ظهر خطأ "file too large"
- تأكد من أن حجم الملف أقل من 50MB
- تأكد من نوع الملف المدعوم

### 5. إعدادات إضافية

#### أنواع الملفات المدعومة
- `image/jpeg`
- `image/png`
- `image/gif`
- `image/webp`

#### حد حجم الملف
- الافتراضي: 50MB
- يمكن تغييره حسب الحاجة

#### إعدادات الأمان
- القراءة: عامة (للجميع)
- الكتابة: للمستخدمين المسجلين فقط
- التحديث: للمستخدمين المسجلين فقط
- الحذف: للمستخدمين المسجلين فقط

## ملاحظات مهمة

1. **الأمان**: تأكد من أن سياسات RLS تعمل بشكل صحيح
2. **الأداء**: استخدم ضغط الصور لتقليل حجم الملفات
3. **التخزين**: راقب استخدام التخزين لتجنب تجاوز الحدود
4. **النسخ الاحتياطي**: احتفظ بنسخ احتياطية من الصور المهمة

## الدعم

إذا واجهت مشاكل:
1. تحقق من [Supabase Documentation](https://supabase.com/docs/guides/storage)
2. راجع [Storage API Reference](https://supabase.com/docs/reference/dart/storage)
3. تحقق من إعدادات المشروع في Dashboard
