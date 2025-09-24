# Banner Controller - إصلاح وتحسين

تم إصلاح وتحسين `banner_controller.dart` لإضافة دعم `vendorId` وتحسين معالجة الأخطاء والترجمة.

## الأخطاء التي تم إصلاحها

### ✅ **إصلاح الاستيرادات**
```dart
// قبل الإصلاح (خطأ)
import 'package:istoreto/core/constants/app_urls.dart'; // غير موجود
import 'package:istoreto/utils/upload.dart'; // مكرر
import 'package:flutter/foundation.dart'; // غير مستخدم
import 'package:istoreto/utils/constants/sizes.dart'; // غير مستخدم

// بعد الإصلاح (صحيح)
// تم إزالة الاستيرادات غير الضرورية والمكررة
```

### ✅ **إصلاح استدعاءات Repository**
```dart
// قبل الإصلاح (خطأ)
var snapshot = await bannersRepo.fetchBanners(vendorId);
bannersRepo.addBanner(newBanner);
bannersRepo.deleteBanner(item.id ?? '');

// بعد الإصلاح (صحيح)
var snapshot = await bannersRepo.getVendorBannersById(vendorId);
await bannersRepo.createBanner(newBanner);
await bannersRepo.deleteBanner(item.id ?? '');
```

### ✅ **إضافة vendorId للبنر**
```dart
// قبل الإصلاح (مفقود)
var newBanner = BannerModel(
  id: '',
  image: bannerImageHostUrl,
  targetScreen: '',
  active: true,
);

// بعد الإصلاح (مكتمل)
var newBanner = BannerModel(
  id: '',
  image: bannerImageHostUrl,
  targetScreen: '',
  active: true,
  vendorId: vendorId,        // ✅ تم إضافة vendorId
  scope: BannerScope.vendor, // ✅ تم إضافة scope
);
```

## التحسينات المضافة

### ✅ **معالجة الأخطاء المحسنة**
```dart
Future<void> deleteBanner(BannerModel item, String vendorId) async {
  try {
    LoadingFullscreen.startLoading();
    await bannersRepo.deleteBanner(item.id ?? '');
    banners.remove(item);
    activeBanners.remove(item);
    TLoader.successSnackBar(
      title: 'banner.banner_deleted_successfully'.tr,
      message: '',
    );
  } catch (e) {
    TLoader.erroreSnackBar(
      message: 'banner.failed_to_delete_banner'.tr,
    );
  } finally {
    LoadingFullscreen.stopLoading();
  }
}
```

### ✅ **رسائل الترجمة**
```dart
// قبل الإصلاح (مكتوبة مباشرة)
message.value = "update status";
message.value = "upload image to server";
message.value = "Send data";

// بعد الإصلاح (مترجمة)
message.value = "banner.update_status".tr;
message.value = "banner.upload_image_to_server".tr;
message.value = "banner.send_data".tr;
```

### ✅ **إضافة مفاتيح الترجمة**

#### **في `lib/translations/en.dart`:**
```dart
// Banner Messages
'banner.image': 'Banner Image',
'banner.upload_image_to_server': 'Upload image to server',
'banner.send_data': 'Send data',
'banner.update_status': 'Update status',
'banner.banner_added_successfully': 'Banner added successfully',
'banner.banner_updated_successfully': 'Banner updated successfully',
'banner.banner_deleted_successfully': 'Banner deleted successfully',
'banner.failed_to_add_banner': 'Failed to add banner',
'banner.failed_to_update_banner': 'Failed to update banner',
'banner.failed_to_delete_banner': 'Failed to delete banner',
```

#### **في `lib/translations/ar.dart`:**
```dart
// Banner Messages
'banner.image': 'صورة البانر',
'banner.upload_image_to_server': 'رفع الصورة إلى الخادم',
'banner.send_data': 'إرسال البيانات',
'banner.update_status': 'تحديث الحالة',
'banner.banner_added_successfully': 'تم إضافة البانر بنجاح',
'banner.banner_updated_successfully': 'تم تحديث البانر بنجاح',
'banner.banner_deleted_successfully': 'تم حذف البانر بنجاح',
'banner.failed_to_add_banner': 'فشل في إضافة البانر',
'banner.failed_to_update_banner': 'فشل في تحديث البانر',
'banner.failed_to_delete_banner': 'فشل في حذف البانر',
```

## الوظائف المحدثة

### ✅ **fetchUserBanners**
- يستخدم `getVendorBannersById` بدلاً من `fetchBanners`
- يدعم `vendorId` بشكل صحيح

### ✅ **deleteBanner**
- معالجة أخطاء محسنة
- رسائل نجاح وخطأ مترجمة
- استخدام `await` للعمليات غير المتزامنة

### ✅ **addBanner**
- إضافة `vendorId` و `scope` للبنر الجديد
- معالجة أخطاء محسنة
- رسائل مترجمة

### ✅ **updateStatus**
- رسائل مترجمة
- معالجة أخطاء محسنة

## المميزات الجديدة

### ✅ **دعم vendorId**
- كل بانر مرتبط بتاجر محدد
- فلترة البانرات حسب التاجر
- أمان أفضل للبيانات

### ✅ **دعم BannerScope**
- تمييز بين بانرات الشركة والتجار
- `BannerScope.vendor` للبانرات التجارية
- `BannerScope.company` للبانرات العامة

### ✅ **الترجمة الكاملة**
- جميع الرسائل مترجمة
- دعم العربية والإنجليزية
- رسائل متسقة عبر التطبيق

### ✅ **معالجة الأخطاء**
- `try-catch` blocks شاملة
- رسائل خطأ واضحة
- معالجة الحالات الاستثنائية

## الاستخدام

### **إضافة بانر جديد**
```dart
final controller = BannerController.instance;
await controller.addBanner('gallery', vendorId);
```

### **حذف بانر**
```dart
await controller.deleteBanner(bannerModel, vendorId);
```

### **تحديث حالة البانر**
```dart
await controller.updateStatus(bannerModel, vendorId);
```

### **جلب بانرات التاجر**
```dart
await controller.fetchUserBanners(vendorId);
```

## الحالة الحالية

✅ **جميع الأخطاء تم إصلاحها**  
✅ **vendorId مدعوم بالكامل**  
✅ **الترجمة تعمل بشكل صحيح**  
✅ **معالجة الأخطاء محسنة**  
✅ **الكود يعمل بدون أخطاء**  
✅ **متوافق مع Supabase**  

النظام الآن جاهز للاستخدام! 🎉✨


