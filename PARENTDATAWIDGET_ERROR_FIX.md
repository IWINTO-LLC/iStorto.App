# ParentDataWidget Error Fix

## المشكلة
```
Exception caught by widgets library
Incorrect use of ParentDataWidget.
```

## السبب
حدثت المشكلة بسبب استخدام `Flexible` داخل `Row` مع `mainAxisSize: MainAxisSize.min`.

عندما يكون `Row` بحجم `MainAxisSize.min`, فإنه يحاول أن يكون بأصغر حجم ممكن، وهذا يتعارض مع `Flexible` الذي يحتاج إلى مساحة قابلة للتوسع.

## الملفات المصابة والتصحيحات

### 1. `lib/featured/shop/view/widgets/sector_stuff.dart`

#### الخطأ الأول (السطر 70-104):
```dart
❌ قبل:
Row(
  children: [
    Flexible(
      child: Visibility(
        visible: withTitle,
        child: BuildSectorTitle(...),
      ),
    ),
    GestureDetector(
      child: Visibility(
        visible: editMode,
        child: ...
      ),
    ),
  ],
)
```

```dart
✅ بعد:
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    if (withTitle)
      Flexible(
        child: BuildSectorTitle(...),
      ),
    if (editMode)
      GestureDetector(
        child: ...
      ),
  ],
)
```

#### الخطأ الثاني (السطر 309-352):
```dart
❌ قبل:
Row titleWithEdit(...) {
  return Row(
    mainAxisSize: MainAxisSize.min,  // ❌ مشكلة!
    children: [
      Flexible(
        child: Visibility(...),
      ),
      ...
    ],
  );
}
```

```dart
✅ بعد:
Row titleWithEdit(...) {
  return Row(
    // إزالة mainAxisSize: MainAxisSize.min
    children: [
      Flexible(
        child: Visibility(...),
      ),
      ...
    ],
  );
}
```

### 2. `lib/featured/shop/view/widgets/grid_builder_custom_card.dart`

#### الخطأ (السطر 212-236):
```dart
❌ قبل:
child: Row(
  mainAxisSize: MainAxisSize.min,  // ❌ مشكلة!
  children: [
    const Icon(...),
    const SizedBox(width: 6),
    Flexible(
      child: Text(...),
    ),
  ],
),
```

```dart
✅ بعد:
child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(...),
    const SizedBox(width: 6),
    Flexible(
      child: Text(...),
    ),
  ],
),
```

## القاعدة العامة

### ❌ لا تفعل:
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Flexible(child: ...),  // خطأ!
    Expanded(child: ...),  // خطأ!
  ],
)
```

### ✅ افعل:
```dart
// الخيار 1: استخدم MainAxisSize.max (الافتراضي)
Row(
  children: [
    Flexible(child: ...),  // ✓ صحيح
    Expanded(child: ...),  // ✓ صحيح
  ],
)

// الخيار 2: لا تستخدم Flexible/Expanded مع min
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(...),  // ✓ صحيح
    Icon(...),  // ✓ صحيح
  ],
)
```

## التحسينات الإضافية

### استخدام `if` بدلاً من `Visibility`
```dart
❌ قبل:
children: [
  Visibility(
    visible: condition,
    child: Widget(),
  ),
]

✅ بعد:
children: [
  if (condition)
    Widget(),
]
```

**الفوائد:**
1. أداء أفضل - لا يتم إنشاء widget إذا كان الشرط `false`
2. كود أنظف وأقصر
3. تجنب مشاكل layout غير ضرورية

## الاختبار
بعد التصحيح، تم اختبار:
- ✅ `market_place_view.dart` - يعمل بدون أخطاء
- ✅ `all_tab.dart` - يعمل بدون أخطاء
- ✅ `sector_builder.dart` - يعمل بدون أخطاء
- ✅ `grid_builder_custom_card.dart` - يعمل بدون أخطاء

## ملاحظات
- `Flexible` و `Expanded` يحتاجان إلى parent يكون `Row`, `Column`, أو `Flex` مع `mainAxisSize: MainAxisSize.max` (الافتراضي)
- `mainAxisSize: MainAxisSize.min` يعني أن الـ parent سيكون بحجم أطفاله بالضبط، مما يجعل `Flexible` و `Expanded` بلا معنى
- استخدم `if` statements في `children` lists بدلاً من `Visibility` كلما أمكن

---

**تاريخ الإصلاح:** October 12, 2025
**الملفات المعدلة:** 2
**نوع الخطأ:** Layout/Rendering Error
**الحالة:** ✅ تم الحل

