# دليل نظام الأقسام للتجار 📚
# Vendor Sections Management System Guide

## نظرة عامة 📋

تم إنشاء نظام كامل لإدارة الأقسام (Sections/Sectors) للتجار يسمح بـ:
- ✅ إنشاء أقسام افتراضية عند تسجيل التاجر
- ✅ تخصيص أسماء الأقسام (عربي وإنجليزي)
- ✅ تغيير طريقة العرض (Grid, List, Slider, etc)
- ✅ إدارة ترتيب الأقسام
- ✅ إخفاء/إظهار الأقسام للزبائن

---

## المكونات الرئيسية 🔧

### 1. قاعدة البيانات 📊

#### جدول `vendor_sections`:
```sql
vendor_sections:
  - id: UUID
  - vendor_id: UUID (FK → vendors)
  - section_key: TEXT (مثل: offers, sales, newArrival)
  - display_name: TEXT (الاسم بالإنجليزية المعروض للزبائن)
  - arabic_name: TEXT (الاسم بالعربية)
  - display_type: TEXT (grid, list, slider, carousel, custom)
  - card_width: DOUBLE
  - card_height: DOUBLE
  - items_per_row: INTEGER
  - is_active: BOOLEAN
  - is_visible_to_customers: BOOLEAN
  - sort_order: INTEGER
  - icon_name: TEXT
  - color_hex: TEXT
  - created_at: TIMESTAMP
  - updated_at: TIMESTAMP
```

#### الأقسام الافتراضية:
عند تسجيل تاجر جديد، يتم إنشاء 12 قسم افتراضي:

| section_key | display_name | arabic_name | display_type | sort_order |
|-------------|--------------|-------------|--------------|------------|
| `offers` | Offers | العروض | grid | 1 |
| `all` | All Products | جميع المنتجات | grid | 2 |
| `sales` | Sales | التخفيضات | slider | 3 |
| `newArrival` | New Arrival | الوافد الجديد | grid | 4 |
| `featured` | Featured | المميز | grid | 5 |
| `foryou` | For You | لك خصيصاً | grid | 6 |
| `mixlin1` | Try This | جرّب هذا | custom | 7 |
| `mixone` | Mix Items | عناصر مختلطة | slider | 8 |
| `mixlin2` | Voutures | مغامرات | grid | 9 |
| `all1` | Product A | منتجات أ | grid | 10 |
| `all2` | Product B | منتجات ب | grid | 11 |
| `all3` | Product C | منتجات ج | grid | 12 |

---

### 2. Model (SectorModel) 📝

#### الحقول الجديدة:
```dart
class SectorModel {
  String? id;
  String vendorId;
  String name;  // section_key
  String englishName;  // display_name
  String? arabicName;  // ← جديد
  String displayType;  // ← جديد (grid, list, slider, etc)
  double? cardWidth;  // ← جديد
  double? cardHeight;  // ← جديد
  int itemsPerRow;  // ← جديد
  bool isActive;  // ← جديد
  bool isVisibleToCustomers;  // ← جديد
  int sortOrder;  // ← جديد
  String? iconName;  // ← جديد
  String? colorHex;  // ← جديد
  DateTime? createdAt;
  DateTime? updatedAt;
}
```

---

### 3. Repository (SectorRepository) 🗄️

#### Functions المتاحة:

```dart
// الحصول على الأقسام
getVendorSections(vendorId)  // جميع الأقسام
getActiveSections(vendorId)  // الأقسام النشطة فقط
getSectionById(sectionId)
getSectionByKey(vendorId, sectionKey)

// إنشاء وتحديث
createSection(SectorModel)
updateSection(SectorModel)
createDefaultSections(vendorId)  // إنشاء الأقسام الافتراضية

// حذف
deleteSection(sectionId)

// تحديثات محددة
updateSectionDisplayName(sectionId, displayName, arabicName)
updateSectionDisplayType(sectionId, displayType, cardWidth, cardHeight, itemsPerRow)
updateSectionsOrder(List<SectorModel>)

// تبديل الحالة
toggleSectionActive(sectionId, isActive)
toggleSectionVisibility(sectionId, isVisible)

// إضافية
getActiveSectionsCount(vendorId)
searchSections(vendorId, query)
```

---

### 4. Controller (SectorController) 🎮

#### Functions المحدثة:

```dart
// إنشاء وجلب
createDefaultSections(vendorId)  // إنشاء الأقسام الافتراضية
fetchSectors()  // جلب من قاعدة البيانات

// تحديث
updateSection(SectorModel)
updateSectionDisplayName(sectionId, displayName, arabicName)
updateSectionDisplayType(sectionId, displayType, ...)
updateSectionsOrder(List<SectorModel>)

// إضافة وحذف
addSection(SectorModel)
deleteSection(sectionId)

// تبديل
toggleSectionActive(sectionId, isActive)

// مساعدة
getSectorById(sectionId)
getSectorName(sectorId, lang)
clearCache()
refreshSectors()
```

---

## خطوات التثبيت 🚀

### الخطوة 1: تشغيل سكريبت قاعدة البيانات

```bash
# 1. افتح Supabase Dashboard → SQL Editor
# 2. انسخ محتوى create_vendor_sections_system.sql
# 3. شغّل السكريبت
```

### الخطوة 2: إنشاء الأقسام للتجار الحاليين

```sql
-- لكل تاجر موجود، شغّل:
SELECT create_default_vendor_sections('vendor-uuid-here');

-- أو لجميع التجار:
DO $$
DECLARE
    vendor_record RECORD;
BEGIN
    FOR vendor_record IN 
        SELECT id FROM vendors
    LOOP
        PERFORM create_default_vendor_sections(vendor_record.id);
    END LOOP;
END $$;
```

### الخطوة 3: اختبار من التطبيق

```dart
// في onInit أو بعد تسجيل تاجر جديد:
final sectorController = Get.put(SectorController(vendorId));
await sectorController.fetchSectors();

print('Sections: ${sectorController.sectors.length}');
// يجب أن يعرض 12 قسم
```

---

## الاستخدام في التطبيق 💻

### 1. في AddProductPage:

```dart
// تحميل الأقسام من قاعدة البيانات
Future<void> _loadSections() async {
  if (!Get.isRegistered<SectorController>()) {
    Get.put(SectorController(widget.vendorId));
  }

  final sectorController = SectorController.instance;
  await sectorController.fetchSectors();

  _sections.value = sectorController.sectors.toList();
  
  // تعيين القسم المبدئي
  if (widget.initialSection != null) {
    final initialSector = _sections.firstWhereOrNull(
      (s) => s.name == widget.initialSection,
    );
    if (initialSector != null) {
      _selectedSection.value = initialSector;
    }
  }
}
```

### 2. في صفحة المتجر (all_tab.dart):

```dart
// استخدام الأقسام من قاعدة البيانات
@override
Widget build(BuildContext context) {
  final sectorController = Get.put(SectorController(vendorId));

  return Obx(() {
    if (sectorController.isLoading.value) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        TPromoSlider(editMode: editMode, vendorId: vendorId),
        
        // عرض الأقسام من قاعدة البيانات
        ...sectorController.sectors.where((s) => s.isVisibleToCustomers).map((section) {
          return SectorBuilder(
            cardWidth: section.cardWidth ?? 25.w,
            cardHeight: section.cardHeight ?? 25.w * (4 / 3),
            sectorName: section.name,
            sctionTitle: 'all',
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

## ميزات التحكم للتاجر 🎯

### 1. تغيير اسم القسم:

```dart
// في وضع التعديل
await sectorController.updateSectionDisplayName(
  sectionId: sectionId,
  displayName: 'عروض خاصة',  // الإنجليزية
  arabicName: 'Special Offers',  // العربية
);
```

### 2. تغيير طريقة العرض:

```dart
await sectorController.updateSectionDisplayType(
  sectionId: sectionId,
  displayType: 'slider',  // من grid إلى slider
  cardWidth: 94.w,
  cardHeight: 94.w * (8 / 6),
  itemsPerRow: 1,
);
```

### 3. إخفاء/إظهار القسم:

```dart
await sectorRepository.toggleSectionVisibility(sectionId, false);
// القسم سيختفي عن الزبائن
```

### 4. تغيير الترتيب:

```dart
// بعد السحب والإفلات
final reorderedSections = [...]; // القائمة الجديدة
await sectorController.updateSectionsOrder(reorderedSections);
```

---

## صفحة إدارة الأقسام (TODO) 🚧

### الميزات المطلوبة:

```dart
class ManageSectionsPage extends StatelessWidget {
  final String vendorId;

  Widget build(BuildContext context) {
    final controller = Get.put(SectorController(vendorId));

    return Scaffold(
      appBar: AppBar(title: Text('إدارة الأقسام')),
      body: Obx(() {
        return ReorderableListView.builder(
          itemCount: controller.sectors.length,
          itemBuilder: (context, index) {
            final section = controller.sectors[index];
            
            return ListTile(
              key: ValueKey(section.id),
              leading: Switch(
                value: section.isActive,
                onChanged: (value) => controller.toggleSectionActive(
                  section.id!,
                  value,
                ),
              ),
              title: Text(section.englishName),
              subtitle: Text(section.arabicName ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة نوع العرض
                  _getDisplayTypeIcon(section.displayType),
                  
                  // زر التعديل
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editSection(section),
                  ),
                ],
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            final sections = controller.sectors.toList();
            final item = sections.removeAt(oldIndex);
            sections.insert(newIndex, item);
            controller.updateSectionsOrder(sections);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addNewSection(),
      ),
    );
  }
  
  Widget _getDisplayTypeIcon(String displayType) {
    switch (displayType) {
      case 'grid':
        return Icon(Icons.grid_view, size: 20);
      case 'list':
        return Icon(Icons.list, size: 20);
      case 'slider':
        return Icon(Icons.view_carousel, size: 20);
      default:
        return Icon(Icons.apps, size: 20);
    }
  }
}
```

---

## أمثلة الاستخدام 💡

### إنشاء الأقسام للتاجر الجديد:

```dart
// عند إنشاء حساب تاجر جديد
Future<void> onVendorCreated(String vendorId) async {
  final sectorController = Get.put(SectorController(vendorId));
  await sectorController.createDefaultSections(vendorId);
  
  print('✅ Default sections created');
}
```

### الحصول على أقسام التاجر:

```dart
final sectorController = Get.put(SectorController(vendorId));
await sectorController.fetchSectors();

final sections = sectorController.sectors;
print('Found ${sections.length} sections');
```

### تحديث اسم قسم:

```dart
await sectorController.updateSectionDisplayName(
  sectionId: 'section-uuid',
  displayName: 'Hot Deals',  // الإنجليزية
  arabicName: 'صفقات ساخنة',  // العربية
);
```

### تغيير طريقة العرض:

```dart
// من Grid إلى Slider
await sectorController.updateSectionDisplayType(
  sectionId: 'section-uuid',
  displayType: 'slider',
  cardWidth: 94.w,
  cardHeight: 94.w * (8 / 6),
  itemsPerRow: 1,
);
```

---

## التكامل مع الكود الحالي 🔗

### في `all_tab.dart`:

#### قبل التحديث:
```dart
// ❌ أقسام ثابتة في الكود
SectorBuilder(
  cardWidth: 25.w,
  cardHeight: 25.w * (4 / 3),
  sectorName: "offers",  // ثابت
  // ...
),
```

#### بعد التحديث:
```dart
// ✅ أقسام من قاعدة البيانات
final sectorController = Get.put(SectorController(vendorId));

return Obx(() {
  return Column(
    children: sectorController.sectors
        .where((s) => s.isVisibleToCustomers && s.isActive)
        .map((section) => SectorBuilder(
          cardWidth: section.cardWidth ?? 25.w,
          cardHeight: section.cardHeight ?? 25.w * (4 / 3),
          sectorName: section.name,
          vendorId: vendorId,
          editMode: editMode,
        ))
        .toList(),
  );
});
```

---

### في `AddProductPage`:

#### قبل التحديث:
```dart
// ❌ قائمة ثابتة
_sections.value = [
  SectorModel(name: 'all', englishName: 'All Products', vendorId: vendorId),
  SectorModel(name: 'offers', englishName: 'Offers', vendorId: vendorId),
  // ...
];
```

#### بعد التحديث:
```dart
// ✅ من قاعدة البيانات
final sectorController = Get.put(SectorController(widget.vendorId));
await sectorController.fetchSectors();
_sections.value = sectorController.sectors.toList();

// يعرض الأقسام بأسمائها المخصصة من التاجر
```

---

## RLS Policies 🔒

### للأمان الكامل:

1. **Anyone can view active sections**
   - الجميع (بما فيهم الزبائن) يرون الأقسام النشطة والمرئية

2. **Vendors can view their own sections**
   - التجار يرون جميع أقسامهم (حتى المخفية)

3. **Vendors can create/update/delete**
   - التجار يتحكمون بأقسامهم فقط

---

## التخصيص المتقدم 🎨

### 1. أنواع العرض المختلفة:

```dart
enum DisplayType {
  grid,      // شبكة عادية
  list,      // قائمة عمودية
  slider,    // عرض متحرك
  carousel,  // دوّار
  custom,    // مخصص
}
```

### 2. تخصيص حجم البطاقات:

```dart
// لكل قسم حجم مختلف
section.cardWidth = 94.w;  // عرض كبير
section.cardHeight = 94.w * (8 / 6);  // نسبة 8:6
section.itemsPerRow = 1;  // عنصر واحد في الصف
```

### 3. الألوان والأيقونات:

```dart
section.iconName = 'flash_sale';  // أيقونة مخصصة
section.colorHex = '#FF5722';  // لون القسم
```

---

## استعلامات مفيدة 🔍

### الحصول على أقسام تاجر:
```sql
SELECT * FROM vendor_sections 
WHERE vendor_id = 'vendor-uuid'
ORDER BY sort_order;
```

### تحديث اسم قسم:
```sql
UPDATE vendor_sections 
SET display_name = 'Hot Deals', arabic_name = 'صفقات ساخنة'
WHERE id = 'section-uuid';
```

### تغيير طريقة العرض:
```sql
UPDATE vendor_sections 
SET 
  display_type = 'slider',
  card_width = 400,
  card_height = 533,
  items_per_row = 1
WHERE id = 'section-uuid';
```

### إخفاء قسم عن الزبائن:
```sql
UPDATE vendor_sections 
SET is_visible_to_customers = false
WHERE id = 'section-uuid';
```

---

## الميزات المستقبلية 🔮

### قريباً:
1. **صفحة إدارة الأقسام** - واجهة مرئية كاملة
2. **السحب والإفلات** - لتغيير الترتيب
3. **معاينة مباشرة** - لرؤية التغييرات قبل الحفظ
4. **قوالب جاهزة** - تخطيطات معدة مسبقاً
5. **تحليلات الأقسام** - أي الأقسام أكثر زيارة

---

## استكشاف الأخطاء 🔧

### المشكلة: لا تظهر الأقسام

**الحل:**
```sql
-- تحقق من وجود الأقسام
SELECT * FROM vendor_sections WHERE vendor_id = 'vendor-uuid';

-- إذا لم توجد، أنشئها:
SELECT create_default_vendor_sections('vendor-uuid');
```

### المشكلة: الأقسام لا تتحدث

**الحل:**
```dart
// مسح الـ cache وإعادة التحميل
sectorController.clearCache();
await sectorController.refreshSectors();
```

---

## الخلاصة ✨

تم إنشاء نظام كامل لإدارة الأقسام:

- ✅ قاعدة بيانات كاملة مع RLS
- ✅ Model محدث بجميع الحقول
- ✅ Repository شامل
- ✅ Controller محدث
- ✅ تكامل مع AddProductPage
- ✅ دعم التخصيص الكامل

**النظام جاهز للاستخدام!** 🎉

للمرحلة التالية: إنشاء واجهة مرئية لإدارة الأقسام في وضع التعديل.

