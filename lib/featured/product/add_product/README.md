# نظام إضافة المنتجات

## الملفات المطلوبة

### 1. التحكم (Controller)
- `product_add_controller.dart` - التحكم في إضافة المنتج

### 2. الواجهة (View)
- `product_add_page.dart` - واجهة إضافة المنتج

### 3. البيانات (Data)
- `product_repository.dart` - مستودع البيانات

## الميزات

### ✅ إضافة منتج جديد
- عنوان المنتج (مطلوب)
- وصف المنتج
- السعر (مطلوب)
- الحد الأدنى للكمية
- اختيار الفئة (مطلوب)
- اختيار القسم (اختياري)

### ✅ إدارة الصور
- اختيار عدة صور من الكاميرا أو الاستديو
- اقتصاص الصور بالأبعاد 600×800
- حذف الصور
- رفع الصور إلى الخادم باستخدام `uploadMediaToServer`

### ✅ التحقق من البيانات
- التحقق من الحقول المطلوبة
- عرض رسائل الخطأ
- عرض تقدم رفع الصور

## كيفية الاستخدام

### 1. إضافة التبعيات في pubspec.yaml
```yaml
dependencies:
  image_picker: ^latest_version
  image_cropper: ^latest_version
  get: ^latest_version
```

### 2. استدعاء الصفحة
```dart
import 'package:istoreto/featured/product/add_product/product_add_page.dart';

  
```

### 3. جلب قائمة الفئات والأقسام
يجب تعديل الكود في `product_add_page.dart` لجلب الفئات والأقسام من قاعدة البيانات:

```dart
// في الكنترولر
RxList<CategoryModel> categories = <CategoryModel>[].obs;
RxList<SectionModel> sections = <SectionModel>[].obs;

// جلب الفئات
Future<void> loadCategories() async {
  // استدعاء API أو Firestore
}

// جلب الأقسام
Future<void> loadSections() async {
  // استدعاء API أو Firestore
}
```

## الهيكل

```
lib/ /featured/product/add_product/
├── product_add_controller.dart
├── product_add_page.dart
├── product_repository.dart
└── README.md
```

## ملاحظات مهمة

1. **vendorId**: يجب تعديل `vendorId` في الكنترولر حسب المستخدم الحالي
2. **الترجمة**: يمكن إضافة دعم الترجمة للنصوص
3. **التحقق**: يمكن إضافة المزيد من التحققات حسب الحاجة
4. **الأمان**: تأكد من إضافة التحققات الأمنية المناسبة

## الأخطاء المحتملة وحلولها

### خطأ: UploadResult غير معرف
**الحل**: تأكد من استيراد `upload_result.dart` في الكنترولر

### خطأ: ProductRepository.createProduct غير موجود
**الحل**: تأكد من وجود الدالة في `product_repository.dart`

### خطأ: image_cropper لا يعمل
**الحل**: تأكد من إضافة الأذونات المطلوبة في Android/iOS

## الاستيرادات المطلوبة

```dart
// في الكنترولر
import 'package:istoreto/featured/product/add_product/product_repository.dart';

// في الصفحة
import 'package:istoreto/featured/product/add_product/product_add_controller.dart';
``` 