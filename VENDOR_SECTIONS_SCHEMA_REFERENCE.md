# مرجع هيكل جدول الأقسام 📊
# Vendor Sections Schema Reference

## مقارنة بين النسخة القديمة والجديدة

---

## النسخة الجديدة (الحالية) - 17 حقل ✨

### الجدول الكامل: `vendor_sections`

| # | Column Name | Type | Nullable | Default | Description |
|---|-------------|------|----------|---------|-------------|
| 1 | `id` | UUID | NO | gen_random_uuid() | المعرف الفريد |
| 2 | `vendor_id` | UUID | NO | - | معرف التاجر (FK) |
| 3 | `section_key` | TEXT | NO | - | المفتاح الداخلي |
| 4 | `display_name` | TEXT | NO | - | الاسم بالإنجليزية |
| 5 | `arabic_name` | TEXT | YES | NULL | الاسم بالعربية ✨ جديد |
| 6 | `display_type` | TEXT | YES | 'grid' | نوع العرض ✨ جديد |
| 7 | `card_width` | DOUBLE | YES | NULL | عرض البطاقة ✨ جديد |
| 8 | `card_height` | DOUBLE | YES | NULL | ارتفاع البطاقة ✨ جديد |
| 9 | `items_per_row` | INTEGER | YES | 3 | عدد العناصر/صف ✨ جديد |
| 10 | `is_active` | BOOLEAN | YES | TRUE | مفعّل؟ ✨ جديد |
| 11 | `is_visible_to_customers` | BOOLEAN | YES | TRUE | مرئي للزبائن؟ ✨ جديد |
| 12 | `sort_order` | INTEGER | YES | 0 | الترتيب ✨ جديد |
| 13 | `icon_name` | TEXT | YES | NULL | اسم الأيقونة ✨ جديد |
| 14 | `color_hex` | TEXT | YES | NULL | لون القسم ✨ جديد |
| 15 | `created_at` | TIMESTAMP | YES | NOW() | تاريخ الإنشاء |
| 16 | `updated_at` | TIMESTAMP | YES | NOW() | تاريخ التحديث |
| 17 | UNIQUE | - | - | - | (vendor_id, section_key) |

---

## النسخة القديمة (المبدئية) - 6 حقول فقط

```sql
-- كانت فقط:
id
vendor_id
name (section_key)
english_name (display_name)
created_at
updated_at
```

---

## الحقول الجديدة المضافة (11 حقل جديد) ✨

### 1. **arabic_name** (TEXT)
- الاسم المعروض بالعربية
- اختياري
- مثال: `'العروض'`, `'التخفيضات'`

### 2. **display_type** (TEXT)
- نوع طريقة العرض
- القيم المسموحة: `'grid'`, `'list'`, `'slider'`, `'carousel'`, `'custom'`
- افتراضي: `'grid'`

### 3. **card_width** (DOUBLE PRECISION)
- عرض البطاقة
- اختياري
- يمكن أن يكون بالبكسل أو النسبة (25.w في Flutter)

### 4. **card_height** (DOUBLE PRECISION)
- ارتفاع البطاقة
- اختياري
- غالباً يتم حسابه بنسبة من card_width

### 5. **items_per_row** (INTEGER)
- عدد العناصر في الصف الواحد
- افتراضي: `3`
- مثال: `1` للـ slider, `3` أو `4` للـ grid

### 6. **is_active** (BOOLEAN)
- هل القسم مفعّل؟
- افتراضي: `TRUE`
- إذا كان `FALSE`، القسم معطل تماماً

### 7. **is_visible_to_customers** (BOOLEAN)
- هل يظهر للزبائن؟
- افتراضي: `TRUE`
- يسمح للتاجر بإخفاء أقسام مؤقتاً

### 8. **sort_order** (INTEGER)
- ترتيب العرض في صفحة المتجر
- افتراضي: `0`
- كلما كانت القيمة أصغر، ظهر القسم أولاً

### 9. **icon_name** (TEXT)
- اسم الأيقونة
- اختياري
- مثال: `'flash_sale'`, `'star'`, `'trending_up'`

### 10. **color_hex** (TEXT)
- لون القسم بصيغة HEX
- اختياري
- مثال: `'#FF5722'`, `'#4CAF50'`

### 11. **CHECK Constraint على display_type**
- يضمن أن `display_type` يكون واحد من القيم المسموحة فقط

---

## أمثلة البيانات

### مثال 1: قسم العروض
```sql
{
  "id": "uuid",
  "vendor_id": "vendor-uuid",
  "section_key": "offers",
  "display_name": "Offers",
  "arabic_name": "العروض",
  "display_type": "grid",
  "card_width": null,
  "card_height": null,
  "items_per_row": 4,
  "is_active": true,
  "is_visible_to_customers": true,
  "sort_order": 1,
  "icon_name": "local_offer",
  "color_hex": "#FF5722",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### مثال 2: قسم التخفيضات (Slider)
```sql
{
  "id": "uuid",
  "vendor_id": "vendor-uuid",
  "section_key": "sales",
  "display_name": "Sales",
  "arabic_name": "التخفيضات",
  "display_type": "slider",
  "card_width": 94.0,  -- عرض كامل
  "card_height": 125.0,  -- نسبة 8:6
  "items_per_row": 1,  -- عنصر واحد في المرة
  "is_active": true,
  "is_visible_to_customers": true,
  "sort_order": 3,
  "icon_name": "trending_down",
  "color_hex": "#4CAF50",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

---

## Indexes (6 مؤشرات)

1. **idx_vendor_sections_vendor_id**
   - على `vendor_id`
   - الأكثر استخداماً

2. **idx_vendor_sections_section_key**
   - على `section_key`
   - للبحث السريع

3. **idx_vendor_sections_active**
   - على `(vendor_id, is_active)`
   - مركب للتصفية

4. **idx_vendor_sections_sort_order**
   - على `(vendor_id, sort_order)`
   - للترتيب السريع

5. **idx_vendor_sections_visible**
   - على `(vendor_id, is_visible_to_customers)`
   - للعرض للزبائن

6. **idx_vendor_sections_display_type**
   - على `display_type`
   - للتصفية حسب نوع العرض

---

## Functions (3 دوال)

### 1. `update_vendor_sections_updated_at()`
- **النوع:** Trigger Function
- **الوظيفة:** تحديث `updated_at` تلقائياً عند التعديل
- **الاستخدام:** تلقائي عبر Trigger

### 2. `create_default_vendor_sections(p_vendor_id UUID)`
- **النوع:** Stored Procedure
- **الوظيفة:** إنشاء 12 قسم افتراضي لتاجر معين
- **الاستخدام اليدوي:**
  ```sql
  SELECT create_default_vendor_sections('vendor-uuid');
  ```
- **الاستخدام من Dart:**
  ```dart
  await sectorRepository.createDefaultSections(vendorId);
  ```

### 3. `auto_create_vendor_sections()`
- **النوع:** Trigger Function
- **الوظيفة:** يتم تشغيلها تلقائياً عند إنشاء تاجر جديد
- **الاستخدام:** تلقائي عبر Trigger

---

## Triggers (2 محفزات)

### 1. `trigger_update_vendor_sections_updated_at`
- **على:** `vendor_sections`
- **متى:** BEFORE UPDATE
- **الوظيفة:** تحديث `updated_at`

### 2. `trigger_auto_create_vendor_sections`
- **على:** `vendors`
- **متى:** AFTER INSERT
- **الوظيفة:** إنشاء الأقسام الافتراضية تلقائياً للتاجر الجديد

---

## RLS Policies (5 سياسات أمان)

### 1. **Anyone can view active sections**
- **العملية:** SELECT
- **الشرط:** `is_active = true AND is_visible_to_customers = true`
- **من:** الجميع (anon + authenticated)

### 2. **Vendors can view their own sections**
- **العملية:** SELECT
- **الشرط:** `vendor_id IN (SELECT id FROM vendors WHERE user_id = auth.uid())`
- **من:** التجار المصادقين فقط

### 3. **Vendors can create their own sections**
- **العملية:** INSERT
- **الشرط:** تحقق من ملكية التاجر
- **من:** التجار المصادقين فقط

### 4. **Vendors can update their own sections**
- **العملية:** UPDATE
- **الشرط:** تحقق من ملكية التاجر (USING و WITH CHECK)
- **من:** التجار المصادقين فقط

### 5. **Vendors can delete their own sections**
- **العملية:** DELETE
- **الشرط:** تحقق من ملكية التاجر
- **من:** التجار المصادقين فقط

---

## أنواع العرض المتاحة

| Display Type | Description | items_per_row | الاستخدام |
|--------------|-------------|---------------|-----------|
| **grid** | شبكة عادية | 2-4 | الأكثر شيوعاً |
| **list** | قائمة عمودية | 1 | للتفاصيل الكاملة |
| **slider** | عرض متحرك أفقي | 1 | للصور الكبيرة |
| **carousel** | دوّار تلقائي | 1 | للعروض البارزة |
| **custom** | تخصيص خاص | متغير | حسب الحاجة |

---

## استعلامات مفيدة

### 1. عرض جميع أقسام تاجر:
```sql
SELECT * FROM vendor_sections 
WHERE vendor_id = 'vendor-uuid'
ORDER BY sort_order;
```

### 2. عرض الأقسام النشطة فقط:
```sql
SELECT * FROM vendor_sections 
WHERE vendor_id = 'vendor-uuid'
  AND is_active = true
  AND is_visible_to_customers = true
ORDER BY sort_order;
```

### 3. تحديث اسم قسم:
```sql
UPDATE vendor_sections 
SET display_name = 'Hot Deals',
    arabic_name = 'صفقات ساخنة'
WHERE id = 'section-uuid';
```

### 4. تغيير نوع العرض:
```sql
UPDATE vendor_sections 
SET display_type = 'slider',
    items_per_row = 1,
    card_width = 94.0,
    card_height = 125.0
WHERE id = 'section-uuid';
```

### 5. إخفاء قسم عن الزبائن:
```sql
UPDATE vendor_sections 
SET is_visible_to_customers = false
WHERE id = 'section-uuid';
```

### 6. إعادة ترتيب الأقسام:
```sql
-- نقل قسم للموضع الأول
UPDATE vendor_sections 
SET sort_order = 0
WHERE id = 'section-uuid';

-- تحديث باقي الأقسام
UPDATE vendor_sections 
SET sort_order = sort_order + 1
WHERE vendor_id = 'vendor-uuid'
  AND id != 'section-uuid';
```

---

## التكامل مع Flutter/Dart

### SectorModel (17 حقل)
```dart
class SectorModel {
  String? id;
  String vendorId;
  String name;  // section_key
  String englishName;  // display_name
  String? arabicName;  // ← جديد
  String displayType;  // ← جديد
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

### التحويل من/إلى JSON
```dart
// من JSON
factory SectorModel.fromJson(Map<String, dynamic> json) {
  return SectorModel(
    id: json['id'],
    vendorId: json['vendor_id'],
    name: json['section_key'],
    englishName: json['display_name'],
    arabicName: json['arabic_name'],
    displayType: json['display_type'] ?? 'grid',
    cardWidth: json['card_width']?.toDouble(),
    cardHeight: json['card_height']?.toDouble(),
    itemsPerRow: json['items_per_row'] ?? 3,
    isActive: json['is_active'] ?? true,
    isVisibleToCustomers: json['is_visible_to_customers'] ?? true,
    sortOrder: json['sort_order'] ?? 0,
    iconName: json['icon_name'],
    colorHex: json['color_hex'],
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
  );
}

// إلى JSON
Map<String, dynamic> toJson() {
  return {
    if (id != null) 'id': id,
    'vendor_id': vendorId,
    'section_key': name,
    'display_name': englishName,
    if (arabicName != null) 'arabic_name': arabicName,
    'display_type': displayType,
    if (cardWidth != null) 'card_width': cardWidth,
    if (cardHeight != null) 'card_height': cardHeight,
    'items_per_row': itemsPerRow,
    'is_active': isActive,
    'is_visible_to_customers': isVisibleToCustomers,
    'sort_order': sortOrder,
    if (iconName != null) 'icon_name': iconName,
    if (colorHex != null) 'color_hex': colorHex,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}
```

---

## الخلاصة

### التغييرات الرئيسية:
- ✅ **6 حقول** → **17 حقل** (زيادة 11 حقل جديد)
- ✅ **0 Indexes** → **6 Indexes**
- ✅ **0 Functions** → **3 Functions**
- ✅ **0 Triggers** → **2 Triggers**
- ✅ **0 Policies** → **5 RLS Policies**
- ✅ إضافة **Trigger تلقائي** لإنشاء الأقسام عند تسجيل تاجر جديد

### الفوائد:
1. **تخصيص كامل** للأقسام لكل تاجر
2. **أمان محسّن** مع RLS Policies
3. **أداء أفضل** مع Indexes محسّنة
4. **إنشاء تلقائي** للأقسام الافتراضية
5. **مرونة في العرض** (5 أنواع مختلفة)

---

**لمزيد من المعلومات:**
- السكريبت الكامل: `create_vendor_sections_complete_updated.sql`
- الدليل الشامل: `VENDOR_SECTIONS_SYSTEM_GUIDE.md`
- دليل التثبيت: `SECTIONS_COMPLETE_SETUP_GUIDE.md`

