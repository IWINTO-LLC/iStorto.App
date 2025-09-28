-- إنشاء bucket للصور
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images',
  'images',
  true,
  52428800, -- 50MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
);

-- سياسات الأمان للقراءة العامة
CREATE POLICY "Public read access for images" ON storage.objects
FOR SELECT USING (bucket_id = 'images');

-- سياسات الأمان للكتابة للمستخدمين المسجلين
CREATE POLICY "Authenticated users can upload images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);

-- سياسات الأمان للتحديث للمستخدمين المسجلين
CREATE POLICY "Authenticated users can update their images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);

-- سياسات الأمان للحذف للمستخدمين المسجلين
CREATE POLICY "Authenticated users can delete their images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
