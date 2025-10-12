# Dynamic Product Grid Widget - دليل الاستخدام

## نظرة عامة

تم إنشاء `DynamicProductGridWidget` كنسخة محسنة ومرنة من `SectorBuilderJustImg` يمكنها استقبال قائمة المنتجات مباشرة دون الحاجة لتحميل البيانات من قاعدة البيانات.

## الميزات الرئيسية

### 1. مرونة في العرض
- **عرض منتجات مخصصة**: يمكن تمرير أي قائمة منتجات
- **أحجام مختلفة**: دعم أحجام مختلفة للكروت
- **وضع التحرير**: دعم وضع التحرير مع أزرار الإضافة
- **مؤشر النقاط**: مؤشر النقاط للتنقل بين المنتجات

### 2. خيارات التخصيص
- **العناوين**: إمكانية إظهار/إخفاء العناوين
- **الحشو**: تخصيص المسافات والحشو
- **الترجمة**: إمكانية تفعيل/تعطيل الترجمة
- **أزرار الفلوتنج**: أزرار مخصصة في وضع التحرير

### 3. Callbacks مخصصة
- **onProductTap**: سلوك مخصص عند النقر على المنتج
- **onAddProduct**: سلوك مخصص عند إضافة منتج جديد

## كيفية الاستخدام

### الاستخدام الأساسي

```dart
DynamicProductGridWidget(
  vendorId: 'vendor1',
  editMode: false,
  cardWidth: 45.w,
  cardHeight: 60.w,
  products: myProductsList,
  withTitle: true,
  sectionTitle: 'المنتجات المميزة',
  sectorName: 'featured',
)
```

### الاستخدام في وضع التحرير

```dart
DynamicProductGridWidget(
  vendorId: 'vendor1',
  editMode: true,
  cardWidth: 40.w,
  cardHeight: 55.w,
  products: myProductsList,
  withTitle: true,
  sectionTitle: 'إدارة المنتجات',
  sectorName: 'manage',
  showEmptyAddButtons: true,
  showFloatingButtons: true,
  onAddProduct: () {
    // منطق إضافة منتج مخصص
    print('إضافة منتج جديد');
  },
)
```

### الاستخدام مع Callbacks مخصصة

```dart
DynamicProductGridWidget(
  vendorId: 'vendor1',
  editMode: false,
  cardWidth: 45.w,
  cardHeight: 60.w,
  products: myProductsList,
  onProductTap: (product, index) {
    // سلوك مخصص عند النقر على المنتج
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.title ?? 'منتج'),
        content: Text('تم النقر على المنتج في الفهرس $index'),
      ),
    );
  },
)
```

## المعاملات (Parameters)

### المعاملات المطلوبة
- `vendorId`: معرف التاجر
- `editMode`: وضع التحرير (true/false)
- `cardWidth`: عرض الكرت
- `cardHeight`: ارتفاع الكرت
- `products`: قائمة المنتجات

### المعاملات الاختيارية
- `withTitle`: إظهار العنوان (افتراضي: true)
- `withPadding`: إضافة حشو (افتراضي: true)
- `sectionTitle`: عنوان القسم
- `showEmptyAddButtons`: إظهار أزرار الإضافة الفارغة (افتراضي: false)
- `sectorName`: اسم القطاع
- `onProductTap`: callback للنقر على المنتج
- `onAddProduct`: callback لإضافة منتج
- `showDotsIndicator`: إظهار مؤشر النقاط (افتراضي: true)
- `showFloatingButtons`: إظهار أزرار الفلوتنج (افتراضي: true)
- `enableTranslation`: تفعيل الترجمة (افتراضي: true)

## أمثلة متقدمة

### عرض منتجات صغيرة

```dart
DynamicProductGridWidget(
  vendorId: 'vendor1',
  editMode: false,
  cardWidth: 25.w,
  cardHeight: 35.w,
  products: smallProductsList,
  withTitle: false,
  showDotsIndicator: false,
  enableTranslation: false,
)
```

### عرض منتجات بدون عناوين

```dart
DynamicProductGridWidget(
  vendorId: 'vendor1',
  editMode: false,
  cardWidth: 50.w,
  cardHeight: 70.w,
  products: productsList,
  withTitle: false,
  withPadding: false,
  showDotsIndicator: true,
)
```

### عرض قائمة فارغة مع أزرار إضافة

```dart
DynamicProductGridWidget(
  vendorId: 'vendor1',
  editMode: true,
  cardWidth: 45.w,
  cardHeight: 60.w,
  products: [], // قائمة فارغة
  withTitle: true,
  sectionTitle: 'لا توجد منتجات',
  showEmptyAddButtons: true,
  showFloatingButtons: true,
)
```

## الفروق عن SectorBuilderJustImg الأصلي

### المزايا
1. **مرونة أكبر**: يمكن استخدامه مع أي قائمة منتجات
2. **أداء أفضل**: لا يحتاج لتحميل البيانات من قاعدة البيانات
3. **تخصيص أكثر**: خيارات أكثر للتحكم في العرض
4. **Callbacks مخصصة**: إمكانية تخصيص السلوك
5. **كود أنظف**: بنية أكثر تنظيماً

### الاستخدامات المناسبة
- عرض منتجات من API خارجي
- عرض منتجات محفوظة محلياً
- عرض منتجات مختلطة من مصادر مختلفة
- إنشاء واجهات مخصصة للمنتجات

## الملفات المرتبطة

1. **الملف الرئيسي**: `dynamic_product_grid_widget.dart`
2. **أمثلة الاستخدام**: `dynamic_product_grid_example.dart`
3. **الملف الأصلي**: `sector_builder_just_img.dart`

## نصائح للاستخدام

1. **اختيار الحجم المناسب**: استخدم `cardWidth` و `cardHeight` المناسب للمحتوى
2. **تحسين الأداء**: استخدم `enableTranslation: false` إذا لم تحتج للترجمة
3. **التخصيص**: استخدم callbacks لتخصيص السلوك حسب احتياجاتك
4. **وضع التحرير**: فعّل `showEmptyAddButtons` و `showFloatingButtons` في وضع التحرير
5. **مؤشر النقاط**: استخدم `showDotsIndicator` للقوائم الطويلة

## الدعم والمساهمة

هذا الـ widget قابل للتطوير والتخصيص. يمكن إضافة ميزات جديدة حسب الحاجة مثل:
- دعم أنواع كروت مختلفة
- إضافة فلاتر للمنتجات
- دعم البحث داخل القائمة
- إضافة تأثيرات انتقالية مخصصة
