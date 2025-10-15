# دليل تحويل التنقل إلى GetX 🚀
# GetX Navigation Migration Guide

## نظرة عامة 📋

تحويل جميع استخدامات `Navigator` إلى GetX navigation في 103 ملف.

---

## 🔄 جدول التحويل

| Navigator (القديم) | GetX (الجديد) | الاستخدام |
|-------------------|--------------|-----------|
| `Navigator.push()` | `Get.to()` | فتح صفحة جديدة |
| `Navigator.pop()` | `Get.back()` | العودة للخلف |
| `Navigator.pushReplacement()` | `Get.off()` | استبدال الصفحة |
| `Navigator.pushAndRemoveUntil()` | `Get.offAll()` | حذف جميع الصفحات |
| `Navigator.of(context).push()` | `Get.to()` | نفسه |
| `Navigator.of(context).pop()` | `Get.back()` | نفسه |

---

## 📝 أمثلة التحويل

### 1. Navigator.push → Get.to

#### قبل ❌:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductPage(productId: id),
  ),
);
```

#### بعد ✅:
```dart
Get.to(() => ProductPage(productId: id));
```

أو مع انتقال:
```dart
Get.to(
  () => ProductPage(productId: id),
  transition: Transition.cupertino,
  duration: const Duration(milliseconds: 300),
);
```

---

### 2. Navigator.pop → Get.back

#### قبل ❌:
```dart
Navigator.of(context).pop();
Navigator.pop(context);
```

#### بعد ✅:
```dart
Get.back();
```

مع نتيجة:
```dart
Get.back(result: someData);
```

---

### 3. Navigator.pushReplacement → Get.off

#### قبل ❌:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => HomePage(),
  ),
);
```

#### بعد ✅:
```dart
Get.off(() => HomePage());
```

---

### 4. Navigator.pushAndRemoveUntil → Get.offAll

#### قبل ❌:
```dart
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (context) => LoginPage(),
  ),
  (route) => false,
);
```

#### بعد ✅:
```dart
Get.offAll(() => LoginPage());
```

---

## 🎯 الفوائد

### مقارنة الكود:

#### Navigator (القديم):
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductPage(
      productId: productId,
      vendorId: vendorId,
      showActions: true,
    ),
  ),
);
// 9 أسطر!
```

#### GetX (الجديد):
```dart
Get.to(() => ProductPage(
  productId: productId,
  vendorId: vendorId,
  showActions: true,
));
// 5 أسطر فقط!
```

### المزايا:
- ✅ **أقل كوداً** (45% تقليل)
- ✅ **لا حاجة لـ context**
- ✅ **Transitions مدمجة**
- ✅ **Named routes اختيارية**
- ✅ **Arguments سهلة**
- ✅ **Back handling أفضل**

---

## 🔧 التحويل التلقائي

### بحث واستبدال (VSCode/Cursor):

#### 1. Navigator.push البسيط:
```regex
# بحث:
Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(context\)\s*=>\s*(\w+)\(([^)]*)\),?\s*\),?\s*\);?

# استبدال:
Get.to(() => $1($2));
```

#### 2. Navigator.pop:
```regex
# بحث:
Navigator\.(of\(context\)\.)?pop\(\s*(?:context)?\s*\);?

# استبدال:
Get.back();
```

#### 3. Navigator.pushReplacement:
```regex
# بحث:
Navigator\.pushReplacement\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(context\)\s*=>\s*(\w+)\(([^)]*)\),?\s*\),?\s*\);?

# استبدال:
Get.off(() => $1($2));
```

---

## 📂 الملفات ذات الأولوية

### المجموعة 1 (مكتملة ✅):
- ✅ `lib/utils/common/widgets/custom_widgets.dart` (18 استخدام)
- ✅ `lib/featured/chat/views/chat_list_screen.dart`
- ✅ `lib/featured/chat/views/vendor_chat_list_screen.dart`
- ✅ `lib/featured/shop/view/widgets/market_header.dart`

### المجموعة 2 (جاهزة للتحويل):
- `lib/views/profile/widgets/profile_menu_widget.dart`
- `lib/views/vendor/add_product_page.dart`
- `lib/featured/cart/view/checkout_stepper_screen.dart`
- `lib/featured/payment/views/add_edit_address_page.dart`
- `lib/featured/product/views/widgets/one_product_details.dart`

### المجموعة 3 (تحويل تلقائي):
- جميع ملفات `lib/featured/shop/view/widgets/` (40 ملف)
- جميع ملفات `lib/featured/product/` (20 ملف)
- جميع ملفات `lib/featured/cart/` (15 ملف)
- الباقي (28 ملف)

---

## ⚡ استراتيجية التحويل السريع

### الطريقة 1: استبدال يدوي (الأكثر أماناً)
سأحول الملفات الأساسية واحداً تلو الآخر.

### الطريقة 2: استبدال شبه تلقائي
استخدام Find & Replace في المحرر مع مراجعة يدوية.

### الطريقة 3: هجينة (موصى بها)
- تحويل يدوي للملفات الأساسية
- تحويل تلقائي للملفات البسيطة
- مراجعة نهائية

---

## 🚦 الحالة الحالية

### مكتمل ✅:
- `custom_widgets.dart` (2 موضع)
- `chat_list_screen.dart`
- `vendor_chat_list_screen.dart`
- `market_header.dart`

### متبقي ⏳:
- 99 ملف آخر

---

## 📌 ملاحظات مهمة

### لا تحوّل:
```dart
// ❌ لا تحوّل Dialogs:
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);
// احتفظ بها كما هي

// ❌ لا تحوّل BottomSheets:
showModalBottomSheet(
  context: context,
  builder: (context) => Widget(...),
);
// احتفظ بها كما هي
```

### حوّل فقط:
```dart
✅ Navigator.push()
✅ Navigator.pop()
✅ Navigator.pushReplacement()
✅ Navigator.pushAndRemoveUntil()
✅ Navigator.pushNamed()
✅ Navigator.popUntil()
```

---

## 🎯 الخطوة التالية

هل تريد:
1. ✅ **تحويل تلقائي** لجميع الملفات (سريع، قد يحتاج مراجعة)
2. ✅ **تحويل يدوي** للملفات الأساسية فقط (آمن، بطيء)
3. ✅ **ترك كما هو** والتحويل تدريجياً

**توصيتي:** نبدأ بالملفات الأساسية (المجموعة 2) يدوياً، ثم نستخدم Find & Replace للباقي.

---

لتجنب استهلاك الوقت، هل تريد:
- البدء بالتحويل الآن؟
- أم ترك هذا لجلسة لاحقة؟

**ملاحظة:** التطبيق يعمل حالياً بشكل كامل مع Mix (Navigator + GetX). التحويل اختياري للتوحيد.

