# العلاقة بين المنتجات والتصنيفات

## البنية الحالية

### جدول المنتجات (products)
```sql
products
├── id (uuid)
├── vendor_id (uuid) → vendors.id
├── title (text)
├── description (text)
├── price (numeric)
├── vendor_category_id (uuid, nullable) → vendor_categories.id
└── ... حقول أخرى
```

### جدول تصنيفات التاجر (vendor_categories)
```sql
vendor_categories
├── id (uuid)
├── vendor_id (uuid) → vendors.id
├── title (text)
├── color (text)
├── icon (text)
├── is_active (boolean)
├── sort_order (integer)
└── timestamps
```

---

## العلاقات

### 1. **Product ← vendor_category_id → VendorCategories**
```
products.vendor_category_id (nullable)
           ↓
vendor_categories.id
```

**ملاحظات مهمة:**
- ✅ `vendor_category_id` **اختياري** (`nullable`)
- ✅ المنتج **قد لا يكون له تصنيف**
- ✅ التصنيف خاص بالتاجر (`vendor_id`)
- ✅ كل تاجر له تصنيفاته الخاصة

### 2. **لا يوجد جدول `categories` عام**
- ❌ لا يوجد جدول `categories` في قاعدة البيانات
- ✅ فقط `vendor_categories` (تصنيفات خاصة بكل تاجر)
- ✅ هذا يعطي مرونة أكبر لكل تاجر

---

## في الكود (ProductModel)

### الحقول:
```dart
class ProductModel {
  String id;
  String? vendorId;
  String title;
  String? vendorCategoryId;  // ✅ اختياري (nullable)
  CategoryModel? category;    // ✅ اختياري (nullable) - للاستخدام المؤقت
  // ...
}
```

### في toJson():
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'vendor_id': vendorId,
    'vendor_category_id': vendorCategoryId,  // ✅ قد يكون null
    // ...
  };
}
```

### في fromJson():
```dart
static ProductModel fromJson(Map<String, dynamic> data) {
  return ProductModel(
    id: data['id'] ?? '',
    vendorId: data['vendor_id'],
    vendorCategoryId: data['vendor_category_id'],  // ✅ قد يكون null
    category: data['category'] != null
        ? CategoryModel.fromJson(data['category'])
        : null,  // ✅ قد يكون null
    // ...
  );
}
```

---

## حالات الاستخدام

### 1. **منتج بدون تصنيف** ✅
```dart
ProductModel(
  id: 'product_1',
  vendorId: 'vendor_1',
  title: 'منتج بدون تصنيف',
  vendorCategoryId: null,  // ✅ مسموح
  // ...
)
```

**في قاعدة البيانات:**
```sql
INSERT INTO products (id, vendor_id, title, vendor_category_id)
VALUES ('product_1', 'vendor_1', 'منتج', NULL);  -- ✅ مسموح
```

### 2. **منتج مع تصنيف** ✅
```dart
ProductModel(
  id: 'product_2',
  vendorId: 'vendor_1',
  title: 'منتج مع تصنيف',
  vendorCategoryId: 'category_1',  // ✅ تصنيف التاجر
  // ...
)
```

**في قاعدة البيانات:**
```sql
INSERT INTO products (id, vendor_id, title, vendor_category_id)
VALUES ('product_2', 'vendor_1', 'منتج', 'category_1');
```

---

## في واجهة المستخدم

### عرض المنتجات حسب التصنيف:
```dart
// في VendorCategoriesWidget
void _onCategoryTap(dynamic category) {
  final productController = ProductController.instance;
  productController.selectCategory(category, vendorId);
}

// في ProductController
void selectCategory(category, vendorId) {
  // جلب المنتجات التي vendor_category_id = category.id
  // أو جلب جميع المنتجات إذا كان "الكل"
}
```

### عرض المنتجات بدون تصنيف:
```dart
// Query للمنتجات بدون تصنيف
SELECT * FROM products 
WHERE vendor_id = 'vendor_1' 
AND vendor_category_id IS NULL;
```

---

## المميزات

### ✅ **مرونة للتاجر:**
- كل تاجر ينشئ تصنيفاته الخاصة
- لا قيود على عدد أو نوع التصنيفات
- التاجر يختار الألوان والأيقونات

### ✅ **اختياري:**
- المنتج قد يكون بدون تصنيف
- مفيد للمنتجات الجديدة أو المؤقتة
- لا إجبار على التصنيف

### ✅ **أداء:**
- Indexes على `vendor_id` و `vendor_category_id`
- بحث سريع بالتصنيف
- GIN index للبحث النصي

---

## SQL Queries مفيدة

### 1. جلب منتجات تصنيف معين:
```sql
SELECT p.* 
FROM products p
WHERE p.vendor_id = 'vendor_id_here'
  AND p.vendor_category_id = 'category_id_here'
  AND p.is_deleted = false;
```

### 2. جلب منتجات بدون تصنيف:
```sql
SELECT p.* 
FROM products p
WHERE p.vendor_id = 'vendor_id_here'
  AND p.vendor_category_id IS NULL
  AND p.is_deleted = false;
```

### 3. جلب جميع منتجات التاجر:
```sql
SELECT p.* 
FROM products p
WHERE p.vendor_id = 'vendor_id_here'
  AND p.is_deleted = false;
```

### 4. جلب المنتجات مع التصنيف (JOIN):
```sql
SELECT 
  p.*,
  vc.title as category_title,
  vc.color as category_color,
  vc.icon as category_icon
FROM products p
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id
WHERE p.vendor_id = 'vendor_id_here'
  AND p.is_deleted = false;
```

---

## في التطبيق

### عند إضافة منتج:
```dart
// المستخدم يختار تصنيف (اختياري)
ProductModel newProduct = ProductModel(
  id: generateId(),
  vendorId: currentVendor.id,
  title: 'منتج جديد',
  vendorCategoryId: selectedCategory?.id,  // ✅ قد يكون null
  // ...
);

await productRepository.addProduct(newProduct);
```

### عند عرض المنتجات:
```dart
// فلترة حسب التصنيف
if (selectedCategoryId != null) {
  products = allProducts.where(
    (p) => p.vendorCategoryId == selectedCategoryId,
  ).toList();
} else {
  // عرض جميع المنتجات
  products = allProducts;
}
```

### عند البحث:
```dart
// البحث في جميع المنتجات بغض النظر عن التصنيف
products = await productRepository.searchProducts(
  vendorId: vendorId,
  query: searchQuery,
  // لا حاجة لـ categoryId
);
```

---

## RLS Policies

### للمنتجات:
```sql
-- القراءة: الجميع يمكنهم رؤية المنتجات النشطة
CREATE POLICY "Allow public read access to active products"
ON products FOR SELECT
USING (is_deleted = false);

-- الإدراج: فقط التاجر صاحب المنتج
CREATE POLICY "Allow vendors to insert their products"
ON products FOR INSERT
WITH CHECK (
  auth.uid() = (SELECT user_id FROM vendors WHERE id = vendor_id)
);

-- التعديل: فقط التاجر صاحب المنتج
CREATE POLICY "Allow vendors to update their products"
ON products FOR UPDATE
USING (
  auth.uid() = (SELECT user_id FROM vendors WHERE id = vendor_id)
);
```

### للتصنيفات:
```sql
-- القراءة: الجميع يمكنهم رؤية التصنيفات النشطة
CREATE POLICY "Allow public read access to active vendor categories"
ON vendor_categories FOR SELECT
USING (is_active = true);

-- الإدراج/التعديل: فقط التاجر
CREATE POLICY "Allow vendors to manage their categories"
ON vendor_categories FOR ALL
USING (
  auth.uid() = (SELECT user_id FROM vendors WHERE id = vendor_id)
);
```

---

## الملخص

### العلاقات:
```
vendors (1) ←→ (many) vendor_categories
vendors (1) ←→ (many) products
vendor_categories (1) ←→ (many) products [optional]
```

### النقاط المهمة:
1. ✅ `vendor_category_id` **اختياري** في `products`
2. ✅ **لا يوجد** جدول `categories` عام
3. ✅ كل تاجر له **تصنيفاته الخاصة**
4. ✅ المنتج **قد لا يكون له تصنيف**
5. ✅ `CategoryModel` في الكود **للاستخدام المؤقت فقط**

### الفوائد:
- ✅ **مرونة** كاملة لكل تاجر
- ✅ **بساطة** في إضافة المنتجات
- ✅ **لا إجبار** على التصنيف
- ✅ **أداء** ممتاز مع الـ indexes

---

**تاريخ التوثيق:** October 12, 2025
**الحالة:** ✅ موثق بالكامل

