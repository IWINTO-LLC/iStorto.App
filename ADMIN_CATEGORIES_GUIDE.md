# دليل إدارة الفئات العامة - Admin Categories Management Guide

## نظرة عامة - Overview

تم إنشاء صفحة إدارة شاملة للفئات العامة (`major_categories`) تسمح للمديرين بإضافة وتعديل وحذف الفئات مع إمكانية رفع الصور الدائرية.

A comprehensive admin page has been created for managing major categories (`major_categories`) allowing administrators to add, edit, and delete categories with circular image upload capability.

## الملفات المنشأة - Created Files

### 1. صفحة الإدارة - Admin Page
- `lib/views/admin/admin_categories_page.dart` - الصفحة الرئيسية لإدارة الفئات
- `lib/views/admin/test_admin_categories_page.dart` - صفحة اختبار مبسطة

### 2. الكونترولر - Controller
- `lib/controllers/admin_categories_controller.dart` - منطق إدارة الفئات

### 3. تحديثات قاعدة البيانات - Database Updates
- `lib/data/repositories/major_category_repository.dart` - إضافة دوال CRUD

## المميزات - Features

### ✅ إدارة الفئات - Category Management
- **عرض الفئات** - Display categories in a grid/list view
- **البحث والفلترة** - Search and filter by status
- **إضافة فئة جديدة** - Add new category with form validation
- **تعديل الفئة** - Edit existing category
- **حذف الفئة** - Delete category with confirmation

### ✅ إدارة الصور - Image Management
- **رفع صورة دائرية** - Upload circular images
- **اقتصاص الصور** - Crop images to circle shape
- **اختيار من الكاميرا أو المعرض** - Choose from camera or gallery
- **معاينة الصور** - Image preview
- **حذف الصور** - Remove images

### ✅ إدارة الحالة - Status Management
- **تفعيل/إلغاء تفعيل** - Activate/Deactivate categories
- **جعل مميز/إزالة من المميز** - Make featured/Remove from featured
- **فلترة حسب الحالة** - Filter by status (Active, Pending, Inactive)

### ✅ دعم متعدد اللغات - Multi-language Support
- **العربية والإنجليزية** - Arabic and English support
- **ترجمات شاملة** - Comprehensive translations

## كيفية الاستخدام - How to Use

### 1. الوصول للصفحة - Access the Page
```dart
// في أي مكان في التطبيق - Anywhere in the app
Get.to(() => const TestAdminCategoriesPage());
```

### 2. إضافة فئة جديدة - Add New Category
1. اضغط على زر "+" - Press the "+" button
2. أدخل اسم الفئة بالإنجليزية - Enter category name in English
3. أدخل اسم الفئة بالعربية (اختياري) - Enter category name in Arabic (optional)
4. اختر صورة دائرية - Select circular image
5. اضغط "إضافة" - Press "Add"

### 3. تعديل فئة موجودة - Edit Existing Category
1. اضغط على القائمة (⋮) - Press the menu (⋮)
2. اختر "تعديل" - Choose "Edit"
3. عدّل البيانات المطلوبة - Modify required data
4. اضغط "تحديث" - Press "Update"

### 4. حذف فئة - Delete Category
1. اضغط على القائمة (⋮) - Press the menu (⋮)
2. اختر "حذف" - Choose "Delete"
3. أكد الحذف - Confirm deletion

## التكوين المطلوب - Required Configuration

### 1. قاعدة البيانات - Database
تأكد من تطبيق السكريبت التالي:
Make sure to apply the following script:

```sql
-- تطبيق السكريبت من fix_commercial_setup_major_categories.sql
-- Apply the script from fix_commercial_setup_major_categories.sql
```

### 2. الصلاحيات - Permissions
تأكد من وجود RLS policies صحيحة:
Make sure correct RLS policies exist:

```sql
-- صلاحية القراءة العامة للفئات
-- Public read access for categories
CREATE POLICY "Public read access for major_categories" ON major_categories
FOR SELECT USING (status = 1);

-- صلاحية الكتابة للمستخدمين المصادق عليهم
-- Write access for authenticated users
CREATE POLICY "Authenticated users can manage major_categories" ON major_categories
FOR ALL USING (auth.role() = 'authenticated');
```

### 3. التخزين - Storage
تأكد من وجود bucket للصور:
Make sure images bucket exists:

```sql
-- إنشاء bucket للصور
-- Create images bucket
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true);
```

## الأكواد المطلوبة - Required Code

### 1. إضافة للـ main.dart
```dart
// إضافة الصفحة للروتر
// Add page to router
GetPage(
  name: '/admin-categories',
  page: () => const TestAdminCategoriesPage(),
),
```

### 2. إضافة زر في صفحة الإدارة الرئيسية
```dart
// في صفحة الإدارة الرئيسية
// In main admin page
ListTile(
  leading: const Icon(Icons.category),
  title: const Text('إدارة الفئات'),
  onTap: () => Get.to(() => const TestAdminCategoriesPage()),
),
```

## استكشاف الأخطاء - Troubleshooting

### مشكلة: لا تظهر الفئات - Categories not showing
**الحل:** تأكد من تطبيق سكريبت قاعدة البيانات
**Solution:** Make sure database script is applied

### مشكلة: خطأ في رفع الصور - Image upload error
**الحل:** تأكد من وجود bucket "images" في Supabase Storage
**Solution:** Make sure "images" bucket exists in Supabase Storage

### مشكلة: خطأ في الصلاحيات - Permission error
**الحل:** تأكد من تطبيق RLS policies الصحيحة
**Solution:** Make sure correct RLS policies are applied

## المميزات المستقبلية - Future Features

- [ ] **تصدير/استيراد الفئات** - Export/Import categories
- [ ] **ترتيب الفئات** - Drag and drop reordering
- [ ] **إحصائيات الفئات** - Category statistics
- [ ] **نسخ احتياطي** - Backup functionality
- [ ] **سجل التغييرات** - Change log

## الدعم - Support

إذا واجهت أي مشاكل، تأكد من:
If you encounter any issues, make sure:

1. ✅ تم تطبيق سكريبت قاعدة البيانات
2. ✅ تم إعداد RLS policies
3. ✅ تم إنشاء storage bucket
4. ✅ تم إضافة الترجمات
5. ✅ تم استيراد الكونترولر بشكل صحيح

---

**ملاحظة:** هذه الصفحة مخصصة للمديرين فقط ويجب حمايتها بصلاحيات مناسبة.
**Note:** This page is for administrators only and should be protected with appropriate permissions.
