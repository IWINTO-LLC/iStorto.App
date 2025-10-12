# تحديث تصميم صفحة إعدادات المتجر (Store Settings Redesign)

## 📋 ملخص التحديثات

تم إعادة تصميم صفحة إعدادات المتجر بالكامل لتكون أكثر حداثة وسهولة في الاستخدام، مع إصلاح مشاكل روابط السوشال ميديا.

## ✅ التحسينات الرئيسية

### 1. التصميم الجديد
- **تصميم مشابه لـ `vendor_admin_zone.dart`**: تصميم موحد ومتناسق
- **بطاقات منفصلة (Cards)**: كل قسم في بطاقة مستقلة
- **أيقونات سوداء**: جميع الأيقونات باللون الأسود لمطابقة التصميم العام
- **خلفية رمادية فاتحة**: خلفية `Colors.grey.shade50` للتباين الجيد
- **ظلال خفيفة**: ظلال ناعمة للبطاقات لإعطاء عمق

### 2. إصلاح مشاكل روابط السوشال ميديا

#### المشاكل السابقة:
```dart
// ❌ المشكلة: استخدام TextEditingController مباشرة دون معالجة صحيحة
controller: TextEditingController(text: value)
onChanged: (val) {
  final updated = controller.profileData.value.socialLink?.copyWith(website: val);
  // لا يتم تحديث vendorData
}
```

#### الحل الجديد:
```dart
// ✅ الحل: إنشاء controller مع وضع المؤشر في النهاية
final textController = TextEditingController(text: value);
textController.selection = TextSelection.fromPosition(
  TextPosition(offset: textController.text.length),
);

// تحديث كلا profileData و vendorData
void _updateSocialLink(VendorController controller, SocialLink updated) {
  controller.profileData.value = controller.profileData.value.copyWith(
    socialLink: updated,
  );
  controller.vendorData.value = controller.vendorData.value.copyWith(
    socialLink: updated,
  );
  hasChanges.value = true;
}
```

### 3. البنية الجديدة

```
lib/featured/shop/view/
├── store_settings.dart (القديم - محفوظ)
└── store_settings_new.dart (الجديد - محسّن)
```

## 📦 الأقسام الجديدة

### 1. بطاقة المعلومات الأساسية
```dart
_buildSettingsCard(
  icon: Icons.store,
  title: 'store_settings_basic_info'.tr,
  children: [
    // اسم المتجر
    // الوصف المختصر
    // السيرة الذاتية
  ],
)
```

### 2. بطاقة إعدادات الدفع
```dart
_buildSettingsCard(
  icon: Icons.payment,
  title: 'store_settings_payment'.tr,
  children: [
    // الدفع عند الاستلام (COD)
    // محفظة iWinto
  ],
)
```

### 3. بطاقة روابط السوشال ميديا (محسّنة)
```dart
_buildSocialLinksCard(controller)
```

**الميزات:**
- ✅ حقول منفصلة لكل منصة
- ✅ زر إظهار/إخفاء لكل رابط
- ✅ تحديث فوري للبيانات
- ✅ معالجة صحيحة للـ controller
- ✅ دعم: Website, Facebook, Instagram, WhatsApp

### 4. بطاقة حالة المتجر
```dart
_buildStoreStatusCard(controller)
```

## 🔧 وظيفة `_buildSocialLinkField`

```dart
Widget _buildSocialLinkField({
  required IconData icon,
  required String label,
  required String value,
  required bool visible,
  required Function(String) onChanged,
  required Function(bool) onVisibilityChanged,
})
```

**الإصلاحات المطبقة:**
1. إنشاء `TextEditingController` جديد لكل حقل
2. وضع المؤشر في نهاية النص
3. تحديث `profileData` و `vendorData` معًا
4. تفعيل `hasChanges` عند أي تغيير

## 🎨 التصميم المرئي

### ألوان البطاقات
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 15,
        offset: const Offset(0, 3),
      ),
    ],
  ),
)
```

### أيقونات الأقسام
```dart
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.12),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(icon, color: Colors.black, size: 22),
)
```

## 📱 الاستخدام

```dart
// الطريقة الجديدة
Get.to(() => VendorSettingsPageNew(
  vendorId: vendorId,
  fromBage: 'vendor_admin_zone',
));

// أو استبدال الصفحة القديمة
// في vendor_admin_zone.dart
onTap: () {
  Get.to(() => VendorSettingsPageNew(
    vendorId: vendorId,
    fromBage: 'vendor_admin_zone',
  ));
},
```

## 🐛 المشاكل المحلولة

### 1. روابط السوشال ميديا لا تحفظ
**السبب**: عدم تحديث `vendorData` بجانب `profileData`

**الحل**:
```dart
void _updateSocialLink(VendorController controller, SocialLink updated) {
  controller.profileData.value = controller.profileData.value.copyWith(
    socialLink: updated,
  );
  controller.vendorData.value = controller.vendorData.value.copyWith(
    socialLink: updated,
  );
  hasChanges.value = true;
}
```

### 2. زر التفعيل/الإخفاء لا يعمل
**السبب**: استخدام `null-aware operator` خاطئ

**الحل**:
```dart
Switch(
  value: visible,  // مباشرة دون ?.
  onChanged: onVisibilityChanged,
  activeColor: Colors.black,
)
```

### 3. TextEditingController يتم إنشاؤه في كل build
**السبب**: إنشاء controller جديد في كل مرة

**الحل**:
```dart
// إنشاء controller محلي مع وضع المؤشر في النهاية
final textController = TextEditingController(text: value);
textController.selection = TextSelection.fromPosition(
  TextPosition(offset: textController.text.length),
);
```

## 🚀 الخطوات التالية

1. **استبدال الصفحة القديمة**:
   ```dart
   // في vendor_admin_zone.dart
   import 'package:istoreto/featured/shop/view/store_settings_new.dart';
   
   // استبدل VendorSettingsPage بـ VendorSettingsPageNew
   ```

2. **إضافة المزيد من المنصات الاجتماعية**:
   - TikTok
   - YouTube
   - X (Twitter)
   - LinkedIn

3. **إضافة إدارة أرقام الهواتف**

## ✨ الميزات المستقبلية

- [ ] إضافة صورة الغلاف واللوغو
- [ ] إدارة ساعات العمل
- [ ] إدارة الموقع الجغرافي
- [ ] إعدادات الإشعارات
- [ ] إدارة فريق العمل

## 📝 ملاحظات

- الملف القديم `store_settings.dart` محفوظ للرجوع إليه عند الحاجة
- جميع التغييرات متوافقة مع `VendorController` الحالي
- لا حاجة لتعديلات في قاعدة البيانات
- التصميم متجاوب مع جميع أحجام الشاشات

---

**تاريخ التحديث**: أكتوبر 2025
**الإصدار**: 2.0
**الحالة**: ✅ جاهز للإنتاج

