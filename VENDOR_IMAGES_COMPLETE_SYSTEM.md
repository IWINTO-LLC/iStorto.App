# نظام تعديل صور المتاجر الكامل (الشعار والغلاف)

## 📸 نظرة عامة

نظام متكامل لتحديث صور المتاجر (organization_logo و organization_cover) مع:
- ✅ دوائر تقدم منفصلة لكل صورة
- ✅ نسب مئوية للتقدم
- ✅ تحديث فوري بدون إعادة تحميل
- ✅ أيقونات كاميرا جانبية احترافية
- ✅ عرض بملء الشاشة مع زووم

---

## 🎯 الميزات

### 1. الشعار (Organization Logo)

**في وضع التعديل:**
- 📷 أيقونة كاميرا صغيرة في الزاوية **السفلية اليمنى**
- ⭕ قص دائري (Circle Crop) - نسبة 1:1
- 📊 دائرة تقدم مع نسبة مئوية
- 💬 نص: "جاري الرفع"

**في وضع العرض:**
- 🔍 عرض بملء الشاشة مع زووم
- 🚫 بدون أدوات تحكم (toolbar-free)
- ❌ زر إغلاق بسيط فقط

### 2. الغلاف (Organization Cover)

**في وضع التعديل:**
- 📷 أيقونة كاميرا صغيرة في الزاوية **السفلية اليمنى**
- 📐 قص مستطيل (Rectangle Crop) - نسبة 16:9
- 📊 دائرة تقدم مع نسبة مئوية
- 💬 نص: "جاري رفع الغلاف"

**في وضع العرض:**
- 🔍 عرض بملء الشاشة مع زووم
- 🚫 بدون أدوات تحكم
- ❌ زر إغلاق بسيط فقط

---

## 🔧 التطبيق التقني

### VendorImageController

**المتغيرات المنفصلة:**

```dart
// للشعار
final RxBool _isLoadingLogo = false.obs;
final RxDouble _logoUploadProgress = 0.0.obs;

// للغلاف
final RxBool _isLoadingCover = false.obs;
final RxDouble _coverUploadProgress = 0.0.obs;

// Getters
bool get isLoadingLogo => _isLoadingLogo.value;
bool get isLoadingCover => _isLoadingCover.value;
double get logoUploadProgress => _logoUploadProgress.value;
double get coverUploadProgress => _coverUploadProgress.value;
```

**مراحل التقدم:**

| المرحلة | النسبة | الوصف |
|---------|--------|-------|
| قراءة الملف | 10% | قراءة بيانات الصورة |
| التحضير | 20% | إنشاء اسم الملف |
| الرفع | 30% → 50% | رفع إلى Supabase Storage |
| الرابط | 85% | الحصول على URL |
| قاعدة البيانات | 90% | تحديث جدول vendors |
| المكتمل | 100% | تحديث واجهة المستخدم |

**دالة التقدم المساعدة:**

```dart
void _setProgress(bool isCover, double value) {
  if (isCover) {
    _coverUploadProgress.value = value;
  } else {
    _logoUploadProgress.value = value;
  }
}
```

---

## 📱 الواجهة البصرية

### 1. الشعار (Logo) - في وضع التعديل

```
┌─────────────────────┐
│                     │
│    ╭─────────╮      │
│    │  LOGO   │      │
│    │         │      │
│    ╰─────────╯      │
│          ⚫📷       │ ← Camera badge (bottom-right)
└─────────────────────┘
```

**أثناء التحميل:**
```
┌─────────────────────┐
│                     │
│    ╭─────────╮      │
│    │  ╭───╮  │      │ ← دائرة التقدم
│    │  │75%│  │      │ ← النسبة
│    │  │رفع│  │      │ ← النص
│    ╰─────────╯      │
└─────────────────────┘
```

### 2. الغلاف (Cover) - في وضع التعديل

```
┌───────────────────────────────┐
│                               │
│         COVER IMAGE           │
│                               │
│                      ⚫📷     │ ← Camera badge (bottom-right)
└───────────────────────────────┘
```

**أثناء التحميل:**
```
┌───────────────────────────────┐
│                               │
│          ╭───────╮            │ ← دائرة التقدم
│          │  65%  │            │ ← النسبة
│          │ رفع   │            │ ← النص
│          │الغلاف │            │
│          ╰───────╯            │
└───────────────────────────────┘
```

---

## 🎨 التفاصيل البصرية

### أيقونة الكاميرا (Edit Mode)

```dart
Container(
  padding: const EdgeInsets.all(10),  // شعار: 8, غلاف: 10
  decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.7),
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Icon(
    Icons.camera_alt,
    color: Colors.white,
    size: 20,  // شعار: 18, غلاف: 20
  ),
)
```

### دائرة التقدم (Loading)

**للشعار:**
```dart
SizedBox(
  width: 70,
  height: 70,
  child: CircularProgressIndicator(
    value: progress,  // 0.0 إلى 1.0
    backgroundColor: Colors.white.withOpacity(0.3),
    valueColor: AlwaysStoppedAnimation(Colors.white),
    strokeWidth: 5,
  ),
)
```

**للغلاف:**
```dart
SizedBox(
  width: 80,
  height: 80,
  child: CircularProgressIndicator(
    value: progress,  // 0.0 إلى 1.0
    backgroundColor: Colors.white.withOpacity(0.3),
    valueColor: AlwaysStoppedAnimation(Colors.white),
    strokeWidth: 6,
  ),
)
```

---

## 🔄 آلية العمل

### عند النقر على الشعار:

```
1. المستخدم ينقر على الشعار
   ↓
2. if (editMode) → فتح image picker
   else → عرض fullscreen مع zoom
   ↓
3. اختيار صورة من الكاميرا أو المعرض
   ↓
4. قص الصورة (دائري 1:1)
   ↓
5. إظهار دائرة التقدم (0% → 100%)
   - 10%: قراءة الملف
   - 20%: تحضير
   - 50%: رفع
   - 85%: رابط
   - 90%: قاعدة بيانات
   - 100%: مكتمل
   ↓
6. تحديث VendorController
   ↓
7. عرض الشعار الجديد فوراً
   ↓
8. إشعار أخضر: "تم تحديث شعار المتجر بنجاح!"
```

### عند النقر على الغلاف:

```
نفس الخطوات لكن مع:
- قص مستطيل 16:9
- نص: "جاري رفع الغلاف"
- إشعار: "تم تحديث صورة الغلاف بنجاح!"
```

---

## 🛠️ الإصلاحات المطبقة

### 1. فصل حالات التحميل

**قبل:**
```dart
❌ متغير isLoading واحد
❌ متغير uploadProgress واحد
❌ عند تعديل أي صورة، تظهر دائرة التحميل على الاثنين
```

**بعد:**
```dart
✅ isLoadingLogo منفصل
✅ isLoadingCover منفصل
✅ logoUploadProgress منفصل
✅ coverUploadProgress منفصل
✅ كل صورة لها دائرة تقدم مستقلة
```

### 2. إصلاح قاعدة البيانات

**قبل:**
```dart
❌ .eq('user_id', vendorId)  // خطأ
```

**بعد:**
```dart
✅ .eq('id', vendorId)  // صحيح
✅ إضافة .select() للتحقق
✅ إضافة debug logs
```

### 3. إصلاح إعدادات القص

**قبل:**
```dart
❌ CropStyle.circle للاثنين
```

**بعد:**
```dart
✅ CropStyle.rectangle للغلاف (16:9)
✅ CropStyle.circle للشعار (1:1)
```

---

## 📋 ملفات السكريبتات

### 1. `fix_vendor_image_update_policy.sql`
- إصلاح RLS policies
- ضمان صلاحيات UPDATE
- التحقق من السياسات

### 2. `debug_vendor_image_update.sql`
- تشخيص المشاكل
- فحص البيانات
- اختبار الاستعلامات

---

## 🧪 الاختبار

### خطوات الاختبار:

1. **افتح التطبيق في وضع debug**

2. **اختبر الشعار:**
   ```
   - انتقل لصفحة المتجر في edit mode
   - اضغط على الشعار
   - اختر صورة
   - راقب دائرة التقدم
   - تأكد من ظهور الشعار الجديد
   ```

3. **اختبر الغلاف:**
   ```
   - اضغط على صورة الغلاف
   - اختر صورة
   - راقب دائرة التقدم
   - تأكد من ظهور الغلاف الجديد
   ```

4. **اختبر الفصل:**
   ```
   - ابدأ رفع الشعار
   - بينما يتم الرفع، جرب النقر على الغلاف
   - يجب أن تظهر دائرة تقدم الشعار فقط
   - الغلاف لا يجب أن يتأثر
   ```

5. **اختبر وضع العرض:**
   ```
   - اخرج من edit mode
   - اضغط على الشعار → fullscreen zoom
   - اضغط على الغلاف → fullscreen zoom
   - لا أدوات تحكم، فقط زر إغلاق
   ```

### النتائج المتوقعة:

✅ دوائر تقدم منفصلة لكل صورة  
✅ تحديث فوري بعد الرفع  
✅ أيقونات كاميرا في الزوايا السفلية  
✅ قص دائري للشعار، مستطيل للغلاف  
✅ عرض fullscreen مع zoom في وضع العرض  
✅ Debug logs واضحة في console  

---

## 📊 المتغيرات والحالات

### VendorImageController State:

| المتغير | النوع | الوصف |
|---------|------|-------|
| `isLoadingLogo` | bool | حالة رفع الشعار |
| `isLoadingCover` | bool | حالة رفع الغلاف |
| `logoUploadProgress` | double | تقدم رفع الشعار (0.0-1.0) |
| `coverUploadProgress` | double | تقدم رفع الغلاف (0.0-1.0) |

### UI States (MarketHeader):

| الحالة | الشعار | الغلاف |
|--------|--------|--------|
| عادي (Edit Mode) | أيقونة كاميرا | أيقونة كاميرا |
| أثناء الرفع | دائرة تقدم 0-100% | دائرة تقدم 0-100% |
| عادي (View Mode) | عرض عادي | عرض عادي |
| عند النقر (View) | Fullscreen + Zoom | Fullscreen + Zoom |

---

## 🎨 التخصيصات البصرية

### أيقونة الكاميرا:

**الموقع:**
- الشعار: `bottom: 0, right: 0`
- الغلاف: `bottom: 16, right: 16`

**الحجم:**
- الشعار: `padding: 8, iconSize: 18`
- الغلاف: `padding: 10, iconSize: 20`

**اللون:**
- خلفية: `Colors.black.opacity(0.7)`
- أيقونة: `Colors.white`
- ظل: `Colors.black.opacity(0.3)`

### دائرة التقدم:

**الحجم:**
- الشعار: `70x70, strokeWidth: 5`
- الغلاف: `80x80, strokeWidth: 6`

**النص:**
- النسبة: `fontSize: 18-20, fontWeight: bold`
- الحالة: `fontSize: 10-12, opacity: 0.8`

---

## 🐛 استكشاف الأخطاء

### المشكلة: الصورة لا تتحدث

**الحل:**
```sql
-- نفذ في Supabase SQL Editor
SELECT * FROM vendors WHERE id = 'YOUR_VENDOR_ID';

-- إذا لم تظهر نتائج:
-- 1. نفذ fix_vendor_image_update_policy.sql
-- 2. تحقق من RLS policies
-- 3. تحقق من الصلاحيات
```

### المشكلة: دائرة التقدم لا تظهر

**الحل:**
```dart
// تأكد من تهيئة Controller
if (editMode && !Get.isRegistered<VendorImageController>()) {
  Get.put(VendorImageController());
}
```

### المشكلة: دائرة التقدم تظهر للاثنين

**الحل:**
```dart
✅ تم الإصلاح - الآن كل صورة لها متغيرات منفصلة
```

### المشكلة: القص غير صحيح

**الحل:**
```dart
✅ تم الإصلاح:
- الشعار: CropStyle.circle (1:1)
- الغلاف: CropStyle.rectangle (16:9)
```

---

## 📝 الكود المهم

### في market_header.dart:

**للغلاف:**
```dart
// Line 166-168
if (editMode && Get.isRegistered<VendorImageController>())
  Obx(() {
    final isLoading = VendorImageController.instance.isLoadingCover;
    final progress = VendorImageController.instance.coverUploadProgress;
    // ...
  })
```

**للشعار:**
```dart
// Line 507-509
if (editMode && Get.isRegistered<VendorImageController>())
  Obx(() {
    final isLoading = VendorImageController.instance.isLoadingLogo;
    final progress = VendorImageController.instance.logoUploadProgress;
    // ...
  })
```

### في vendor_image_controller.dart:

**تعيين التقدم:**
```dart
// Line 282-288
void _setProgress(bool isCover, double value) {
  if (isCover) {
    _coverUploadProgress.value = value;
  } else {
    _logoUploadProgress.value = value;
  }
}
```

**التحديث في قاعدة البيانات:**
```dart
// Line 301-310
final response = await SupabaseService.client
    .from('vendors')
    .update({fieldName: imageUrl})
    .eq('id', vendorId)  // ✅ استخدام id وليس user_id
    .select();
```

---

## ✅ قائمة التحقق

قبل النشر، تأكد من:

- [ ] تنفيذ `fix_vendor_image_update_policy.sql` في Supabase
- [ ] اختبار رفع الشعار
- [ ] اختبار رفع الغلاف
- [ ] التحقق من الفصل بين الاثنين
- [ ] اختبار fullscreen zoom في view mode
- [ ] مراجعة debug logs
- [ ] اختبار معالجة الأخطاء
- [ ] التحقق من RLS policies

---

## 🎉 النتيجة النهائية

### الشعار (Logo):
- ✅ قابل للتعديل بنقرة واحدة
- ✅ قص دائري احترافي
- ✅ دائرة تقدم منفصلة
- ✅ تحديث فوري
- ✅ zoom في وضع العرض

### الغلاف (Cover):
- ✅ قابل للتعديل بنقرة واحدة
- ✅ قص مستطيل 16:9
- ✅ دائرة تقدم منفصلة
- ✅ تحديث فوري
- ✅ zoom في وضع العرض

### التجربة:
- ✅ سلسة وسريعة
- ✅ واضحة ومباشرة
- ✅ احترافية
- ✅ بدون تعقيدات

---

## 📚 الملفات المعدلة

1. ✅ `lib/featured/shop/controller/vendor_image_controller.dart`
   - إضافة متغيرات منفصلة
   - دالة _setProgress
   - تحديث معالجة الأخطاء
   - إصلاح crop styles

2. ✅ `lib/featured/shop/view/widgets/market_header.dart`
   - إضافة click handler للغلاف
   - دوائر تقدم منفصلة
   - أيقونات كاميرا في الزوايا
   - fullscreen viewer للعرض

3. ✅ `lib/featured/album/screens/fullscreen_image_viewer.dart`
   - إضافة hideControls parameter
   - زر إغلاق بسيط

4. 📝 `fix_vendor_image_update_policy.sql` (جديد)
5. 📝 `debug_vendor_image_update.sql` (جديد)
6. 📝 `VENDOR_IMAGE_UPDATE_FIX.md` (جديد)
7. 📝 `VENDOR_IMAGES_COMPLETE_SYSTEM.md` (هذا الملف)

---

تم إصلاح جميع المشاكل! النظام جاهز للاستخدام. 🚀

