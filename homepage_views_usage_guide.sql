-- =====================================================
-- دليل استخدام Views الصفحة الرئيسية في Flutter
-- Guide for Using Homepage Views in Flutter
-- =====================================================

-- =====================================================
-- 1. أمثلة استعلامات للصفحة الرئيسية
-- Homepage Query Examples
-- =====================================================

-- استعلام للحصول على بيانات الصفحة الرئيسية كاملة
WITH homepage_data AS (
    SELECT 
        -- أحدث المنتجات
        (SELECT COUNT(*) FROM homepage_latest_products) as latest_products_count,
        -- أحدث التجار
        (SELECT COUNT(*) FROM homepage_latest_vendors) as latest_vendors_count,
        -- المنتجات المميزة
        (SELECT COUNT(*) FROM homepage_featured_products) as featured_products_count,
        -- التجار المميزين
        (SELECT COUNT(*) FROM homepage_featured_vendors) as featured_vendors_count
)
SELECT * FROM homepage_data;

-- =====================================================
-- 2. استعلامات محسنة للأداء
-- Performance Optimized Queries
-- =====================================================

-- استعلام سريع للحصول على أحدث المنتجات مع الحد الأدنى من البيانات
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status
FROM homepage_latest_products
LIMIT 20;

-- استعلام سريع للحصول على أحدث التجار مع الحد الأدنى من البيانات
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    avg_product_price
FROM homepage_latest_vendors
LIMIT 10;

-- =====================================================
-- 3. استعلامات للعرض في أقسام مختلفة
-- Queries for Different Display Sections
-- =====================================================

-- قسم "أحدث المنتجات"
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status,
    product_age_status
FROM homepage_latest_products
WHERE product_age_status IN ('new', 'recent')
ORDER BY created_at DESC
LIMIT 15;

-- قسم "التجار الجدد"
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    vendor_age_status
FROM homepage_latest_vendors
WHERE vendor_age_status IN ('new', 'recent')
ORDER BY created_at DESC
LIMIT 8;

-- قسم "المنتجات المميزة"
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    display_priority
FROM homepage_featured_products
ORDER BY display_priority DESC, created_at DESC
LIMIT 12;

-- قسم "التجار المميزين"
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    avg_product_price,
    display_priority
FROM homepage_featured_vendors
ORDER BY display_priority DESC, total_products DESC
LIMIT 6;

-- =====================================================
-- 4. استعلامات للبحث والتصفية
-- Search and Filter Queries
-- =====================================================

-- البحث عن منتجات في فئة معينة
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status
FROM homepage_latest_products
WHERE vendor_category_title ILIKE '%إلكترونيات%'
ORDER BY display_priority DESC, created_at DESC
LIMIT 20;

-- البحث عن منتجات بسعر معين
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status
FROM homepage_latest_products
WHERE price BETWEEN 50 AND 200
ORDER BY price ASC, display_priority DESC
LIMIT 20;

-- البحث عن منتجات متوفرة فقط
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status
FROM homepage_latest_products
WHERE stock_status = 'in_stock'
ORDER BY display_priority DESC, created_at DESC
LIMIT 20;

-- =====================================================
-- 5. استعلامات للإحصائيات والعرض
-- Statistics and Display Queries
-- =====================================================

-- إحصائيات سريعة للعرض
SELECT 
    'المنتجات' as category,
    total_products as total,
    active_products as active,
    new_products_week as new_this_week,
    new_products_month as new_this_month
FROM homepage_statistics
UNION ALL
SELECT 
    'التجار' as category,
    total_vendors as total,
    active_vendors as active,
    new_vendors_week as new_this_week,
    new_vendors_month as new_this_month
FROM homepage_statistics;

-- إحصائيات الفئات
SELECT 
    vendor_category_title,
    vendor_category_color,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count
FROM homepage_latest_products
GROUP BY vendor_category_title, vendor_category_color
ORDER BY product_count DESC
LIMIT 10;

-- =====================================================
-- 6. استعلامات للعرض في الشبكة
-- Grid Display Queries
-- =====================================================

-- عرض المنتجات في شبكة 2x2
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status,
    ROW_NUMBER() OVER (ORDER BY display_priority DESC, created_at DESC) as row_num
FROM homepage_latest_products
LIMIT 20;

-- عرض التجار في شبكة 2x2
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    avg_product_price,
    ROW_NUMBER() OVER (ORDER BY display_priority DESC, total_products DESC) as row_num
FROM homepage_latest_vendors
LIMIT 12;

-- =====================================================
-- 7. استعلامات للعرض في القوائم
-- List Display Queries
-- =====================================================

-- عرض المنتجات في قائمة عمودية
SELECT 
    product_id,
    product_name,
    product_description,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status,
    product_age_status
FROM homepage_latest_products
ORDER BY display_priority DESC, created_at DESC
LIMIT 50;

-- عرض التجار في قائمة عمودية
SELECT 
    vendor_id,
    vendor_name,
    vendor_bio,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    active_products,
    avg_product_price,
    vendor_age_status
FROM homepage_latest_vendors
ORDER BY display_priority DESC, total_products DESC
LIMIT 30;

-- =====================================================
-- 8. استعلامات للعرض في الكروسل
-- Carousel Display Queries
-- =====================================================

-- عرض المنتجات في كروسل
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status,
    display_priority
FROM homepage_featured_products
ORDER BY display_priority DESC, created_at DESC
LIMIT 10;

-- عرض التجار في كروسل
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    avg_product_price,
    display_priority
FROM homepage_featured_vendors
ORDER BY display_priority DESC, total_products DESC
LIMIT 8;

-- =====================================================
-- 9. استعلامات للعرض في التابز
-- Tab Display Queries
-- =====================================================

-- عرض المنتجات حسب الفئة في تابز
SELECT 
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM homepage_latest_products
GROUP BY vendor_category_title, vendor_category_color, vendor_category_icon
ORDER BY product_count DESC;

-- عرض المنتجات في كل تاب
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    stock_status
FROM homepage_latest_products
WHERE vendor_category_title = 'إلكترونيات'
ORDER BY display_priority DESC, created_at DESC
LIMIT 20;

-- =====================================================
-- 10. استعلامات للعرض في البانر
-- Banner Display Queries
-- =====================================================

-- عرض المنتجات المميزة في البانر
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    stock_status
FROM homepage_featured_products
WHERE display_priority >= 90
ORDER BY display_priority DESC, created_at DESC
LIMIT 5;

-- عرض التجار المميزين في البانر
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    avg_product_price
FROM homepage_featured_vendors
WHERE display_priority >= 90
ORDER BY display_priority DESC, total_products DESC
LIMIT 3;

-- =====================================================
-- 11. استعلامات للعرض في الفوتر
-- Footer Display Queries
-- =====================================================

-- عرض إحصائيات في الفوتر
SELECT 
    'إجمالي المنتجات' as stat_name,
    total_products::TEXT as stat_value
FROM homepage_statistics
UNION ALL
SELECT 
    'إجمالي التجار' as stat_name,
    total_vendors::TEXT as stat_value
FROM homepage_statistics
UNION ALL
SELECT 
    'المنتجات الجديدة هذا الأسبوع' as stat_name,
    new_products_week::TEXT as stat_value
FROM homepage_statistics
UNION ALL
SELECT 
    'التجار الجدد هذا الأسبوع' as stat_name,
    new_vendors_week::TEXT as stat_value
FROM homepage_statistics;

-- =====================================================
-- 12. استعلامات للعرض في البحث السريع
-- Quick Search Display Queries
-- =====================================================

-- البحث السريع في المنتجات
SELECT 
    product_id,
    product_name,
    price,
    currency,
    product_image,
    vendor_name,
    vendor_category_title,
    vendor_category_color
FROM homepage_latest_products
WHERE product_name ILIKE '%هاتف%'
ORDER BY display_priority DESC, created_at DESC
LIMIT 10;

-- البحث السريع في التجار
SELECT 
    vendor_id,
    vendor_name,
    vendor_image,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products
FROM homepage_latest_vendors
WHERE vendor_name ILIKE '%محمد%'
ORDER BY display_priority DESC, total_products DESC
LIMIT 10;

-- =====================================================
-- انتهاء دليل استخدام Views الصفحة الرئيسية
-- End of Homepage Views Usage Guide
-- =====================================================
