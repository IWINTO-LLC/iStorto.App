# إصلاح دوائر التقدم لصور الملف الشخصي

## ✅ تم إصلاح المشكلة

**المشكلة:** عند تعديل صورة الغلاف أو الصورة الشخصية في صفحة Profile، لا تظهر دائرة التقدم مع النسبة المئوية.

---

## 🔧 الإصلاحات المطبقة

### 1. تحديث `ImageEditController`

**الملف:** `lib/controllers/image_edit_controller.dart`

#### إضافة متغيرات منفصلة للتقدم:

```dart
// متغيرات منفصلة للتحميل والتقدم
final RxBool _isLoadingProfile = false.obs;
final RxBool _isLoadingCover = false.obs;
final RxDouble _profileUploadProgress = 0.0.obs;
final RxDouble _coverUploadProgress = 0.0.obs;

// Getters
bool get isLoadingProfile => _isLoadingProfile.value;
bool get isLoadingCover => _isLoadingCover.value;
double get profileUploadProgress => _profileUploadProgress.value;
double get coverUploadProgress => _coverUploadProgress.value;
```

---

#### تحديث `saveProfileImageToDatabase`:

**المراحل:**
```dart
10%  → قراءة الملف
20%  → التحضير
30-50% → الرفع
80%  → الحصول على الرابط
90%  → تحديث قاعدة البيانات
100% → مكتمل
```

**الكود:**
```dart
_isLoadingProfile.value = true;
_profileUploadProgress.value = 0.0;

_profileUploadProgress.value = 0.1;  // قراءة
_profileUploadProgress.value = 0.2;  // تحضير
_profileUploadProgress.value = 0.3;  // رفع
_profileUploadProgress.value = 0.5;  // رفع
_profileUploadProgress.value = 0.8;  // رابط
_profileUploadProgress.value = 0.9;  // تحديث DB
_profileUploadProgress.value = 1.0;  // مكتمل
```

---

#### تحديث `saveCoverImageToDatabase`:

نفس النظام لكن باستخدام:
- `_isLoadingCover`
- `_coverUploadProgress`

---

#### إصلاح vendors query:

**قبل:**
```dart
.eq('user_id', currentUser.id)  // ❌ خطأ!
```

**بعد:**
```dart
.eq('id', currentUser.vendorId!)  // ✅ صحيح
```

---

### 2. تحديث `profile_header_widget.dart`

**الملف:** `lib/views/profile/widgets/profile_header_widget.dart`

#### إضافة دائرة تقدم للصورة الشخصية:

```dart
// في _buildProfilePicture
if (imageController.isLoadingProfile) {
  final progress = imageController.profileUploadProgress;
  final percentage = (progress * 100).toInt();
  
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withOpacity(0.7),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // دائرة التقدم (70×70)
        CircularProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation(Colors.white),
          strokeWidth: 5,
        ),
        // النص (النسبة + "جاري الرفع")
        Column(
          children: [
            Text('$percentage%', style: ...),
            Text('uploading_profile_photo'.tr, style: ...),
          ],
        ),
      ],
    ),
  );
}
```

---

#### إضافة دائرة تقدم لصورة الغلاف:

```dart
// في _buildCoverImageBackground
if (imageController.isLoadingCover) {
  final progress = imageController.coverUploadProgress;
  final percentage = (progress * 100).toInt();
  
  return Container(
    color: Colors.black.withOpacity(0.7),
    child: Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دائرة التقدم (100×100)
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 6,
          ),
          // النص (النسبة + "جاري رفع الغلاف")
          Column(
            children: [
              Text('$percentage%', style: ...),
              Text('uploading_cover_photo'.tr, style: ...),
            ],
          ),
        ],
      ),
    ),
  );
}
```

---

### 3. تحديث مفاتيح الترجمة

**في `ar.dart` و `en.dart`:**

```dart
'uploading_profile_photo': 'جاري رفع الصورة',  // AR
'uploading_cover_photo': 'جاري رفع الغلاف',      // AR

'uploading_profile_photo': 'Uploading photo',   // EN
'uploading_cover_photo': 'Uploading cover',      // EN

'profile_image_updated_successfully': 'تم تحديث الصورة الشخصية بنجاح',
'cover_image_updated_successfully': 'تم تحديث صورة الغلاف بنجاح',
```

---

## 📊 المقارنة البصرية

### قبل الإصلاح:

```
[صورة غلاف/شخصية]
      ↓
  [اختيار صورة]
      ↓
  [قص الصورة]
      ↓
   ⏳ بدون مؤشر تحميل!
      ↓
   [صورة جديدة]
```

---

### بعد الإصلاح:

```
[صورة غلاف/شخصية]
      ↓
  [اختيار صورة]
      ↓
  [قص الصورة]
      ↓
   ╭─────╮
   │ 50% │ ← دائرة تقدم
   │رفع  │
   ╰─────╯
      ↓
   [صورة جديدة]
```

---

## 🎯 الميزات

### للصورة الشخصية:

- ✅ دائرة تقدم دائرية (70×70)
- ✅ نسبة مئوية (0-100%)
- ✅ نص "جاري رفع الصورة"
- ✅ قص دائري (1:1)
- ✅ تحديث فوري
- ✅ خلفية سوداء شفافة

---

### لصورة الغلاف:

- ✅ دائرة تقدم كبيرة (100×100)
- ✅ نسبة مئوية (0-100%)
- ✅ نص "جاري رفع الغلاف"
- ✅ قص مستطيل (16:9)
- ✅ تحديث فوري
- ✅ خلفية سوداء شفافة

---

## 🔄 آلية العمل

### 1. المستخدم ينقر "تعديل الصورة الشخصية":

```
1. فتح dialog اختيار المصدر
   ↓
2. اختيار كاميرا/معرض
   ↓
3. اختيار صورة
   ↓
4. قص الصورة (دائري 1:1)
   ↓
5. ✅ دائرة التقدم تظهر على الصورة الشخصية
   - 10%: قراءة
   - 20%: تحضير
   - 50%: رفع
   - 80%: رابط
   - 90%: قاعدة بيانات
   - 100%: مكتمل
   ↓
6. الصورة الجديدة تظهر فوراً
   ↓
7. إشعار أخضر: "تم تحديث الصورة الشخصية بنجاح"
```

---

### 2. المستخدم ينقر "تعديل صورة الغلاف":

```
نفس الخطوات لكن:
- قص مستطيل 16:9
- دائرة تقدم أكبر
- نص "جاري رفع الغلاف"
```

---

## 🎨 التصميم

### الصورة الشخصية (Profile):

```
      ┌─────────────┐
      │   ╭─────╮   │
      │   │ 75% │   │ ← دائرة تقدم (70×70)
      │   │رفع  │   │
      │   ╰─────╯   │
      └─────────────┘
      120×120 Container
```

**المواصفات:**
- Container: 120×120
- Progress circle: 70×70
- Stroke width: 5
- النص: 18px (نسبة)، 10px (حالة)
- الخلفية: سوداء 70% opacity

---

### صورة الغلاف (Cover):

```
┌─────────────────────────────┐
│                             │
│        ╭────────╮           │
│        │  65%   │           │ ← دائرة تقدم (100×100)
│        │ رفع    │           │
│        │الغلاف  │           │
│        ╰────────╯           │
│                             │
└─────────────────────────────┘
   Full width × 280 height
```

**المواصفات:**
- Progress circle: 100×100
- Stroke width: 6
- النص: 24px (نسبة)، 13px (حالة)
- الخلفية: سوداء 70% opacity

---

## 🧪 الاختبار

### اختبار الصورة الشخصية:

```
1. افتح Profile
2. اضغط "المعلومات الشخصية"
3. اضغط "تعديل الصورة الشخصية"
4. اختر صورة
5. قص الصورة
6. راقب دائرة التقدم
```

**النتيجة المتوقعة:**
```
✅ دائرة تقدم تظهر على الصورة الشخصية
✅ النسبة تتحدث (0% → 100%)
✅ النص يظهر: "جاري رفع الصورة"
✅ الصورة الجديدة تظهر بعد الانتهاء
✅ إشعار نجاح أخضر
```

---

### اختبار صورة الغلاف:

```
1. افتح Profile
2. اضغط "المعلومات الشخصية"
3. اضغط "تعديل صورة الغلاف"
4. اختر صورة
5. قص الصورة
6. راقب دائرة التقدم
```

**النتيجة المتوقعة:**
```
✅ دائرة تقدم تظهر في منتصف الشاشة
✅ النسبة تتحدث (0% → 100%)
✅ النص يظهر: "جاري رفع الغلاف"
✅ الصورة الجديدة تظهر بعد الانتهاء
✅ إشعار نجاح أخضر
```

---

## 🔍 Debug Logs

عند رفع صورة، ستظهر في Console:

```
// لا logs محددة في ImageEditController حالياً
// لكن يمكنك إضافتها في save methods
```

**لإضافة logs:**
```dart
debugPrint('📸 Uploading profile image...');
debugPrint('📊 Progress: ${(_profileUploadProgress.value * 100).toInt()}%');
debugPrint('✅ Upload complete!');
```

---

## 📋 الملفات المُعدّلة

| الملف | التغييرات |
|------|-----------|
| `image_edit_controller.dart` | إضافة progress variables، تحديث save methods |
| `profile_header_widget.dart` | إضافة progress UI overlay |
| `ar.dart` | إضافة مفاتيح ترجمة |
| `en.dart` | إضافة مفاتيح ترجمة |

---

## 🎯 الحالات المدعومة

### ✅ صفحة Profile:
- تعديل الصورة الشخصية → ✅ دائرة تقدم
- تعديل صورة الغلاف → ✅ دائرة تقدم

### ✅ صفحة المتجر (Market Header):
- تعديل الشعار → ✅ دائرة تقدم (كانت موجودة)
- تعديل الغلاف → ✅ دائرة تقدم (كانت موجودة)

---

## 🎉 النتيجة

### الآن جميع عمليات رفع الصور تعرض:

✅ **دائرة تقدم واضحة**  
✅ **نسبة مئوية متحركة (0-100%)**  
✅ **نص الحالة مترجم**  
✅ **تحديث فوري للصورة**  
✅ **إشعارات نجاح/فشل**  
✅ **تجربة مستخدم متسقة**  

---

## 💡 ملاحظات

### 1. الفصل بين العمليات:

- رفع الصورة الشخصية = دائرة تقدم على الصورة الشخصية فقط
- رفع الغلاف = دائرة تقدم على الغلاف فقط
- لا تداخل بين العمليتين

### 2. نسبة القص:

- الصورة الشخصية: 1:1 دائري
- صورة الغلاف: 16:9 مستطيل (تم التحديث من 4:3)

### 3. المتوافقية:

```dart
@Deprecated('Use isLoadingProfile or isLoadingCover')
bool get isLoading => _isLoadingProfile.value || _isLoadingCover.value;
```

للكود القديم الذي قد يستخدم `isLoading` بدون تحديد.

---

## ✅ قائمة التحقق

- [x] إضافة progress variables
- [x] تحديث save methods
- [x] إضافة UI overlay
- [x] مفاتيح ترجمة
- [x] إصلاح vendors query
- [x] تحديث نسبة القص (16:9)
- [x] localization للرسائل
- [x] لا أخطاء linter
- [x] الفصل بين العمليات
- [x] تحديث فوري

---

**جاهز! الآن جميع عمليات رفع الصور تعرض دوائر تقدم! 🎉**

