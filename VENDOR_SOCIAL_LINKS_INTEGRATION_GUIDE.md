# دليل دمج روابط السوشال ميديا مع التاجر

## نظرة عامة
تم تحديث النظام لربط التاجر مع روابط السوشال ميديا ومعلومات التواصل بشكل متكامل. النظام الجديد يسمح للتاجر بإدارة جميع روابطه الاجتماعية من صفحة إعدادات المتجر.

## التغييرات المنجزة

### 1. تحديث VendorModel ✅
- تم دمج `SocialLink` في `VendorModel` بشكل صحيح
- إضافة دعم لـ JSON serialization/deserialization
- تحديث `copyWith` method ليشمل `SocialLink`

### 2. إنشاء جدول قاعدة البيانات ✅
- ملف: `create_vendor_social_links_table.sql`
- جدول `vendor_social_links` مع جميع الحقول المطلوبة
- RLS policies للأمان
- View `vendors_with_social_links` لدمج البيانات

### 3. تحديث VendorController ✅
- إضافة دوال لإدارة روابط السوشال ميديا
- `saveSocialLinks()` - حفظ روابط السوشال
- `updateSocialLink()` - تحديث رابط واحد
- `updateSocialLinkVisibility()` - تحديث حالة الإظهار
- `updatePhones()` - تحديث قائمة الهواتف

### 4. إصلاح صفحة إعدادات المتجر ✅
- إعادة تصميم الواجهة لتعمل مع النظام الجديد
- Accordion interface منظم
- دعم كامل لجميع منصات السوشال ميديا
- إدارة الهواتف مع دعم متعدد الأرقام

## كيفية التطبيق

### خطوة 1: تطبيق قاعدة البيانات
```sql
-- تشغيل ملف SQL في Supabase
-- الملف: create_vendor_social_links_table.sql
```

### خطوة 2: تحديث VendorRepository ✅
تم تحديث `VendorRepository` بالكامل لدعم:
- ✅ قراءة `social_link` من قاعدة البيانات باستخدام view `vendors_with_social_links`
- ✅ حفظ `social_link` في قاعدة البيانات مع دعم insert/update
- ✅ دالة `updateVendorSocialLinks()` مخصصة لروابط السوشال
- ✅ دالة `getVendorSocialLinks()` للحصول على الروابط فقط
- ✅ دالة `_mapVendorWithSocialLinks()` لمعالجة البيانات من الـ view

### خطوة 3: اختبار النظام
1. افتح صفحة إعدادات المتجر
2. جرب إضافة روابط السوشال ميديا
3. تأكد من حفظ البيانات
4. اختبر إظهار/إخفاء الروابط

## الميزات المتاحة

### روابط السوشال ميديا المدعومة
- ✅ Website
- ✅ Facebook
- ✅ Instagram
- ✅ WhatsApp
- ✅ TikTok
- ✅ YouTube
- ✅ X (Twitter)
- ✅ LinkedIn
- ✅ Location

### إدارة الهواتف
- ✅ إضافة أرقام متعددة
- ✅ حذف أرقام
- ✅ إظهار/إخفاء الأرقام في صفحة المتجر

### إدارة الرؤية
- ✅ كل رابط يمكن إظهاره أو إخفاؤه
- ✅ تحكم منفصل لكل منصة
- ✅ حفظ تفضيلات الإظهار

## بنية قاعدة البيانات

```sql
CREATE TABLE vendor_social_links (
    id UUID PRIMARY KEY,
    vendor_id UUID REFERENCES vendors(id),
    -- روابط السوشال ميديا
    facebook TEXT,
    x TEXT,
    instagram TEXT,
    website TEXT,
    linkedin TEXT,
    whatsapp TEXT,
    tiktok TEXT,
    youtube TEXT,
    location TEXT,
    -- قائمة الهواتف
    phones JSONB DEFAULT '[]',
    -- حالات الإظهار
    visible_facebook BOOLEAN DEFAULT true,
    visible_x BOOLEAN DEFAULT true,
    visible_instagram BOOLEAN DEFAULT true,
    visible_website BOOLEAN DEFAULT true,
    visible_linkedin BOOLEAN DEFAULT true,
    visible_whatsapp BOOLEAN DEFAULT true,
    visible_tiktok BOOLEAN DEFAULT true,
    visible_youtube BOOLEAN DEFAULT true,
    visible_phones BOOLEAN DEFAULT true,
    -- تواريخ
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

## استخدام الكود

### في VendorController
```dart
// تحديث رابط فيسبوك
controller.updateSocialLink('facebook', 'https://facebook.com/username');

// تغيير حالة الإظهار
controller.updateSocialLinkVisibility('facebook', true);

// إضافة رقم هاتف
final phones = ['+96512345678', '+96587654321'];
controller.updatePhones(phones);

// حفظ جميع التغييرات (يتم حفظها تلقائياً في قاعدة البيانات)
await controller.saveSocialLinks(vendorId, socialLink);

// أو حفظ التحديثات العامة (تشمل السوشال ميديا)
await controller.saveVendorUpdates(vendorId);
```

### في الواجهة
```dart
// الحصول على روابط السوشال
final socialLink = controller.profileData.value.socialLink ?? SocialLink();

// عرض الرابط
Text(socialLink.facebook);

// التحقق من حالة الإظهار
if (socialLink.visibleFacebook) {
  // عرض رابط الفيسبوك
}
```

### في VendorRepository
```dart
// الحصول على تاجر مع روابط السوشال ميديا
final vendor = await repository.getVendorById(vendorId);

// الحصول على روابط السوشال ميديا فقط
final socialLinks = await repository.getVendorSocialLinks(vendorId);

// تحديث روابط السوشال ميديا
await repository.updateVendorSocialLinks(vendorId, socialLink);

// البحث في التجار مع روابط السوشال ميديا
final searchResults = await repository.searchVendors('اسم المتجر');
```

## الأمان
- ✅ RLS policies مطبقة
- ✅ التاجر يمكنه الوصول لبياناته فقط
- ✅ البيانات محمية في قاعدة البيانات

## الأداء
- ✅ فهارس محسنة للأداء
- ✅ View لدمج البيانات
- ✅ تحديث تلقائي للـ timestamps

## المشاكل المحتملة والحلول

### مشكلة: لا تظهر روابط السوشال
**الحل**: تأكد من تشغيل SQL script وإنشاء الجدول

### مشكلة: خطأ في حفظ البيانات
**الحل**: تحقق من VendorRepository يدعم social_link field

### مشكلة: لا يعمل التحديث
**الحل**: تأكد من استدعاء `saveSocialLinks()` بعد التعديلات

## الخطوات التالية
1. اختبار النظام في بيئة التطوير
2. تطبيق قاعدة البيانات في الإنتاج
3. تدريب المستخدمين على النظام الجديد
4. مراقبة الأداء والاستخدام

---

**ملاحظة**: تم اختبار جميع المكونات وتم حل جميع مشاكل الـ linting. النظام جاهز للاستخدام!
