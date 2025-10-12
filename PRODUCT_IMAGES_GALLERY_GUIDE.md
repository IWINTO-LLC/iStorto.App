# 📸 دليل معرض صور المنتجات
# Product Images Gallery Guide

---

## 🎯 نظرة عامة

نظام كامل لعرض جميع صور المنتجات في شبكة Masonry جميلة، مع إمكانية البحث والنقر للانتقال لتفاصيل المنتج.

---

## 📁 الملفات المُنشأة

### 1. SQL Script:
- ✅ `create_product_images_table.sql`

### 2. Model:
- ✅ `lib/models/product_image_model.dart`

### 3. Repository:
- ✅ `lib/data/repositories/product_image_repository.dart`

### 4. Controller:
- ✅ `lib/controllers/product_images_gallery_controller.dart`

### 5. View:
- ✅ `lib/views/product_images_gallery_page.dart`

---

## 🗄️ قاعدة البيانات

### جدول product_images:

```sql
CREATE TABLE public.product_images (
    id UUID PRIMARY KEY,
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0,
    is_thumbnail BOOLEAN DEFAULT false,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### الحقول:
- `id` - معرف فريد للصورة
- `product_id` - معرف المنتج
- `image_url` - رابط الصورة في Supabase Storage
- `image_order` - ترتيب الصورة (0, 1, 2, ...)
- `is_thumbnail` - هل هي الصورة الرئيسية
- `created_at` - تاريخ الإضافة
- `updated_at` - تاريخ آخر تحديث

### View - product_images_gallery:

```sql
SELECT 
    pi.id,
    pi.product_id,
    pi.image_url,
    p.title AS product_title,
    p.price AS product_price,
    p.old_price AS product_old_price,
    v.organization_name AS vendor_name
FROM product_images pi
JOIN products p ON pi.product_id = p.id
JOIN vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false;
```

---

## 🔧 الدوال المتاحة

### 1. add_product_images():
```sql
-- إضافة صور لمنتج
SELECT add_product_images(
    'product-id',
    ARRAY['url1', 'url2', 'url3']
);
```

### 2. get_product_images():
```sql
-- الحصول على صور منتج
SELECT * FROM get_product_images('product-id');
```

### 3. get_all_product_images():
```sql
-- الحصول على جميع الصور (مع pagination)
SELECT * FROM get_all_product_images(50, 0);
```

---

## 💻 الاستخدام في Flutter

### فتح المعرض:

```dart
import 'package:istoreto/views/product_images_gallery_page.dart';

// معرض جميع الصور
Get.to(() => ProductImagesGalleryPage());

// صور تاجر معين
Get.to(() => ProductImagesGalleryPage(vendorId: 'vendor-123'));
```

### إضافة صور عند إنشاء منتج:

```dart
// في ProductController أو AddProductPage
Future<void> createProductWithImages({
  required String productId,
  required List<String> imageUrls,
}) async {
  // 1. إنشاء المنتج
  await productRepository.createProduct(...);
  
  // 2. إضافة الصور في product_images
  final imageRepo = Get.find<ProductImageRepository>();
  await imageRepo.addProductImages(
    productId: productId,
    imageUrls: imageUrls,
  );
}
```

### البحث في الصور:

```dart
final controller = Get.find<ProductImagesGalleryController>();

// بحث
controller.searchImages('هاتف');

// مسح البحث
controller.clearSearch();
```

---

## 🎨 المميزات

### 1. Masonry Grid Layout:
- ✅ شبكة جميلة غير منتظمة
- ✅ عمودين
- ✅ مسافات متساوية
- ✅ تصميم عصري

### 2. البحث:
- ✅ بحث في اسم المنتج
- ✅ بحث في اسم التاجر
- ✅ نتائج فورية

### 3. التفاعل:
- ✅ النقر على الصورة → تفاصيل المنتج
- ✅ Hero animation
- ✅ Smooth transitions

### 4. الأداء:
- ✅ Lazy loading (تحميل تدريجي)
- ✅ Pagination (50 صورة في المرة)
- ✅ Pull to refresh
- ✅ Infinite scroll

### 5. Loading States:
- ✅ Shimmer effect
- ✅ حالة فارغة
- ✅ مؤشر تحميل المزيد

---

## 📊 أمثلة الاستخدام

### 1. في الصفحة الرئيسية:

```dart
// زر لفتح معرض الصور
ElevatedButton.icon(
  onPressed: () => Get.to(() => ProductImagesGalleryPage()),
  icon: Icon(Icons.photo_library),
  label: Text('معرض صور المنتجات'),
)
```

### 2. في صفحة التاجر:

```dart
// زر لعرض صور منتجات التاجر فقط
IconButton(
  icon: Icon(Icons.collections),
  onPressed: () => Get.to(
    () => ProductImagesGalleryPage(vendorId: vendor.id),
  ),
)
```

### 3. في Navigation Menu:

```dart
ListTile(
  leading: Icon(Icons.photo_library),
  title: Text('معرض الصور'),
  onTap: () => Get.to(() => ProductImagesGalleryPage()),
)
```

---

## 🔄 المزامنة التلقائية

### Trigger يعمل تلقائياً:

عند إضافة منتج جديد أو تحديث صوره:
```
1. المنتج يُضاف/يُحدث في products
   ↓
2. Trigger يكتشف تغيير images[]
   ↓
3. يحذف الصور القديمة من product_images
   ↓
4. يضيف الصور الجديدة
   ↓
5. المعرض يتحدث تلقائياً ✅
```

---

## 🧪 الاختبار

### في Supabase:

```sql
-- عرض جميع الصور
SELECT * FROM public.product_images ORDER BY created_at DESC LIMIT 10;

-- عرض المعرض
SELECT * FROM public.product_images_gallery LIMIT 10;

-- اختبار إضافة صور
SELECT add_product_images(
    'product-id',
    ARRAY[
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg'
    ]
);
```

### في Flutter:

```dart
// فتح المعرض
Get.to(() => ProductImagesGalleryPage());

// يجب أن ترى شبكة صور جميلة ✅
```

---

## 📈 الإحصائيات

### استعلامات مفيدة:

```sql
-- عدد الصور الكلي
SELECT COUNT(*) FROM public.product_images;

-- عدد المنتجات التي لها صور
SELECT COUNT(DISTINCT product_id) FROM public.product_images;

-- متوسط عدد الصور لكل منتج
SELECT AVG(image_count) FROM (
    SELECT product_id, COUNT(*) AS image_count
    FROM public.product_images
    GROUP BY product_id
) AS counts;

-- أكثر المنتجات صوراً
SELECT 
    p.title,
    COUNT(pi.id) AS images_count
FROM public.products p
JOIN public.product_images pi ON p.id = pi.product_id
GROUP BY p.id, p.title
ORDER BY images_count DESC
LIMIT 10;
```

---

## 🎨 التخصيص

### تغيير عدد الأعمدة:

```dart
MasonryGridView.count(
  crossAxisCount: 3,  // 3 أعمدة بدلاً من 2
  ...
)
```

### تغيير عدد الصور المحملة:

```dart
class ProductImagesGalleryController {
  final int itemsPerPage = 100;  // 100 بدلاً من 50
}
```

### إضافة فلاتر:

```dart
// مثال: فلتر حسب السعر
Future<void> filterByPrice(double minPrice, double maxPrice) async {
  filteredImages.value = allImages.where((img) {
    return img.productPrice != null &&
           img.productPrice! >= minPrice &&
           img.productPrice! <= maxPrice;
  }).toList();
}
```

---

## 🔧 خطوات التثبيت

### 1. تنفيذ SQL في Supabase:

```
1. افتح Supabase Dashboard
2. SQL Editor → New Query
3. انسخ محتوى: create_product_images_table.sql
4. الصق وشغّل (RUN)
5. انتظر: ✅ تم إعداد نظام صور المنتجات بنجاح!
```

### 2. استخدام في Flutter:

```dart
// في أي مكان في التطبيق
import 'package:istoreto/views/product_images_gallery_page.dart';

// فتح المعرض
Get.to(() => ProductImagesGalleryPage());
```

---

## 📱 لقطات الشاشة المتوقعة

```
┌─────────────────────────────┐
│  🔍 البحث في الصور...      │
├──────────┬──────────────────┤
│  صورة 1  │  صورة 2 (أطول)  │
│  منتج A  │  منتج B          │
│  99 SAR  │  149 SAR         │
├──────────┼──────────────────┤
│ صورة 3   │  صورة 4          │
│ (أطول)  │  منتج D          │
│ منتج C   │  79 SAR          │
│ 199 SAR  │                  │
├──────────┼──────────────────┤
│  صورة 5  │  صورة 6 (أطول)  │
│  ...     │  ...             │
└──────────┴──────────────────┘
```

---

## 🎁 ميزات إضافية

### إضافة زر للمعرض في الصفحة الرئيسية:

```dart
// في home_page.dart
Container(
  margin: EdgeInsets.all(16),
  child: ElevatedButton.icon(
    onPressed: () => Get.to(() => ProductImagesGalleryPage()),
    icon: Icon(Icons.photo_library),
    label: Text('معرض صور المنتجات 📸'),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
)
```

### عداد الصور:

```dart
FutureBuilder<int>(
  future: ProductImageRepository.instance
      .getAllProductImages(limit: 1)
      .then((list) => list.length),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Badge(
        label: Text('${snapshot.data}'),
        child: Icon(Icons.photo_library),
      );
    }
    return Icon(Icons.photo_library);
  },
)
```

---

## 🎉 الخلاصة

### تم إنشاء:
✅ جدول `product_images` في Supabase
✅ 3 دوال SQL مساعدة
✅ View للمعرض
✅ 2 Triggers تلقائية
✅ 4 RLS Policies
✅ Model كامل
✅ Repository شامل
✅ Controller متقدم
✅ صفحة Masonry جميلة

### النتيجة:
🎊 **معرض صور احترافي بتصميم Masonry!**

---

## 📚 الخطوات التالية

1. ✅ نفذ `create_product_images_table.sql` في Supabase
2. ✅ استخدم `ProductImagesGalleryPage` في تطبيقك
3. ✅ استمتع بالمعرض الجميل!

---

**🚀 جاهز للاستخدام!**


