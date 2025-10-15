# دليل الإعداد الكامل لنظام الأقسام 🚀
# Complete Sections System Setup Guide

## نظرة عامة 📋

نظام الأقسام يسمح لكل تاجر بتخصيص أقساطه (Sections) في متجره، مع إمكانية:
- ✅ تغيير الأسماء (عربي وإنجليزي)
- ✅ تغيير طريقة العرض (Grid, List, Slider)
- ✅ إعادة الترتيب
- ✅ الإخفاء/الإظهار

---

## خطوات التثبيت الكاملة 🔧

### الخطوة 1: إنشاء البنية الأساسية
```sql
-- في Supabase SQL Editor:
1. شغّل: create_vendor_sections_system.sql
```

**ما يفعله:**
- ينشئ جدول `vendor_sections`
- ينشئ Function `create_default_vendor_sections()`
- ينشئ RLS Policies
- ينشئ Indexes

**النتيجة المتوقعة:**
```
✅ Table "vendor_sections" created
✅ Function "create_default_vendor_sections" created
✅ 5 RLS policies created
✅ 5 indexes created
```

---

### الخطوة 2: إضافة Trigger للتجار الجدد
```sql
-- في Supabase SQL Editor:
2. شغّل: add_auto_sections_trigger.sql
```

**ما يفعله:**
- ينشئ Trigger تلقائي على جدول `vendors`
- عند إنشاء تاجر جديد → ينشئ 12 قسم افتراضي تلقائياً

**النتيجة المتوقعة:**
```
✅ Function "auto_create_vendor_sections" created
✅ Trigger "trigger_auto_create_vendor_sections" created
```

**الاختبار:**
```sql
-- إنشاء تاجر تجريبي
INSERT INTO vendors (user_id, organization_name, organization_logo, brief)
VALUES ('test-user-123', 'Test Store', 'logo.png', 'Test')
RETURNING id;

-- التحقق من الأقسام
SELECT * FROM vendor_sections WHERE vendor_id = 'returned-id';
-- يجب أن ترى 12 قسم!
```

---

### الخطوة 3: إضافة الأقسام للتجار الحاليين
```sql
-- في Supabase SQL Editor:
3. شغّل: create_sections_for_existing_vendors.sql
```

**ما يفعله:**
- يمر على جميع التجار الموجودين
- ينشئ 12 قسم افتراضي لكل واحد
- يعرض تقرير مفصل

**النتيجة المتوقعة:**
```
NOTICE: Vendor: Store Name (uuid) - Sections: 12
NOTICE: Vendor: Store Name 2 (uuid) - Sections: 12
...
NOTICE: ==========================================
NOTICE: إجمالي التجار: 50
NOTICE: تم إنشاء الأقسام بنجاح!
NOTICE: ==========================================

✅ جميع التجار لديهم أقسام!
```

---

## التحقق من النجاح ✅

### 1. التحقق من عدد الأقسام:
```sql
SELECT 
    v.organization_name,
    COUNT(vs.id) as sections_count
FROM vendors v
LEFT JOIN vendor_sections vs ON v.id = vs.vendor_id
GROUP BY v.id, v.organization_name
ORDER BY sections_count DESC;
```

**النتيجة المتوقعة:**
```
organization_name    | sections_count
---------------------|---------------
Store 1              | 12
Store 2              | 12
Store 3              | 12
...
```

### 2. التحقق من أسماء الأقسام:
```sql
SELECT section_key, display_name, arabic_name, sort_order
FROM vendor_sections
WHERE vendor_id = 'any-vendor-id'
ORDER BY sort_order;
```

**النتيجة المتوقعة:**
```
section_key | display_name  | arabic_name       | sort_order
------------|---------------|-------------------|------------
offers      | Offers        | العروض            | 1
all         | All Products  | جميع المنتجات     | 2
sales       | Sales         | التخفيضات         | 3
...
```

---

## الاستخدام في التطبيق 📱

### 1. تحميل الأقسام تلقائياً:

```dart
// في AddProductPage أو أي صفحة أخرى:
final sectorController = Get.put(SectorController(vendorId));
await sectorController.fetchSectors();

// الأقسام تُحمل تلقائياً من قاعدة البيانات
print('Sections: ${sectorController.sectors.length}'); // 12
```

### 2. عرض الأقسام في واجهة المتجر:

```dart
// في all_tab.dart:
@override
Widget build(BuildContext context) {
  final sectorController = Get.put(SectorController(vendorId));

  return Obx(() {
    if (sectorController.isLoading.value) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        // عرض الأقسام النشطة والمرئية فقط
        ...sectorController.sectors
            .where((s) => s.isVisibleToCustomers && s.isActive)
            .map((section) {
              return SectorBuilder(
                cardWidth: section.cardWidth ?? 25.w,
                cardHeight: section.cardHeight ?? 25.w * (4 / 3),
                sectorName: section.name,
                sctionTitle: section.englishName,
                vendorId: vendorId,
                editMode: editMode,
              );
            }),
      ],
    );
  });
}
```

---

## إحصائيات النظام 📊

### ما تم إنجازه:

#### قاعدة البيانات:
- ✅ جدول `vendor_sections` كامل
- ✅ 12 قسم افتراضي لكل تاجر
- ✅ 5 RLS Policies للأمان
- ✅ 5 Indexes للأداء
- ✅ 2 Functions (يدوي + تلقائي)
- ✅ 1 Trigger تلقائي
- ✅ دعم تخصيص كامل

#### الكود:
- ✅ `SectorModel` محدث (17 حقل)
- ✅ `SectorRepository` كامل (20+ function)
- ✅ `SectorController` محدث للعمل مع قاعدة البيانات
- ✅ `AddProductPage` يحمل الأقسام من قاعدة البيانات
- ✅ `custom_widgets.dart` محدث

#### الميزات:
- ✅ إنشاء تلقائي للأقسام عند تسجيل تاجر جديد
- ✅ تخصيص أسماء الأقسام (عربي وإنجليزي)
- ✅ تغيير طريقة العرض (Grid, List, Slider, Carousel, Custom)
- ✅ تخصيص أحجام البطاقات
- ✅ إعادة ترتيب الأقسام
- ✅ إخفاء/إظهار للزبائن
- ✅ تفعيل/تعطيل الأقسام
- ✅ البحث في الأقسام

---

## الأقسام الافتراضية 📁

كل تاجر جديد يحصل على هذه الأقسام تلقائياً:

| # | section_key | display_name | arabic_name | display_type | sort_order |
|---|-------------|--------------|-------------|--------------|------------|
| 1 | offers | Offers | العروض | grid | 1 |
| 2 | all | All Products | جميع المنتجات | grid | 2 |
| 3 | sales | Sales | التخفيضات | slider | 3 |
| 4 | newArrival | New Arrival | الوافد الجديد | grid | 4 |
| 5 | featured | Featured | المميز | grid | 5 |
| 6 | foryou | For You | لك خصيصاً | grid | 6 |
| 7 | mixlin1 | Try This | جرّب هذا | custom | 7 |
| 8 | mixone | Mix Items | عناصر مختلطة | slider | 8 |
| 9 | mixlin2 | Voutures | مغامرات | grid | 9 |
| 10 | all1 | Product A | منتجات أ | grid | 10 |
| 11 | all2 | Product B | منتجات ب | grid | 11 |
| 12 | all3 | Product C | منتجات ج | grid | 12 |

---

## تخصيص الأقسام 🎨

### 1. تغيير اسم القسم:

```dart
await sectorController.updateSectionDisplayName(
  sectionId: section.id!,
  displayName: 'Hot Deals',
  arabicName: 'صفقات ساخنة',
);
```

### 2. تغيير طريقة العرض:

```dart
await sectorController.updateSectionDisplayType(
  sectionId: section.id!,
  displayType: 'slider',
  cardWidth: 94.w,
  cardHeight: 94.w * (8 / 6),
  itemsPerRow: 1,
);
```

### 3. إخفاء القسم:

```sql
UPDATE vendor_sections 
SET is_visible_to_customers = false 
WHERE id = 'section-id';
```

أو في Dart:
```dart
await sectorRepository.toggleSectionVisibility(section.id!, false);
```

### 4. تغيير الترتيب:

```dart
// بعد السحب والإفلات
final reorderedSections = [...]; // القائمة الجديدة
await sectorController.updateSectionsOrder(reorderedSections);
```

---

## استكشاف الأخطاء 🔧

### المشكلة 1: لا تظهر الأقسام للتاجر

**الحل:**
```sql
-- تحقق من وجود الأقسام
SELECT * FROM vendor_sections WHERE vendor_id = 'vendor-id';

-- إذا لم توجد:
SELECT create_default_vendor_sections('vendor-id');
```

### المشكلة 2: التجار الجدد لا يحصلون على أقسام تلقائياً

**الحل:**
```sql
-- تحقق من وجود Trigger
SELECT * FROM pg_trigger WHERE tgname = 'trigger_auto_create_vendor_sections';

-- إذا لم يوجد، شغّل:
-- add_auto_sections_trigger.sql
```

### المشكلة 3: الأقسام لا تتحدث في التطبيق

**الحل:**
```dart
// مسح الـ cache
sectorController.clearCache();
await sectorController.refreshSectors();
```

---

## استعلامات مفيدة 💡

### 1. عرض جميع التجار وعدد أقسامهم:
```sql
SELECT 
    v.organization_name,
    COUNT(vs.id) as sections_count,
    COUNT(CASE WHEN vs.is_active THEN 1 END) as active_sections
FROM vendors v
LEFT JOIN vendor_sections vs ON v.id = vs.vendor_id
GROUP BY v.id, v.organization_name
ORDER BY sections_count DESC;
```

### 2. عرض التجار الذين لا يملكون أقسام:
```sql
SELECT v.*
FROM vendors v
LEFT JOIN vendor_sections vs ON v.id = vs.vendor_id
WHERE vs.id IS NULL;
```

### 3. عرض الأقسام الأكثر استخداماً:
```sql
SELECT 
    section_key,
    display_name,
    COUNT(*) as usage_count
FROM vendor_sections
GROUP BY section_key, display_name
ORDER BY usage_count DESC;
```

---

## ملفات السكريبت 📄

1. **create_vendor_sections_system.sql**
   - البنية الأساسية
   - الجداول والـ Functions الرئيسية

2. **add_auto_sections_trigger.sql**
   - Trigger للتجار الجدد
   - إنشاء تلقائي للأقسام

3. **create_sections_for_existing_vendors.sql**
   - للتجار المسجلين سابقاً
   - إنشاء دفعي للأقسام

---

## الخلاصة النهائية ✨

### ✅ للتجار الجدد:
- يتم إنشاء 12 قسم **تلقائياً** عند التسجيل
- لا حاجة لأي إعداد يدوي
- كل شيء جاهز للاستخدام فوراً

### ✅ للتجار المسجلين سابقاً:
- شغّل `create_sections_for_existing_vendors.sql` **مرة واحدة فقط**
- سيحصل كل تاجر على 12 قسم افتراضي
- يمكن تشغيله مرات متعددة بأمان (لن يكرر الأقسام)

### ✅ التخصيص:
- كل تاجر يمكنه تغيير أسماء الأقسام
- تغيير طريقة العرض
- إعادة الترتيب
- الإخفاء/الإظهار

---

## خطة التنفيذ السريعة ⚡

```bash
# 1. في Supabase SQL Editor:
✅ شغّل: create_vendor_sections_system.sql
✅ شغّل: add_auto_sections_trigger.sql
✅ شغّل: create_sections_for_existing_vendors.sql

# 2. تحقق من النتائج:
✅ SELECT COUNT(*) FROM vendor_sections;
   # يجب أن يكون: عدد_التجار × 12

# 3. في التطبيق:
✅ flutter clean
✅ flutter pub get
✅ flutter run

# 4. اختبار:
✅ افتح صفحة إضافة منتج
✅ تأكد من ظهور الأقسام من قاعدة البيانات
✅ جرّب إضافة منتج من قسم معين
```

---

**النظام الآن كامل ومتكامل! 🎉**

للمزيد من التفاصيل، راجع: `VENDOR_SECTIONS_SYSTEM_GUIDE.md`

