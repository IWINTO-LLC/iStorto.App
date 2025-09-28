-- سكريبت لإعداد Supabase Storage لرفع الصور

-- 1. إنشاء bucket للصور
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. إنشاء سياسات الأمان للـ bucket

-- السياسة للقراءة العامة
CREATE POLICY "Public read access" ON storage.objects
FOR SELECT USING (bucket_id = 'images');

-- السياسة للكتابة (المستخدمين المسجلين فقط)
CREATE POLICY "Authenticated users can upload images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);

-- السياسة للتحديث (المستخدمين المسجلين فقط)
CREATE POLICY "Authenticated users can update images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);

-- السياسة للحذف (المستخدمين المسجلين فقط)
CREATE POLICY "Authenticated users can delete images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);

-- 3. فحص الـ bucket
SELECT * FROM storage.buckets WHERE id = 'images';

-- 4. فحص السياسات
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 5. اختبار الرفع (اختياري)
-- يمكنك اختبار رفع صورة من التطبيق بعد تشغيل هذا السكريبت

-- 6. ملاحظات مهمة
-- تأكد من أن:
-- - Bucket 'images' تم إنشاؤه
-- - السياسات مطبقة بشكل صحيح
-- - الـ RLS مفعّل على storage.objects
-- - المستخدمون المسجلون يمكنهم رفع الصور
-- - الجميع يمكنهم قراءة الصور (public access)
