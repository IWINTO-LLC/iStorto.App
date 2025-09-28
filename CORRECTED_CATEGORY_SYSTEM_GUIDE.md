# دليل نظام الفئات المصحح

## تصحيح الفهم

تم تصحيح النظام ليعكس البنية الصحيحة:

### 1. **`major_categories`** - الفئات العامة
- **المصدر**: تدخل من الإدارة فقط
- **الاستخدام**: فئات عامة للتطبيق
- **الوصول**: جميع المستخدمين يمكنهم رؤيتها
- **الغرض**: التاجر يختار منها خلال إنشاء الحساب التجاري

### 2. **`vendor_categories`** - الفئات الخاصة
- **المصدر**: كل تاجر يضيفها بنفسه
- **الاستخدام**: فئات خاصة لكل تاجر
- **الوصول**: التاجر فقط يمكنه إدارتها
- **الغرض**: تصنيفات خاصة بمنتجات التاجر

## التطبيق المُصحح

### 1. المرحلة الثالثة - اختيار الفئات العامة

#### أ) الواجهة
- عرض الفئات العامة (`major_categories`) في شبكة
- إمكانية الاختيار المتعدد
- تجربة سلسة مع مؤثرات بصرية

#### ب) المنطق
```dart
// تحميل الفئات العامة
Future<void> loadAvailableCategories() async {
  final repository = MajorCategoryRepository();
  final categories = await repository.getAllCategories();
  availableCategories.value = categories;
}

// حفظ الفئات المختارة
Future<void> _saveSelectedMajorCategories(String vendorId) async {
  final selectedCategoriesString = selectedCategories.join(',');
  await _supabaseService.updateVendorCategories(vendorId, selectedCategoriesString);
}
```

### 2. قاعدة البيانات

#### أ) حقل جديد في جدول `vendors`
```sql
ALTER TABLE vendors 
ADD COLUMN selected_major_categories TEXT;
```

#### ب) جدول `major_categories`
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

#### ج) سياسات RLS
- **قراءة عامة**: الفئات النشطة فقط
- **إدراج/تحديث**: المستخدمون المصادق عليهم (للإدارة)

### 3. النماذج المُحدثة

#### أ) `VendorModel`
```dart
class VendorModel {
  // ... باقي الحقول
  final String? selectedMajorCategories; // الفئات العامة المختارة
  // ... باقي الحقول
}
```

#### ب) `MajorCategoryModel`
```dart
class MajorCategoryModel {
  String? id;
  String name;
  String? arabicName;
  String? image;
  bool isFeature;
  int status; // 1: Active, 2: Pending, 3: Inactive
  String? parentId;
  // ... باقي الحقول
}
```

### 4. الخدمات

#### أ) `SupabaseService`
```dart
// تحديث فئات التاجر المختارة
Future<void> updateVendorCategories(String vendorId, String selectedCategories) async {
  await client
      .from('vendors')
      .update({
        'selected_major_categories': selectedCategories,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', vendorId);
}
```

#### ب) `MajorCategoryRepository`
```dart
// جلب جميع الفئات النشطة
Future<List<MajorCategoryModel>> getAllCategories() async {
  final response = await _client
      .from('major_categories')
      .select()
      .eq('status', 1)
      .order('is_feature', ascending: false)
      .order('name', ascending: true);
  
  return (response as List)
      .map((data) => MajorCategoryModel.fromJson(data))
      .toList();
}
```

### 5. الفئات التجريبية

تم إدراج 15 فئة تجريبية:

#### أ) فئات مميزة
- إلكترونيات (Electronics)
- أزياء (Fashion)

#### ب) فئات عادية
- المنزل والحديقة (Home & Garden)
- رياضة (Sports)
- كتب (Books)
- الصحة والجمال (Health & Beauty)
- السيارات (Automotive)
- الطعام والشراب (Food & Beverage)
- الألعاب (Toys & Games)
- القرطاسية (Office Supplies)
- المجوهرات (Jewelry)
- مستلزمات الحيوانات الأليفة (Pet Supplies)
- الآلات الموسيقية (Musical Instruments)
- الفنون والحرف (Art & Crafts)
- السفر (Travel)

### 6. الدوال المساعدة

#### أ) `get_active_major_categories()`
```sql
-- جلب الفئات النشطة
CREATE OR REPLACE FUNCTION get_active_major_categories()
RETURNS TABLE (
    id UUID,
    name VARCHAR(255),
    arabic_name VARCHAR(255),
    image VARCHAR(500),
    is_feature BOOLEAN,
    status INTEGER,
    parent_id UUID,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mc.id, mc.name, mc.arabic_name, mc.image,
        mc.is_feature, mc.status, mc.parent_id, mc.created_at
    FROM major_categories mc
    WHERE mc.status = 1
    ORDER BY mc.is_feature DESC, mc.name ASC;
END;
$$ LANGUAGE plpgsql;
```

#### ب) `get_vendor_selected_categories()`
```sql
-- جلب فئات التاجر المختارة
CREATE OR REPLACE FUNCTION get_vendor_selected_categories(p_vendor_id UUID)
RETURNS TABLE (
    id UUID,
    name VARCHAR(255),
    arabic_name VARCHAR(255),
    image VARCHAR(500),
    is_feature BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mc.id, mc.name, mc.arabic_name, mc.image, mc.is_feature
    FROM vendors v
    JOIN major_categories mc ON mc.id::text = ANY(string_to_array(v.selected_major_categories, ','))
    WHERE v.id = p_vendor_id
    AND mc.status = 1
    ORDER BY mc.is_feature DESC, mc.name ASC;
END;
$$ LANGUAGE plpgsql;
```

#### ج) `update_vendor_selected_categories()`
```sql
-- تحديث فئات التاجر المختارة
CREATE OR REPLACE FUNCTION update_vendor_selected_categories(
    p_vendor_id UUID,
    p_selected_categories TEXT
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE vendors 
    SET 
        selected_major_categories = p_selected_categories,
        updated_at = NOW()
    WHERE id = p_vendor_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
```

### 7. سير العمل

#### أ) إنشاء الحساب التجاري
1. المستخدم يملأ البيانات الأساسية
2. المستخدم يختار الصور
3. **المستخدم يختار من الفئات العامة**
4. حفظ البيانات والفئات المختارة
5. الانتقال لصفحة التهاني

#### ب) إدارة الفئات الخاصة
- التاجر يمكنه إضافة فئات خاصة (`vendor_categories`) لاحقاً
- هذه الفئات منفصلة تماماً عن الفئات العامة
- كل تاجر يدير فئاته الخاصة فقط

### 8. المزايا

#### أ) للمستخدمين
- **وضوح**: فصل واضح بين الفئات العامة والخاصة
- **مرونة**: اختيار من فئات معدة مسبقاً
- **سهولة**: واجهة بديهية للاختيار

#### ب) للإدارة
- **تحكم**: إدارة الفئات العامة من لوحة التحكم
- **تنظيم**: فئات موحدة لجميع التجار
- **مراقبة**: تتبع الفئات الأكثر اختياراً

#### ج) للتجار
- **تخصيص**: إضافة فئات خاصة لاحقاً
- **مرونة**: اختيار من فئات عامة + فئات خاصة
- **تنظيم**: تصنيف منتجاتهم بشكل دقيق

### 9. الملفات المُحدثة

#### أ) الملفات الجديدة
- `fix_commercial_setup_major_categories.sql` - سكريبت قاعدة البيانات المصحح
- `CORRECTED_CATEGORY_SYSTEM_GUIDE.md` - هذا الدليل

#### ب) الملفات المُحدثة
- `lib/views/initial_commercial_page.dart` - المرحلة الثالثة
- `lib/controllers/initial_commercial_controller.dart` - منطق اختيار الفئات
- `lib/services/supabase_service.dart` - دالة تحديث الفئات
- `lib/featured/shop/data/vendor_model.dart` - حقل الفئات المختارة

### 10. الخطوات المطلوبة

#### أ) تشغيل سكريبت قاعدة البيانات
```sql
-- تشغيل: fix_commercial_setup_major_categories.sql
-- سيتم:
-- 1. إضافة حقل selected_major_categories لجدول vendors
-- 2. إنشاء جدول major_categories
-- 3. إدراج الفئات التجريبية
-- 4. إنشاء الدوال المساعدة
-- 5. تطبيق سياسات RLS
```

#### ب) اختبار النظام
1. افتح صفحة إنشاء الحساب التجاري
2. انتقل للمرحلة الثالثة
3. ستجد شبكة الفئات العامة
4. اختبر عملية الاختيار والحفظ
5. تحقق من حفظ الفئات في قاعدة البيانات

### 11. الخلاصة

تم تصحيح النظام ليعكس البنية الصحيحة:
- **الفئات العامة** (`major_categories`) للاختيار أثناء إنشاء الحساب
- **الفئات الخاصة** (`vendor_categories`) لإدارة التاجر لاحقاً
- فصل واضح بين النوعين
- نظام مرن وقابل للتوسع

النظام جاهز للاستخدام! 🚀
