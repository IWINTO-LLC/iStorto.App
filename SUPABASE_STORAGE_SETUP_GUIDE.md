# دليل إعداد Supabase Storage لرفع الصور

## التحديثات المُطبقة

### 1. في `lib/controllers/initial_commercial_controller.dart`
- ✅ إضافة متغيرات التحميل: `isUploading`, `uploadProgress`
- ✅ دالة `uploadImageToStorage()` لرفع الصور
- ✅ تحديث `saveCommercialAccount()` لرفع الصور أولاً
- ✅ مؤشر التقدم أثناء الرفع

### 2. في `lib/services/supabase_service.dart`
- ✅ دالة `uploadImageToStorage()` لرفع الصور إلى Supabase Storage
- ✅ دالة `deleteImageFromStorage()` لحذف الصور
- ✅ إدارة الأخطاء والاستجابات

### 3. في `lib/views/initial_commercial_page.dart`
- ✅ مؤشر التقدم أثناء الرفع
- ✅ عرض نسبة التقدم في المئة

## إعداد Supabase Storage

### 1. إنشاء Storage Bucket

#### في Supabase Dashboard
1. اذهب إلى **Storage** في القائمة الجانبية
2. اضغط **New bucket**
3. أدخل:
   - **Name**: `images`
   - **Public bucket**: ✅ مفعّل
   - **File size limit**: `50 MB` (أو حسب الحاجة)
   - **Allowed MIME types**: `image/*`

### 2. إعداد السياسات (Policies)

#### الطريقة الأولى: من Dashboard
1. اذهب إلى **Storage** > **Policies**
2. اضغط **New Policy**
3. أنشئ السياسات التالية:

##### سياسة القراءة العامة
```sql
CREATE POLICY "Public read access" ON storage.objects
FOR SELECT USING (bucket_id = 'images');
```

##### سياسة الكتابة للمستخدمين المسجلين
```sql
CREATE POLICY "Authenticated users can upload images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
```

##### سياسة التحديث للمستخدمين المسجلين
```sql
CREATE POLICY "Authenticated users can update images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
```

##### سياسة الحذف للمستخدمين المسجلين
```sql
CREATE POLICY "Authenticated users can delete images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);
```

#### الطريقة الثانية: سكريبت SQL
```sql
-- انسخ والصق محتوى setup_supabase_storage.sql
```

### 3. اختبار الإعداد

#### فحص الـ Bucket
```sql
SELECT * FROM storage.buckets WHERE id = 'images';
```

#### فحص السياسات
```sql
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
```

## كيفية عمل النظام

### 1. اختيار الصورة
```dart
// المستخدم يختار صورة من الكاميرا أو المعرض
final image = await ImagePicker().pickImage(source: ImageSource.camera);
```

### 2. رفع الصورة
```dart
// رفع الصورة إلى Supabase Storage
final result = await supabaseService.uploadImageToStorage(
  bytes, 
  'vendor-logos/unique-filename.jpg'
);
```

### 3. الحصول على الرابط
```dart
// الحصول على الرابط العام للصورة
final imageUrl = result['url'];
```

### 4. حفظ البيانات
```dart
// حفظ بيانات البائع مع رابط الصورة
final vendorData = {
  'organization_logo': imageUrl,
  // ... باقي البيانات
};
```

## تدفق العمل

### 1. إنشاء الحساب التجاري
```
المستخدم يملأ البيانات → يختار الصور → يضغط "Create Account"
```

### 2. رفع الصور
```
بداية الرفع (0%) → رفع الشعار (30%) → رفع الغلاف (70%) → اكتمال الرفع (90%)
```

### 3. حفظ البيانات
```
حفظ بيانات البائع → تحديث نوع الحساب → اكتمال العملية (100%)
```

## إدارة الملفات

### هيكل المجلدات
```
images/
├── vendor-logos/
│   ├── 1703123456789_logo.jpg
│   └── 1703123456790_logo.png
└── vendor-covers/
    ├── 1703123456789_cover.jpg
    └── 1703123456790_cover.png
```

### تسمية الملفات
```dart
// تنسيق: timestamp_filename
final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
```

## معالجة الأخطاء

### 1. أخطاء الرفع
```dart
try {
  final result = await uploadImageToStorage(image, path);
  if (!result['success']) {
    throw Exception(result['message']);
  }
} catch (e) {
  // عرض رسالة خطأ للمستخدم
  Get.snackbar('Error', e.toString());
}
```

### 2. أخطاء الشبكة
```dart
// إعادة المحاولة عند فشل الشبكة
if (e.toString().contains('network')) {
  // إعادة المحاولة
}
```

### 3. أخطاء الحجم
```dart
// التحقق من حجم الصورة قبل الرفع
if (bytes.length > 5 * 1024 * 1024) { // 5MB
  throw Exception('Image too large');
}
```

## تحسينات مستقبلية

### 1. ضغط الصور
```dart
// ضغط الصور قبل الرفع
final compressedImage = await FlutterImageCompress.compressWithList(
  bytes,
  minHeight: 1024,
  minWidth: 1024,
  quality: 80,
);
```

### 2. معاينة الصور
```dart
// عرض معاينة للصورة قبل الرفع
Widget buildImagePreview(XFile image) {
  return Image.file(File(image.path));
}
```

### 3. حذف الصور القديمة
```dart
// حذف الصور القديمة عند تحديث الصورة
if (oldImageUrl.isNotEmpty) {
  await deleteImageFromStorage(oldImagePath);
}
```

## استكشاف الأخطاء

### 1. لا يمكن رفع الصور
- تحقق من إعدادات الـ bucket
- تحقق من السياسات
- تحقق من صلاحيات المستخدم

### 2. الصور لا تظهر
- تحقق من أن الـ bucket عام
- تحقق من الروابط العامة
- تحقق من تنسيق الملفات

### 3. أخطاء في التطبيق
- تحقق من الاستيرادات
- تحقق من صلاحيات التطبيق
- تحقق من إعدادات الشبكة

---

## الخلاصة

تم إعداد نظام رفع الصور بنجاح:

1. **الرفع**: الصور تُرفع إلى Supabase Storage
2. **التقدم**: مؤشر تقدم أثناء الرفع
3. **الروابط**: حفظ روابط الصور في قاعدة البيانات
4. **الأمان**: سياسات أمان للتحكم في الوصول
5. **الأخطاء**: معالجة شاملة للأخطاء

النظام جاهز للاستخدام!
