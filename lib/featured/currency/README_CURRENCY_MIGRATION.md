# Currency System Migration - تحديث نظام العملات

تم تحديث نظام العملات ليعمل مع Supabase بدلاً من Firestore.

## التحديثات الرئيسية

### 1. **CurrencyController** (`lib/featured/currency/controller/currency_controller.dart`)
- **تم إزالة**: جميع تبعيات Firestore
- **تم إضافة**: تكامل Supabase من خلال CurrencyRepository
- **تم تحديث**: دوال التحويل لتعمل مع هيكل البيانات الجديد
- **تم إضافة**: دوال إضافية لإدارة العملات

### 2. **CurrencyRepository** (`lib/featured/payment/data/currency_repository.dart`)
- **تم إضافة**: دوال شاملة لإدارة العملات
- **تم إضافة**: دعم للبحث والتصفية
- **تم إضافة**: دعم للتحويل بين العملات
- **تم إضافة**: دعم للإحصائيات والتحليلات

### 3. **Database Schema** (`lib/utils/supabase_currency_schema.sql`)
- **الجدول**: `currencies`
- **المميزات**:
  - Row Level Security (RLS) مفعل
  - تحديث تلقائي للطوابع الزمنية
  - فهارس للأداء
  - دوال مساعدة للتحويل
  - عرض العملات الشائعة

## هيكل البيانات الجديد

### جدول `currencies`:
```sql
CREATE TABLE currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    iso TEXT NOT NULL UNIQUE,
    usd_to_coin_exchange_rate DECIMAL(10,6) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## إعداد قاعدة البيانات

### الخطوة 1: تشغيل SQL Schema
```sql
-- في Supabase SQL Editor
-- انسخ والصق محتوى supabase_currency_schema.sql
-- وقم بتشغيله
```

### الخطوة 2: التحقق من إنشاء الجدول
بعد تشغيل SQL، تأكد من إنشاء:
- ✅ جدول `currencies`
- ✅ سياسات RLS
- ✅ الفهارس
- ✅ الدوال المساعدة
- ✅ عرض `popular_currencies`

## الاستخدام الجديد

### 1. **تحميل العملات**
```dart
final currencyController = Get.find<CurrencyController>();

// تحميل جميع العملات
await currencyController.fetchAllCurrencies();

// تحميل العملات الشائعة
final popularCurrencies = await currencyController.getPopularCurrencies();
```

### 2. **التحويل بين العملات**
```dart
// تحويل محلي (سريع)
final convertedAmount = currencyController.convert(100.0, 'USD', 'EUR');

// تحويل من الخادم (دقيق)
final convertedAmount = await currencyController.convertCurrency('USD', 'EUR', 100.0);
```

### 3. **إدارة العملة الافتراضية**
```dart
// الحصول على العملة الافتراضية
final defaultCurrency = currencyController.currentUserCurrency;

// تحديث العملة الافتراضية
await currencyController.updateDefaultCurrency(userId, 'EUR');
```

### 4. **البحث والتصفية**
```dart
// البحث عن عملة
final currency = await currencyController.getCurrencyByISO('USD');

// التحقق من توفر العملة
final isAvailable = currencyController.isCurrencyAvailable('EUR');
```

## الدوال المتاحة في Repository

### 1. **العمليات الأساسية**
```dart
// إنشاء عملة جديدة
await repository.createCurrency(currency);

// الحصول على عملة بالمعرف
await repository.getCurrencyById(currencyId);

// الحصول على عملة بالرمز
await repository.getCurrencyByISO('USD');

// تحديث عملة
await repository.updateCurrency(currency);

// حذف عملة
await repository.deleteCurrency(currencyId);
```

### 2. **البحث والتصفية**
```dart
// البحث عن عملات
await repository.searchCurrencies('Dollar');

// تصفية العملات
await repository.getCurrenciesFiltered(
  searchQuery: 'Dollar',
  minRate: 1.0,
  maxRate: 10.0,
  page: 0,
  limit: 20,
);

// العملات الشائعة
await repository.getPopularCurrencies();
```

### 3. **التحويل والإحصائيات**
```dart
// تحويل العملات
await repository.convertCurrency('USD', 'EUR', 100.0);

// الحصول على معدل التحويل
await repository.getConversionRate('USD', 'EUR');

// إحصائيات العملات
await repository.getCurrencyStatistics();
```

### 4. **العمليات المتقدمة**
```dart
// تحديث معدلات متعددة
await repository.updateMultipleExchangeRates({
  'USD': 1.0,
  'EUR': 0.85,
  'GBP': 0.73,
});

// العملات النشطة
await repository.getActiveCurrencies();

// مراقبة التغييرات (Real-time)
repository.watchCurrencies().listen((currencies) {
  // تحديث واجهة المستخدم
});
```

## الدوال المتاحة في Supabase

### 1. **get_currency_by_iso(currency_iso)**
```sql
SELECT * FROM get_currency_by_iso('USD');
```

### 2. **convert_currency(from_iso, to_iso, amount)**
```sql
SELECT convert_currency('USD', 'EUR', 100.0);
```

### 3. **search_currencies(search_term)**
```sql
SELECT * FROM search_currencies('Dollar');
```

### 4. **get_currency_statistics()**
```sql
SELECT * FROM get_currency_statistics();
```

### 5. **update_exchange_rates(rate_updates)**
```sql
SELECT update_exchange_rates('[
  {"iso": "USD", "rate": 1.0},
  {"iso": "EUR", "rate": 0.85}
]'::jsonb);
```

## المميزات الجديدة

### 1. **أداء محسن**
- فهارس للاستعلامات السريعة
- تحويل محلي سريع
- تخزين مؤقت للعملات

### 2. **دقة أكبر**
- دعم للأرقام العشرية الدقيقة
- تحويل دقيق عبر الخادم
- تحديث فوري للأسعار

### 3. **مرونة أكثر**
- بحث متقدم
- تصفية متعددة المعايير
- دعم للصفحات

### 4. **أمان محسن**
- Row Level Security
- صلاحيات محددة
- حماية البيانات

## استكشاف الأخطاء

### المشاكل الشائعة

1. **خطأ في التحويل**: تأكد من وجود العملات في قاعدة البيانات
2. **بطء في التحميل**: تحقق من الفهارس
3. **أخطاء الصلاحيات**: تحقق من RLS policies

### نصائح الأداء

1. **استخدم الفهارس**: تأكد من وجود فهارس على الحقول المطلوبة
2. **تخزين مؤقت**: احفظ العملات محلياً عند الإمكان
3. **تحويل محلي**: استخدم التحويل المحلي للعمليات السريعة

## التحديثات المستقبلية

### 1. **تاريخ الأسعار**
- تتبع تغيرات الأسعار
- رسوم بيانية للاتجاهات
- تنبيهات التغيير

### 2. **عملات رقمية**
- دعم العملات المشفرة
- أسعار فورية
- محافظ رقمية

### 3. **تحليلات متقدمة**
- إحصائيات الاستخدام
- توقعات الأسعار
- تقارير مفصلة

النظام جاهز للاستخدام! 💱✨
