# دليل صفحة إدارة منتجات التاجر
# Vendor Products Management Page Guide

---

**التاريخ | Date:** October 11, 2025  
**الإصدار | Version:** 1.0.0  
**الحالة | Status:** ✅ Complete

---

## 📖 نظرة عامة | Overview

تم إنشاء نظام متكامل لإدارة منتجات التاجر مع صفحتين رئيسيتين:

1. **صفحة إدارة المنتجات** - لعرض وإدارة المنتجات الموجودة
2. **صفحة إضافة منتج** - لإضافة منتجات جديدة

النظام مدمج في `vendor_admin_zone.dart` ومشابه تماماً لإدارة الفئات والبنرات.

---

## 🎯 الملفات المُنشأة | Created Files

### 1. Controller
```
lib/controllers/vendor_products_management_controller.dart
```

**المسؤوليات:**
- جلب منتجات التاجر (نشطة ومحذوفة)
- البحث في المنتجات
- الفلترة حسب الحالة (all/active/deleted)
- حذف منتج (soft delete)
- استعادة منتج محذوف
- حذف نهائي للمنتج

### 2. صفحة الإدارة
```
lib/views/vendor/vendor_products_management_page.dart
```

**المميزات:**
- عرض جميع المنتجات
- شريط بحث
- فلترة حسب الحالة
- بطاقات منتجات جميلة
- زر FAB لإضافة منتج جديد
- خيارات المنتج (edit/delete/restore)

### 3. صفحة الإضافة
```
lib/views/vendor/add_product_page.dart
```

**المميزات:**
- 4 أقسام منظمة
- خيار "بدون تصنيف"
- اختيار Section
- حساب تلقائي للأسعار
- إدارة الصور

### 4. التكامل
```
lib/views/vendor/vendor_admin_zone.dart (محدث)
```

---

## 🚀 كيفية الوصول | How to Access

### من Vendor Admin Zone:

```
Vendor Admin Zone
  ↓
إدارة المنتجات (Products Management)
  ↓
┌──────────────────────────────┐
│ Products Management Page     │
│  • Search products           │
│  • Filter (all/active/deleted)│
│  • View product details      │
│  • Delete/Restore products   │
│  • [+] Add New Product       │
└──────────────────────────────┘
  ↓ (Click Add)
┌──────────────────────────────┐
│ Add Product Page             │
│  • Basic info                │
│  • Category & Section        │
│  • Pricing                   │
│  • Images                    │
│  • [Save] button             │
└──────────────────────────────┘
```

---

## ✨ المميزات التفصيلية | Detailed Features

### 1. **صفحة إدارة المنتجات**

#### البحث والفلترة:
```dart
// البحث
🔍 Search Box → يبحث في الاسم والوصف

// الفلترة
🔘 All Products     - جميع المنتجات
🔘 Active Products  - المنتجات النشطة فقط
🔘 Deleted Products - المنتجات المحذوفة فقط
```

#### بطاقة المنتج:
```
┌────────────────────────────────┐
│ [صورة]  اسم المنتج      [✓ نشط]│
│          الوصف...              │
│          120 USD     [⋮ خيارات] │
└────────────────────────────────┘
```

#### خيارات المنتج:

**للمنتجات النشطة:**
- ✏️ تعديل المنتج (Edit)
- 🗑️ حذف المنتج (Delete - soft delete)

**للمنتجات المحذوفة:**
- ↺ استعادة المنتج (Restore)
- ⚠️ حذف نهائي (Delete Permanently)

---

### 2. **صفحة إضافة المنتج**

#### الأقسام الأربعة:

**1. المعلومات الأساسية:**
- اسم المنتج (مطلوب)
- الوصف (اختياري)
- الحد الأدنى للكمية (مطلوب)

**2. التصنيف والقسم:**
- التصنيف:
  - **"بدون تصنيف"** ← خيار خاص
  - فئات التاجر
  - [+] إنشاء فئة جديدة
- القسم:
  - All Products
  - Offers
  - Sales
  - New Arrival
  - Featured

**3. التسعير:**
- سعر البيع (مطلوب)
- نسبة الخصم (اختياري - حساب تلقائي)
- السعر الأصلي (اختياري - حساب تلقائي)

**4. الصور:**
- 📷 Camera
- 🖼️ Gallery
- معاينة وحذف

---

## 🎨 التصميم | Design

### Page Layout:

```
┌─────────────────────────────────────┐
│ ← Products Management     [🔄]      │ AppBar
├─────────────────────────────────────┤
│ [🔍 Search...           ] [≡ Filter]│ Search Bar
├─────────────────────────────────────┤
│ 📦 Found 15 products                │ Count
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [img] Product Name        [✓]   │ │
│ │       Description...      ⋮     │ │
│ │       120 USD                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [img] Another Product     [✓]   │ │
│ │       ...                   ⋮   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ...                                 │
│                                     │
└─────────────────────────────────────┘
                  [➕ Add New Product]    FAB
```

### Color Scheme:

- **Background:** `Colors.grey.shade50`
- **Cards:** `Colors.white`
- **Primary:** `TColors.primary`
- **Active Status:** `Colors.green`
- **Deleted Status:** `Colors.red`

---

## 🔄 دورة العمل | Workflow

### 1. عرض المنتجات:

```
Load Page
  ↓
controller.loadVendorProducts(vendorId)
  ↓
ProductRepository.getAllProducts(vendorId)
  ↓
Display products in list
  ↓
User can: Search, Filter, View details
```

### 2. إضافة منتج:

```
Click FAB
  ↓
Navigate to AddProductPage
  ↓
User fills form
  ↓
Click Save
  ↓
Validate & Upload
  ↓
Navigate back + Reload list
```

### 3. حذف منتج:

```
Click ⋮ → Delete
  ↓
Confirm dialog
  ↓
Soft delete (is_deleted = true)
  ↓
Update local list
  ↓
Show success message
```

### 4. استعادة منتج:

```
Filter to "Deleted"
  ↓
Click ⋮ → Restore
  ↓
Update is_deleted = false
  ↓
Move to active list
  ↓
Show success message
```

---

## 📊 الإحصائيات | Statistics

### قبل التحديث:
- ❌ لا توجد صفحة إدارة منتجات
- ❌ Coming Soon placeholder
- ❌ لا يمكن عرض/تعديل/حذف المنتجات

### بعد التحديث:
- ✅ صفحة إدارة كاملة
- ✅ صفحة إضافة حديثة
- ✅ بحث وفلترة
- ✅ حذف واستعادة
- ✅ تصميم احترافي
- ✅ ترجمة كاملة

---

## 🌍 Localization | الترجمة

### مفاتيح الترجمة المُضافة (24 key):

```dart
// Page titles
'products_management'
'add_new_product'

// Search & Filter
'search_products_placeholder'
'all_products'
'active_products'
'deleted_products'

// Actions
'delete_product'
'delete_product_confirmation'
'restore_product'
'edit_product'
'delete_permanently'
'permanently_delete_product'
'permanently_delete_warning'

// Messages
'product_deleted_successfully'
'product_restored_successfully'
'product_permanently_deleted'
'failed_to_delete_product'
'failed_to_restore_product'
'failed_to_delete_permanently'
'add_first_product'
'no_results_found'

// Status
'active'
'deleted'
```

**Coverage:** ✅ 100% - English & Arabic

---

## 🎯 أمثلة الاستخدام | Usage Examples

### Example 1: From Vendor Admin Zone

```dart
// المستخدم يضغط على "إدارة المنتجات"
VendorAdminZone
  ↓ (tap)
VendorProductsManagementPage(vendorId: 'vendor_123')
```

### Example 2: Direct Navigation

```dart
// من أي مكان في التطبيق
final authController = Get.find<AuthController>();
final vendorId = authController.currentUser.value?.vendorId;

if (vendorId != null) {
  Get.to(() => VendorProductsManagementPage(vendorId: vendorId));
}
```

### Example 3: With Callback

```dart
// عند الحاجة لتحديث قائمة معينة بعد الإضافة
final result = await Get.to(() => AddProductPage(vendorId: vendorId));

if (result == true) {
  // تم إضافة منتج جديد
  _refreshProductsList();
}
```

---

## 🔧 Functions Reference | مرجع الوظائف

### VendorProductsManagementController:

```dart
// تحميل المنتجات
loadVendorProducts(String vendorId)

// البحث
searchProducts(String query)

// الفلترة
filterByStatus(String status)  // 'all' | 'active' | 'deleted'

// الحذف
deleteProduct(ProductModel product)  // Soft delete

// الاستعادة
restoreProduct(ProductModel product)  // من المحذوفات

// الحذف النهائي
permanentlyDeleteProduct(ProductModel product)  // لا يمكن التراجع

// عرض الخيارات
showProductOptions(BuildContext context, ProductModel product)
```

---

## 📝 ملاحظات مهمة | Important Notes

### 1. **Soft Delete vs Permanent Delete**

**Soft Delete:**
- يغير `is_deleted` إلى `true`
- المنتج يبقى في قاعدة البيانات
- يمكن استعادته
- يظهر في فلتر "Deleted Products"

**Permanent Delete:**
- يحذف السجل نهائياً من قاعدة البيانات
- **لا يمكن التراجع**
- يحتاج تأكيد مزدوج

### 2. **Product Status Chip**

```dart
// نشط (Active)
[✓ Active] → Green background

// محذوف (Deleted)
[🗑 Deleted] → Red background
```

### 3. **Integration Points**

الصفحة متكاملة مع:
- ✅ `ProductController` - لإنشاء المنتجات
- ✅ `ProductRepository` - لجلب المنتجات
- ✅ `VendorCategoryRepository` - للفئات
- ✅ `AddProductPage` - لإضافة منتجات جديدة
- ✅ `ProductDetailsPage` - لعرض التفاصيل

---

## 🧪 Testing | الاختبار

### Test Scenarios:

#### Test 1: Load Products
```
1. Open vendor admin zone
2. Click "إدارة المنتجات"
3. Wait for products to load
✅ Should show: All vendor products
```

#### Test 2: Search Products
```
1. Type in search box
2. Products filter in real-time
✅ Should show: Matching products only
```

#### Test 3: Filter by Status
```
1. Click filter button
2. Select "Active Products"
✅ Should show: Only active products

3. Select "Deleted Products"
✅ Should show: Only deleted products
```

#### Test 4: Delete Product
```
1. Click ⋮ on a product
2. Click "حذف المنتج"
3. Confirm deletion
✅ Product marked as deleted
✅ Moves to "Deleted Products" filter
```

#### Test 5: Restore Product
```
1. Filter to "Deleted Products"
2. Click ⋮ on deleted product
3. Click "استعادة المنتج"
✅ Product restored
✅ Moves back to active products
```

#### Test 6: Add New Product
```
1. Click [+] FAB
2. Fill product form
3. Add images
4. Click Save
✅ Navigate to AddProductPage
✅ Product created
✅ Navigate back
✅ List refreshed automatically
```

---

## 🎨 UI Components | مكونات الواجهة

### Product Card:

```dart
┌─────────────────────────────────────┐
│ ┌──────┐  Product Title      [✓]    │
│ │ IMG  │  Description...             │
│ │80x80 │  120 USD            [⋮]    │
│ └──────┘                             │
└─────────────────────────────────────┘
```

### Search & Filter Bar:

```dart
┌─────────────────────────────────────┐
│ [🔍 Search products...] [≡ Filter] │
└─────────────────────────────────────┘
```

### Filter Menu:

```dart
┌───────────────────┐
│ ☑ All Products    │
│ ○ Active Products │
│ ○ Deleted Products│
└───────────────────┘
```

### Product Options (Bottom Sheet):

```dart
┌──────────────────────────┐
│      Product Title       │
│ ─────────────────────── │
│ ✏️ Edit Product         │
│ 🗑️ Delete Product       │
│    (or)                  │
│ ↺ Restore Product       │
│ ⚠️ Delete Permanently   │
└──────────────────────────┘
```

---

## 🔄 Data Flow | تدفق البيانات

### Load Products:

```
VendorProductsManagementPage
  ↓
controller.loadVendorProducts(vendorId)
  ↓
ProductRepository.getAllProducts(vendorId)
  ↓
Supabase: SELECT * FROM products WHERE vendor_id = ?
  ↓
allProducts = results
  ↓
_applyFilters()
  ↓
filteredProducts = filtered results
  ↓
UI updates (Obx)
```

### Search:

```
User types in search box
  ↓
onChanged → controller.searchProducts(query)
  ↓
searchQuery.value = query
  ↓
_applyFilters()
  ↓
Filter allProducts by title/description
  ↓
filteredProducts updated
  ↓
UI refreshes
```

### Delete Product:

```
User clicks Delete
  ↓
Show confirmation dialog
  ↓
User confirms
  ↓
repository.deleteProduct(id)
  ↓
Supabase: UPDATE products SET is_deleted = true WHERE id = ?
  ↓
Update local allProducts list
  ↓
_applyFilters()
  ↓
Show success message
```

---

## 📱 Screenshots Flow | تدفق الشاشات

```
1. Vendor Admin Zone
   ┌──────────────────────┐
   │ 🏪 Welcome           │
   │ ──────────────────── │
   │ 📢 Banners          →│
   │ 📦 Products         →│ ← New!
   │ 📁 Categories       →│
   │ 🛒 Orders           →│
   │ ⚙️ Settings         →│
   └──────────────────────┘

2. Products Management
   ┌──────────────────────┐
   │ ← Products Management│ [🔄]
   │ ──────────────────── │
   │ [🔍 Search] [Filter]│
   │ 📦 Found 15 products │
   │ ──────────────────── │
   │ [Product Card]       │
   │ [Product Card]       │
   │ [Product Card]       │
   │        ...           │
   │                 [+]  │
   └──────────────────────┘

3. Add Product (on FAB click)
   ┌──────────────────────┐
   │ ← Add New Product [✓]│
   │ ──────────────────── │
   │ 📝 Basic Info        │
   │ 🗂️ Category & Section│
   │ 💰 Pricing           │
   │ 📷 Images            │
   │ ──────────────────── │
   │ [Save Product]       │
   └──────────────────────┘
```

---

## 🔧 Customization | التخصيص

### إضافة filters إضافية:

```dart
// في Controller
final RxString categoryFilter = ''.obs;

void filterByCategory(String categoryId) {
  categoryFilter.value = categoryId;
  _applyFilters();
}

// في _applyFilters()
if (categoryFilter.value.isNotEmpty) {
  results = results.where((p) => 
    p.vendorCategoryId == categoryFilter.value
  ).toList();
}
```

### إضافة sorting:

```dart
// في Controller
final RxString sortBy = 'date'.obs;

void sort(String by) {
  sortBy.value = by;
  _applySorting();
}

void _applySorting() {
  switch (sortBy.value) {
    case 'price_high':
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      break;
    case 'price_low':
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      break;
    case 'date':
      filteredProducts.sort((a, b) => 
        (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now())
      );
      break;
  }
}
```

---

## 🐛 Troubleshooting | حل المشاكل

### المشكلة: المنتجات لا تُحمل

**الحل:**
```sql
-- تحقق من RLS policies في Supabase
SELECT * FROM products WHERE vendor_id = 'YOUR_VENDOR_ID';

-- تحقق من أن ProductRepository مُهيأ
Get.put(ProductRepository());
```

### المشكلة: الحذف لا يعمل

**الحل:**
```sql
-- تحقق من RLS policy للحذف
-- يجب أن تسمح للتاجر بتحديث منتجاته
```

### المشكلة: زر الإضافة لا يعمل

**الحل:**
```dart
// تأكد من أن AddProductPage موجودة
import 'package:istoreto/views/vendor/add_product_page.dart';

// تحقق من vendorId صحيح
debugPrint('VendorId: $vendorId');
```

---

## 🎯 Integration في vendor_admin_zone | التكامل

**قبل:**
```dart
_buildManagementCard(
  icon: Icons.inventory,
  title: 'vendor_admin_zone_products'.tr,
  onTap: () {
    Get.snackbar('Coming Soon', '...');  // ❌
  },
),
```

**بعد:**
```dart
_buildManagementCard(
  icon: Icons.inventory,
  title: 'vendor_admin_zone_products'.tr,
  onTap: () => Get.to(
    () => VendorProductsManagementPage(vendorId: vendorId),  // ✅
  ),
),
```

---

## ✅ Checklist | قائمة المراجعة

### Code:
- [x] Controller created
- [x] Management page created
- [x] Add product page created
- [x] Integrated in vendor_admin_zone
- [x] All imports added
- [x] No lint errors

### Translations:
- [x] English keys (24)
- [x] Arabic keys (24)
- [x] No hardcoded strings

### Features:
- [x] Load products
- [x] Search products
- [x] Filter by status
- [x] Delete product (soft)
- [x] Restore product
- [x] Delete permanently
- [x] Add new product
- [x] View product details
- [x] Refresh functionality

### UI/UX:
- [x] Loading states
- [x] Empty states
- [x] Success messages
- [x] Error messages
- [x] Confirmation dialogs
- [x] Smooth transitions

---

## 🎉 Summary | الخلاصة

تم إنشاء نظام إدارة منتجات متكامل مع:

✅ **صفحتين رئيسيتين:**
- صفحة إدارة المنتجات (Management)
- صفحة إضافة منتج (Add)

✅ **مميزات كاملة:**
- بحث وفلترة
- حذف واستعادة
- حذف نهائي
- إضافة منتجات جديدة

✅ **تصميم احترافي:**
- مشابه لإدارة البنرات والفئات
- واجهة نظيفة وبسيطة
- تجربة مستخدم ممتازة

✅ **Integration:**
- متكامل في Vendor Admin Zone
- يعمل مع جميع الأنظمة الموجودة
- بدون أخطاء

**Status:** ✅ **Ready for Production!**

---

**Created by:** AI Assistant  
**Last Updated:** October 11, 2025  
**Version:** 1.0.0

