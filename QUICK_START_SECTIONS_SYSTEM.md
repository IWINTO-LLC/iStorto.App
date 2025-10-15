# دليل البدء السريع - نظام الأقسام ⚡
# Quick Start Guide - Sections System

## ملخص سريع 📋

تم إنشاء نظام كامل لإدارة أقسام التجار مع:
- ✅ **17 حقل** في جدول `vendor_sections`
- ✅ **12 قسم افتراضي** لكل تاجر
- ✅ **إنشاء تلقائي** عند تسجيل تاجر جديد
- ✅ **تخصيص كامل** للأسماء والعرض

---

## التثبيت السريع (3 خطوات فقط) 🚀

### 1️⃣ شغّل السكريبت الرئيسي
```sql
-- في Supabase SQL Editor:
-- شغّل: create_vendor_sections_complete_updated.sql
```
**هذا السكريبت يعمل كل شيء:**
- ✅ ينشئ الجدول مع 17 حقل
- ✅ ينشئ 6 Indexes
- ✅ ينشئ 3 Functions
- ✅ ينشئ 2 Triggers (واحد تلقائي)
- ✅ ينشئ 5 RLS Policies

### 2️⃣ أضف الأقسام للتجار الحاليين
```sql
-- احذف التعليق من الخطوة 10 في نفس السكريبت
-- أو شغّل هذا:
DO $$
DECLARE
    vendor_record RECORD;
BEGIN
    FOR vendor_record IN SELECT id FROM public.vendors
    LOOP
        PERFORM create_default_vendor_sections(vendor_record.id);
    END LOOP;
END $$;
```

### 3️⃣ تحقق من النجاح
```sql
-- يجب أن ترى: عدد_التجار × 12
SELECT COUNT(*) FROM vendor_sections;

-- عرض إحصائيات
SELECT 
    v.organization_name,
    COUNT(vs.id) as sections_count
FROM vendors v
LEFT JOIN vendor_sections vs ON v.id = vs.vendor_id
GROUP BY v.organization_name
ORDER BY sections_count DESC;
```

---

## الأقسام الافتراضية (12 قسم) 📁

| # | section_key | display_name | arabic_name | display_type |
|---|-------------|--------------|-------------|--------------|
| 1 | offers | Offers | العروض | grid |
| 2 | all | All Products | جميع المنتجات | grid |
| 3 | sales | Sales | التخفيضات | slider |
| 4 | newArrival | New Arrival | الوافد الجديد | grid |
| 5 | featured | Featured | المميز | grid |
| 6 | foryou | For You | لك خصيصاً | grid |
| 7 | mixlin1 | Try This | جرّب هذا | custom |
| 8 | mixone | Mix Items | عناصر مختلطة | slider |
| 9 | mixlin2 | Voutures | مغامرات | grid |
| 10 | all1 | Product A | منتجات أ | grid |
| 11 | all2 | Product B | منتجات ب | grid |
| 12 | all3 | Product C | منتجات ج | grid |

---

## الاستخدام في التطبيق 📱

### تحميل الأقسام:
```dart
// في AddProductPage أو أي صفحة:
final sectorController = Get.put(SectorController(vendorId));
await sectorController.fetchSectors();

// الأقسام محملة!
print('Sections: ${sectorController.sectors.length}'); // 12
```

### عرض الأقسام:
```dart
Obx(() {
  return Column(
    children: sectorController.sectors
        .where((s) => s.isVisibleToCustomers && s.isActive)
        .map((section) => SectorBuilder(
          sectorName: section.name,
          vendorId: vendorId,
          // ...
        ))
        .toList(),
  );
})
```

---

## تخصيص الأقسام 🎨

### 1. تغيير الاسم:
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
  cardHeight: 125.0,
  itemsPerRow: 1,
);
```

### 3. إخفاء/إظهار:
```dart
await sectorRepository.toggleSectionVisibility(section.id!, false);
```

---

## الحقول الجديدة (11 حقل) ✨

```dart
class SectorModel {
  // الحقول القديمة:
  String? id;
  String vendorId;
  String name;  // section_key
  String englishName;  // display_name
  DateTime? createdAt;
  DateTime? updatedAt;
  
  // الحقول الجديدة (11):
  String? arabicName;              // ← جديد
  String displayType;              // ← جديد
  double? cardWidth;               // ← جديد
  double? cardHeight;              // ← جديد
  int itemsPerRow;                 // ← جديد
  bool isActive;                   // ← جديد
  bool isVisibleToCustomers;       // ← جديد
  int sortOrder;                   // ← جديد
  String? iconName;                // ← جديد
  String? colorHex;                // ← جديد
}
```

---

## أنواع العرض المتاحة

| Type | Description | items_per_row |
|------|-------------|---------------|
| grid | شبكة عادية | 2-4 |
| list | قائمة عمودية | 1 |
| slider | عرض متحرك | 1 |
| carousel | دوّار تلقائي | 1 |
| custom | تخصيص خاص | متغير |

---

## التحقق من المشاكل 🔧

### المشكلة: لا تظهر الأقسام
```sql
-- تحقق:
SELECT * FROM vendor_sections WHERE vendor_id = 'vendor-uuid';

-- إذا فارغ:
SELECT create_default_vendor_sections('vendor-uuid');
```

### المشكلة: التجار الجدد لا يحصلون على أقسام
```sql
-- تحقق من Trigger:
SELECT * FROM pg_trigger 
WHERE tgname = 'trigger_auto_create_vendor_sections';

-- إذا غير موجود، شغّل:
-- create_vendor_sections_complete_updated.sql
```

---

## الملفات المتاحة 📚

### السكريبتات:
1. **create_vendor_sections_complete_updated.sql** ⭐
   - السكريبت الرئيسي الكامل والمحدث
   - يحتوي على كل شيء (جداول، functions، triggers، policies)
   
2. **add_auto_sections_trigger.sql**
   - Trigger فقط (مدمج في السكريبت الرئيسي)
   
3. **create_sections_for_existing_vendors.sql**
   - لإنشاء الأقسام للتجار الموجودين فقط

### التوثيق:
1. **VENDOR_SECTIONS_SYSTEM_GUIDE.md**
   - الدليل الشامل للنظام
   
2. **SECTIONS_COMPLETE_SETUP_GUIDE.md**
   - دليل التثبيت الكامل خطوة بخطوة
   
3. **VENDOR_SECTIONS_SCHEMA_REFERENCE.md**
   - مرجع هيكل الجدول والمقارنة
   
4. **QUICK_START_SECTIONS_SYSTEM.md** (هذا الملف)
   - دليل البدء السريع

---

## الخلاصة ✅

### للتجار الجدد:
- ✅ يتم إنشاء 12 قسم **تلقائياً** عند التسجيل
- ✅ لا حاجة لأي إعداد

### للتجار الحاليين:
- ⚡ شغّل `create_vendor_sections_complete_updated.sql`
- ⚡ احذف التعليق من الخطوة 10
- ⚡ جميع التجار سيحصلون على 12 قسم

### الميزات:
- ✅ تخصيص الأسماء (عربي وإنجليزي)
- ✅ تخصيص طريقة العرض (5 أنواع)
- ✅ إعادة الترتيب
- ✅ الإخفاء/الإظهار
- ✅ أمان كامل مع RLS

---

## البدء الآن! 🚀

```bash
# 1. افتح Supabase SQL Editor
# 2. شغّل: create_vendor_sections_complete_updated.sql
# 3. احذف التعليق من الخطوة 10 (للتجار الحاليين)
# 4. اختبر في التطبيق:
#    - افتح AddProductPage
#    - شاهد الأقسام محملة من قاعدة البيانات!
```

**النظام الآن جاهز للاستخدام! 🎉**

