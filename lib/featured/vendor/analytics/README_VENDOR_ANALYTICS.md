# Vendor Analytics System - نظام تحليلات التجار

نظام شامل لتحليل أداء منتجات التجار في السلة والمنتجات المحفوظة.

## المميزات الرئيسية

### 📊 **تحليلات المنتجات المحفوظة**
- عدد مرات حفظ المنتج
- عدد المستخدمين الفريدين الذين حفظوا المنتج
- إجمالي الكمية المحفوظة
- إجمالي القيمة المحفوظة

### 🛒 **تحليلات السلة**
- عدد مرات إضافة المنتج للسلة
- عدد المستخدمين الفريدين الذين أضافوا للسلة
- إجمالي الكمية في السلة
- إجمالي القيمة في السلة

### 📈 **تحليلات متقدمة**
- نقاط التفاعل (Engagement Score)
- تحليل المنافسين
- المنتجات الرائجة
- الأنشطة الحديثة

## الملفات المطلوبة

### 1. **Database Schema** (`lib/utils/supabase_vendor_analytics_schema.sql`)
```sql
-- تشغيل هذا الملف في Supabase SQL Editor
-- يحتوي على:
-- - Views للتحليلات
-- - Functions للاستعلامات
-- - Indexes للأداء
```

### 2. **Repository** (`lib/featured/vendor/analytics/vendor_analytics_repository.dart`)
- إدارة جميع عمليات قاعدة البيانات
- استعلامات محسنة للأداء
- معالجة الأخطاء

### 3. **Controller** (`lib/featured/vendor/analytics/vendor_analytics_controller.dart`)
- إدارة الحالة
- تحميل البيانات
- واجهة سهلة للاستخدام

## كيفية الاستخدام

### 1. **إعداد قاعدة البيانات**
```sql
-- في Supabase SQL Editor
-- انسخ والصق محتوى supabase_vendor_analytics_schema.sql
-- وقم بتشغيله
```

### 2. **في التطبيق**
```dart
// تهيئة الـ Controller
final analyticsController = Get.put(VendorAnalyticsController());

// تعيين معرف التاجر
analyticsController.setVendorId('vendor-uuid');

// تحميل جميع التحليلات
await analyticsController.loadVendorAnalytics();
```

### 3. **الاستعلامات المتاحة**

#### تحميل البيانات الأساسية
```dart
// تحميل المنتجات المحفوظة
await analyticsController.loadSavedProducts();

// تحميل منتجات السلة
await analyticsController.loadCartProducts();

// تحميل ملخص التاجر
await analyticsController.loadVendorSummary();
```

#### تحميل التحليلات المتقدمة
```dart
// تحميل أفضل المنتجات أداءً
await analyticsController.loadTopPerformingProducts(limit: 10);

// تحميل المنتجات عالية الحفظ منخفضة السلة
await analyticsController.loadHighSaveLowCartProducts();

// تحميل الأنشطة الحديثة
await analyticsController.loadRecentActivity();
```

#### الوصول للبيانات
```dart
// البيانات الأساسية
final savedProducts = analyticsController.savedProducts;
final cartProducts = analyticsController.cartProducts;
final summary = analyticsController.vendorSummary.value;

// الإحصائيات المحسوبة
final totalRevenue = analyticsController.totalPotentialRevenue;
final avgEngagement = analyticsController.averageEngagementScore;
final uniqueUsers = analyticsController.totalUniqueSavers;
```

## Views المتاحة

### 1. **vendor_saved_products**
```sql
SELECT * FROM vendor_saved_products 
WHERE vendor_id = 'vendor-uuid'
ORDER BY times_saved DESC;
```

### 2. **vendor_cart_products**
```sql
SELECT * FROM vendor_cart_products 
WHERE vendor_id = 'vendor-uuid'
ORDER BY times_in_cart DESC;
```

### 3. **vendor_product_analytics**
```sql
SELECT * FROM vendor_product_analytics 
WHERE vendor_id = 'vendor-uuid'
ORDER BY engagement_score DESC;
```

### 4. **vendor_summary_analytics**
```sql
SELECT * FROM vendor_summary_analytics 
WHERE vendor_id = 'vendor-uuid';
```

## Functions المتاحة

### 1. **get_vendor_saved_products(vendor_uuid)**
```sql
SELECT * FROM get_vendor_saved_products('vendor-uuid');
```

### 2. **get_vendor_cart_products(vendor_uuid)**
```sql
SELECT * FROM get_vendor_cart_products('vendor-uuid');
```

### 3. **get_vendor_analytics(vendor_uuid)**
```sql
SELECT * FROM get_vendor_analytics('vendor-uuid');
```

### 4. **get_vendor_recent_activity(vendor_uuid)**
```sql
SELECT * FROM get_vendor_recent_activity('vendor-uuid');
```

## أمثلة عملية

### 1. **عرض لوحة تحكم التاجر**
```dart
class VendorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();
    
    return Obx(() => Column(
      children: [
        // ملخص الأداء
        SummaryCard(
          totalProducts: analytics.vendorSummary.value?['total_products'] ?? 0,
          totalSaves: analytics.vendorSummary.value?['total_saves'] ?? 0,
          totalRevenue: analytics.totalPotentialRevenue,
        ),
        
        // أفضل المنتجات
        TopProductsList(
          products: analytics.topPerformingProducts,
        ),
        
        // المنتجات التي تحتاج انتباه
        ProductsNeedingAttention(
          products: analytics.productsNeedingAttention,
        ),
      ],
    ));
  }
}
```

### 2. **إشعارات التاجر**
```dart
class VendorNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();
    
    return Obx(() => ListView.builder(
      itemCount: analytics.recentActivity.length,
      itemBuilder: (context, index) {
        final activity = analytics.recentActivity[index];
        return ActivityCard(
          type: activity['activity_type'],
          productTitle: activity['product_title'],
          userCount: activity['user_count'],
          timestamp: activity['activity_time'],
        );
      },
    ));
  }
}
```

### 3. **تحليل منتج معين**
```dart
class ProductAnalyticsPage extends StatelessWidget {
  final String productId;
  
  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();
    
    return FutureBuilder<Map<String, dynamic>?>(
      future: analytics.getProductAnalytics(productId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return ProductAnalyticsCard(
            timesSaved: data['times_saved'] ?? 0,
            timesInCart: data['times_in_cart'] ?? 0,
            engagementScore: data['engagement_score'] ?? 0.0,
            totalValue: data['total_potential_value'] ?? 0.0,
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## مؤشرات الأداء الرئيسية (KPIs)

### 1. **نقاط التفاعل (Engagement Score)**
```
Engagement Score = (مرات الحفظ × 1.0) + (مرات السلة × 2.0)
```

### 2. **معدل التحويل**
```
Conversion Rate = (مرات السلة / مرات الحفظ) × 100
```

### 3. **القيمة المحتملة**
```
Potential Value = إجمالي قيمة المحفوظات + إجمالي قيمة السلة
```

## التحديثات المستقبلية

### 1. **إشعارات فورية**
- تنبيهات عند حفظ منتج جديد
- إشعارات عند إضافة منتج للسلة

### 2. **تحليلات متقدمة**
- تحليل الاتجاهات
- توقعات المبيعات
- تحليل المنافسين

### 3. **تقارير مخصصة**
- تقارير PDF
- تصدير البيانات
- جداول زمنية

### 4. **تحليلات المستخدمين**
- سلوك المستخدمين
- أنماط الشراء
- توصيات المنتجات

## استكشاف الأخطاء

### المشاكل الشائعة

1. **بطء في التحميل**: تحقق من الفهارس
2. **بيانات فارغة**: تأكد من وجود بيانات في الجداول
3. **أخطاء الصلاحيات**: تحقق من RLS policies

### نصائح الأداء

1. **استخدم الفهارس**: تأكد من وجود فهارس على الحقول المطلوبة
2. **حدد النتائج**: استخدم LIMIT للاستعلامات الكبيرة
3. **تخزين مؤقت**: احفظ النتائج محلياً عند الإمكان

## الأمان

- **Row Level Security**: مفعل على جميع الجداول
- **صلاحيات محدودة**: التجار يرون فقط منتجاتهم
- **حماية البيانات**: تشفير البيانات الحساسة

النظام جاهز للاستخدام! 📊✨
