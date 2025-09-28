# دليل نظام الفئات المتعددة للتجار (Many-to-Many)

## نظرة عامة
تصميم نظام يسمح للتاجر باختيار عدة فئات رئيسية للتخصص فيها، مع إمكانية تحديد فئة أساسية وأولويات مختلفة.

## الهيكل المقترح

### 1. الجداول

#### أ) جدول `major_categories` (موجود بالفعل)
```sql
CREATE TABLE major_categories (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    arabic_name VARCHAR(255),
    image VARCHAR(500),
    is_feature BOOLEAN DEFAULT false,
    status INTEGER DEFAULT 2, -- 1: Active, 2: Pending, 3: Inactive
    parent_id UUID REFERENCES major_categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### ب) جدول `vendor_major_categories` (جدول الربط)
```sql
CREATE TABLE vendor_major_categories (
    id UUID PRIMARY KEY,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    major_category_id UUID REFERENCES major_categories(id) ON DELETE CASCADE,
    
    -- إعدادات التخصص
    is_primary BOOLEAN DEFAULT false, -- الفئة الأساسية
    priority INTEGER DEFAULT 0, -- الأولوية (0 = أعلى أولوية)
    specialization_level INTEGER DEFAULT 1, -- مستوى التخصص (1-5)
    custom_description TEXT, -- وصف مخصص
    is_active BOOLEAN DEFAULT true, -- تفعيل/إلغاء التخصص
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_vendor_category UNIQUE(vendor_id, major_category_id),
    CONSTRAINT valid_specialization_level CHECK (specialization_level BETWEEN 1 AND 5)
);
```

### 2. الميزات

#### أ) التخصص المتعدد
- التاجر يمكنه اختيار عدة فئات
- كل فئة لها مستوى تخصص (1-5)
- وصف مخصص لكل فئة

#### ب) الفئة الأساسية
- فئة واحدة فقط يمكن أن تكون أساسية
- الفئة الأساسية تظهر أولاً في الملف الشخصي
- تحديث تلقائي عند تغيير الفئة الأساسية

#### ج) نظام الأولويات
- ترتيب الفئات حسب الأولوية
- إمكانية تغيير الأولويات
- عرض الفئات حسب الأولوية

#### د) إدارة الحالة
- تفعيل/إلغاء تفعيل الفئات
- إمكانية إضافة/حذف فئات
- تتبع التغييرات

### 3. النماذج (Models)

#### أ) `VendorCategoryModel`
```dart
class VendorCategoryModel {
  String? id;
  String vendorId;
  String majorCategoryId;
  bool isPrimary;
  int priority;
  int specializationLevel; // 1-5
  String? customDescription;
  bool isActive;
  MajorCategoryModel? majorCategory; // العلاقة
}
```

#### ب) `AddVendorCategoryRequest`
```dart
class AddVendorCategoryRequest {
  String vendorId;
  String majorCategoryId;
  bool isPrimary;
  int priority;
  int specializationLevel;
  String? customDescription;
}
```

### 4. الوظائف الأساسية

#### أ) إضافة فئة جديدة
```dart
Future<VendorCategoryModel> addVendorCategory(
  AddVendorCategoryRequest request,
) async {
  // إدراج فئة جديدة للتاجر
}
```

#### ب) الحصول على فئات التاجر
```dart
Future<List<VendorCategoryModel>> getVendorCategories(
  String vendorId,
) async {
  // جلب جميع فئات التاجر مع التفاصيل
}
```

#### ج) تحديث الأولويات
```dart
Future<bool> updateCategoryPriorities(
  UpdateCategoryPrioritiesRequest request,
) async {
  // تحديث ترتيب الأولويات
}
```

#### د) تعيين الفئة الأساسية
```dart
Future<bool> setPrimaryCategory(
  String vendorId,
  String majorCategoryId,
) async {
  // تعيين فئة كأساسية
}
```

### 5. الواجهة المقترحة

#### أ) صفحة اختيار الفئات
```
┌─────────────────────────────────────┐
│ اختيار فئات التخصص                   │
├─────────────────────────────────────┤
│ □ إلكترونيات (مستوى: مبتدئ)          │
│ ☑ أزياء (مستوى: متقدم) [أساسية]     │
│ □ منزل وحديقة (مستوى: متوسط)        │
│ □ رياضة (مستوى: خبير)               │
├─────────────────────────────────────┤
│ [إضافة فئة] [حفظ التغييرات]         │
└─────────────────────────────────────┘
```

#### ب) إدارة الفئات
```
┌─────────────────────────────────────┐
│ فئات التخصص                         │
├─────────────────────────────────────┤
│ 1. أزياء (أساسية) [متقدم] ⭐         │
│ 2. إلكترونيات [مبتدئ]               │
│ 3. منزل وحديقة [متوسط]              │
├─────────────────────────────────────┤
│ [ترتيب] [تعديل] [إضافة فئة جديدة]   │
└─────────────────────────────────────┘
```

### 6. أمثلة الاستخدام

#### أ) إضافة فئة جديدة
```dart
final request = AddVendorCategoryRequest(
  vendorId: 'vendor_id',
  majorCategoryId: 'category_id',
  isPrimary: false,
  priority: 1,
  specializationLevel: 3,
  customDescription: 'متخصص في الأزياء النسائية',
);

await VendorCategoryRepository.instance.addVendorCategory(request);
```

#### ب) جلب فئات التاجر
```dart
final categories = await VendorCategoryRepository.instance
    .getVendorCategories('vendor_id');

for (final category in categories) {
  print('${category.categoryName} - ${category.specializationLevelText}');
}
```

#### ج) تحديث الأولويات
```dart
final request = UpdateCategoryPrioritiesRequest(
  vendorId: 'vendor_id',
  priorities: [
    CategoryPriorityItem(majorCategoryId: 'cat1', priority: 0),
    CategoryPriorityItem(majorCategoryId: 'cat2', priority: 1),
  ],
);

await VendorCategoryRepository.instance.updateCategoryPriorities(request);
```

### 7. قيود RLS

#### أ) القراءة العامة
- السماح لجميع المستخدمين بقراءة الفئات النشطة
- عرض الفئات للتجار النشطين فقط

#### ب) القراءة الخاصة
- السماح للتاجر بقراءة فئاته الخاصة
- عرض جميع الفئات (النشطة وغير النشطة)

#### ج) الكتابة
- السماح للتاجر بإدارة فئاته الخاصة فقط
- التحقق من ملكية التاجر

### 8. الفهارس والأداء

#### أ) فهارس أساسية
```sql
CREATE INDEX idx_vendor_major_categories_vendor_id 
    ON vendor_major_categories(vendor_id);

CREATE INDEX idx_vendor_major_categories_category_id 
    ON vendor_major_categories(major_category_id);

CREATE INDEX idx_vendor_major_categories_active 
    ON vendor_major_categories(is_active) WHERE is_active = true;
```

#### ب) فهارس مركبة
```sql
CREATE INDEX idx_vendor_major_categories_vendor_active 
    ON vendor_major_categories(vendor_id, is_active) 
    WHERE is_active = true;
```

### 9. الدوال المساعدة

#### أ) دالة جلب فئات التاجر مع التفاصيل
```sql
CREATE OR REPLACE FUNCTION get_vendor_categories_with_details(p_vendor_id UUID)
RETURNS TABLE (
    category_id UUID,
    category_name VARCHAR(255),
    is_primary BOOLEAN,
    priority INTEGER,
    specialization_level INTEGER
) AS $$
-- تنفيذ الدالة
```

#### ب) دالة إضافة فئة للتاجر
```sql
CREATE OR REPLACE FUNCTION add_vendor_category(
    p_vendor_id UUID,
    p_major_category_id UUID,
    p_is_primary BOOLEAN DEFAULT false,
    p_priority INTEGER DEFAULT 0,
    p_specialization_level INTEGER DEFAULT 1
) RETURNS UUID AS $$
-- تنفيذ الدالة
```

### 10. المزايا

#### أ) المرونة
- اختيار عدة فئات
- تخصيص مستوى التخصص
- وصف مخصص لكل فئة

#### ب) التنظيم
- نظام أولويات واضح
- فئة أساسية مميزة
- إدارة حالة الفئات

#### ج) الأداء
- فهارس محسنة
- استعلامات فعالة
- تحديثات تدريجية

### 11. التحديات والحلول

#### أ) تحديات التصميم
- **التعقيد**: نظام متعدد الفئات
- **الحل**: واجهة بسيطة ومفهومة

#### ب) تحديات الأداء
- **الاستعلامات**: جلب فئات متعددة
- **الحل**: فهارس محسنة ودوال مساعدة

#### ج) تحديات البيانات
- **التناسق**: فئة أساسية واحدة فقط
- **الحل**: قيود قاعدة البيانات ومشغلات

### 12. خطة التنفيذ

#### المرحلة 1: قاعدة البيانات
1. إنشاء جدول `vendor_major_categories`
2. إضافة الفهارس والقيود
3. إنشاء الدوال المساعدة

#### المرحلة 2: النماذج
1. إنشاء `VendorCategoryModel`
2. إنشاء نماذج الطلبات
3. إضافة الوظائف المساعدة

#### المرحلة 3: المستودع
1. إنشاء `VendorCategoryRepository`
2. تنفيذ العمليات الأساسية
3. إضافة العمليات المتقدمة

#### المرحلة 4: الواجهة
1. صفحة اختيار الفئات
2. صفحة إدارة الفئات
3. تحديث الملف الشخصي

#### المرحلة 5: الاختبار
1. اختبار العمليات الأساسية
2. اختبار الأداء
3. اختبار التكامل

### 13. أمثلة عملية

#### أ) تاجر إلكترونيات
```dart
// إضافة فئات للتاجر
await addVendorCategory('vendor1', 'electronics', true, 0, 4);
await addVendorCategory('vendor1', 'gadgets', false, 1, 3);
await addVendorCategory('vendor1', 'accessories', false, 2, 2);
```

#### ب) تاجر أزياء
```dart
// إضافة فئات للتاجر
await addVendorCategory('vendor2', 'fashion', true, 0, 5);
await addVendorCategory('vendor2', 'women_clothing', false, 1, 4);
await addVendorCategory('vendor2', 'men_clothing', false, 2, 3);
```

### 14. الخلاصة

هذا التصميم يوفر:
- **مرونة** في اختيار الفئات
- **تنظيم** واضح للفئات
- **أداء** محسن للاستعلامات
- **قابلية التوسع** للمستقبل
- **سهولة الاستخدام** للمطورين والمستخدمين

النظام يدعم التخصص المتعدد مع الحفاظ على البساطة والفعالية.
