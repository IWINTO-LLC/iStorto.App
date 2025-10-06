# نظام البحث الشامل والمخصص - Comprehensive Search System

## 📋 نظرة عامة
تم إنشاء نظام بحث شامل ومتقدم يدعم البحث في المنتجات والتجار وفئات التجار مع إمكانيات فلترة متقدمة وحفظ تاريخ البحث.

## 🏗️ الهيكل المعماري

### 1. نماذج البيانات (Models)
- **`SearchResultModel`**: نموذج بيانات نتيجة البحث الشامل
- **`SearchFilterModel`**: نموذج بيانات فلاتر البحث المخصص
- **`SearchStatisticsModel`**: نموذج بيانات إحصائيات البحث

### 2. مستودع البيانات (Repository)
- **`SearchRepository`**: يتعامل مع Supabase ويوفر دوال البحث المختلفة

### 3. متحكم البيانات (Controller)
- **`SearchController`**: يدير حالة البحث والفلترة وتاريخ البحث

### 4. واجهات المستخدم (Views)
- **`CustomSearchPage`**: صفحة البحث المخصص مع الفلترة المتقدمة
- **`HomeSearchBar`**: شريط البحث في الصفحة الرئيسية
- **`HomeSearchResults`**: عرض نتائج البحث في الصفحة الرئيسية
- **`HomeSearchHistory`**: عرض تاريخ البحث في الصفحة الرئيسية

### 5. مكونات واجهة المستخدم (Widgets)
- **`SearchResultCard`**: بطاقة عرض نتيجة البحث
- **`SearchFilterSheet`**: ورقة الفلترة المتقدمة
- **`SearchHistoryWidget`**: ويدجت تاريخ البحث

## 🔍 أنواع البحث المدعومة

### 1. البحث الشامل (Comprehensive Search)
```dart
// البحث الشامل مع Full Text Search
await searchController.performComprehensiveSearch(
  searchQuery: 'هاتف',
  categoryFilter: 'إلكترونيات',
  vendorFilter: 'Sara Fitness',
  availabilityFilter: 'available',
  featureFilter: 'featured',
  verifiedFilter: true,
  priceMin: 100,
  priceMax: 500,
);
```

### 2. البحث السريع (Quick Search)
```dart
// البحث السريع بدون Full Text Search
await searchController.performQuickSearch(
  searchQuery: 'fitness',
  limitCount: 20,
);
```

### 3. البحث المخصص (Custom Search)
```dart
// البحث المخصص مع فلاتر متعددة
await searchController.performCustomSearch(
  searchQuery: 'hotel',
  filters: SearchFilterModel(
    categoryFilter: 'فندق',
    verifiedFilter: true,
    priceMin: 100,
    priceMax: 1000,
  ),
);
```

### 4. البحث المتخصص
```dart
// البحث في المنتجات فقط
await searchController.searchProductsOnly(searchQuery: 'منتج');

// البحث في التجار فقط
await searchController.searchVendorsOnly(searchQuery: 'تاجر');

// البحث في الفئات فقط
await searchController.searchCategoriesOnly(searchQuery: 'فئة');
```

## 🎯 الفلاتر المتاحة

### فلتر الفئة
- البحث في فئة التاجر المحددة
- دعم البحث النصي والفلترة السريعة

### فلتر التاجر
- البحث في اسم التاجر
- دعم التجار المعتمدين وغير المعتمدين

### فلتر التوفر
- `available`: المنتجات المتوفرة فقط
- `unavailable`: المنتجات غير المتوفرة فقط
- `null`: جميع المنتجات

### فلتر المميز
- `featured`: المنتجات المميزة فقط
- `normal`: المنتجات العادية فقط
- `null`: جميع المنتجات

### فلتر التحقق
- `true`: التجار المعتمدين فقط
- `false`: التجار غير المعتمدين فقط
- `null`: جميع التجار

### فلتر السعر
- تحديد الحد الأدنى والأعلى للسعر
- دعم النطاقات السريعة المحددة مسبقاً

## 💾 إدارة تاريخ البحث

### حفظ البحث
```dart
// يتم حفظ البحث تلقائياً عند تنفيذ البحث
// يمكن تعطيل الحفظ باستخدام addToHistory: false
await searchController.performComprehensiveSearch(
  searchQuery: 'منتج',
  addToHistory: false, // تعطيل الحفظ
);
```

### إدارة التاريخ
```dart
// مسح تاريخ البحث
searchController.clearSearchHistory();

// حذف بحث محدد
searchController.removeFromSearchHistory('منتج');

// عرض تاريخ البحث
final history = searchController.searchHistory;
```

## 📊 إحصائيات البحث

### الحصول على الإحصائيات
```dart
// تحميل الإحصائيات
await searchController.refreshSearchStatistics();

// عرض الإحصائيات
final stats = searchController.searchStatistics.value;
print('إجمالي المنتجات: ${stats?.totalProducts}');
print('إجمالي التجار: ${stats?.totalVendors}');
print('التجار المعتمدين: ${stats?.verifiedVendors}');
```

## 🚀 الاستخدام في التطبيق

### 1. تهيئة النظام
```dart
// في main.dart
Get.put(SearchController());

// في الصفحة الرئيسية
HomeSearchBar(
  searchController: TextEditingController(),
  onSearchSubmitted: (query) {
    // منطق إضافي عند البحث
  },
)
```

### 2. التنقل للبحث المخصص
```dart
// من أي مكان في التطبيق
Get.to(() => const CustomSearchPage());

// أو باستخدام المسار
Get.toNamed('/custom-search');
```

### 3. عرض النتائج
```dart
// في الصفحة الرئيسية
const HomeSearchResults()

// في صفحة مخصصة
Obx(() => ListView.builder(
  itemCount: searchController.searchResults.length,
  itemBuilder: (context, index) {
    final result = searchController.searchResults[index];
    return SearchResultCard(
      result: result,
      onTap: () => _navigateToProductDetails(result),
    );
  },
))
```

## 🔧 التكوين المتقدم

### تحديث قاعدة البيانات
```dart
// تحديث Materialized View يدوياً
await searchController.refreshMaterializedView();

// تفعيل التحديث التلقائي
searchController.toggleAutoRefresh();
```

### إدارة الفلاتر
```dart
// تحديث فلتر محدد
searchController.setCategoryFilter('فندق');
searchController.setVerifiedFilter(true);
searchController.setPriceRange(100, 500);

// مسح جميع الفلاتر
searchController.clearSearchFilters();
```

## 📱 واجهة المستخدم

### الصفحة الرئيسية
- شريط بحث شامل مع أزرار البحث السريع والشامل
- عرض تاريخ البحث السابق
- عرض نتائج البحث المحدودة
- زر الفلترة للانتقال للبحث المخصص

### صفحة البحث المخصص
- شريط بحث متقدم
- عرض الفلاتر النشطة
- ورقة فلترة شاملة
- عرض النتائج مع إمكانية التحميل الإضافي
- إدارة تاريخ البحث

### بطاقة نتيجة البحث
- صورة المنتج
- معلومات المنتج والتاجر
- أيقونات الحالة (مميز، معتمد، متوفر)
- السعر والخصم
- نقاط البحث والصلة

## 🎨 التخصيص

### الألوان والثيم
```dart
// يمكن تخصيص الألوان في Theme
primaryColor: Colors.blue,
accentColor: Colors.orange,
```

### النصوص والترجمة
```dart
// دعم الترجمة متعدد اللغات
'hintText': 'search_hint'.tr,
'searchButton': 'search'.tr,
```

## 🔍 استكشاف الأخطاء

### مشاكل شائعة
1. **لا تظهر النتائج**: تأكد من تشغيل سكريبت قاعدة البيانات
2. **خطأ في البحث**: تحقق من اتصال Supabase
3. **تاريخ البحث لا يحفظ**: تأكد من تهيئة GetStorage

### سجلات التصحيح
```dart
// تفعيل سجلات التصحيح
if (kDebugMode) {
  print('نتائج البحث: ${searchController.searchResults.length}');
  print('حالة التحميل: ${searchController.isLoading.value}');
}
```

## 📈 الأداء

### تحسينات الأداء
- استخدام Materialized View للبحث السريع
- فهارس قاعدة البيانات المحسنة
- التحميل التدريجي للنتائج
- التخزين المؤقت للتاريخ

### مراقبة الأداء
```dart
// مراقبة وقت البحث
final stopwatch = Stopwatch()..start();
await searchController.performComprehensiveSearch(searchQuery: 'test');
stopwatch.stop();
print('وقت البحث: ${stopwatch.elapsedMilliseconds}ms');
```

## 🔄 التحديثات المستقبلية

### ميزات مخططة
- البحث الصوتي
- البحث بالصورة
- اقتراحات البحث الذكية
- تحليلات البحث المتقدمة
- البحث الجغرافي

### تحسينات الأداء
- البحث المحلي
- التخزين المؤقت المتقدم
- ضغط البيانات
- البحث المتوازي

---

## 📞 الدعم

لأي استفسارات أو مشاكل، يرجى مراجعة:
- ملفات السجلات للتشخيص
- قاعدة البيانات للتأكد من صحة البيانات
- إعدادات Supabase للصلاحيات

**تم تطوير هذا النظام وفقاً لأفضل الممارسات في Flutter وGetX مع دعم كامل للغة العربية.**
