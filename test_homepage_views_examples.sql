-- =====================================================
-- أمثلة اختبار Views الصفحة الرئيسية
-- Homepage Views Test Examples
-- =====================================================

-- =====================================================
-- 1. اختبار أحدث المنتجات
-- Test Latest Products
-- =====================================================

-- الحصول على أحدث 20 منتج
SELECT * FROM get_latest_products(20, 0);

-- الحصول على أحدث 10 منتجات مع تفاصيل أكثر
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    price,
    stock_status,
    product_age_status,
    display_priority
FROM homepage_latest_products
LIMIT 10;

-- =====================================================
-- 2. اختبار أحدث التجار
-- Test Latest Vendors
-- =====================================================

-- الحصول على أحدث 10 تجار
SELECT * FROM get_latest_vendors(10, 0);

-- الحصول على أحدث التجار مع إحصائياتهم
SELECT 
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    total_products,
    active_products,
    available_products,
    avg_product_price,
    vendor_age_status,
    display_priority
FROM homepage_latest_vendors
LIMIT 10;

-- =====================================================
-- 3. اختبار المنتجات المميزة
-- Test Featured Products
-- =====================================================

-- الحصول على المنتجات المميزة
SELECT * FROM get_featured_products(15, 0);

-- الحصول على المنتجات المميزة مع تفاصيل أكثر
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    price,
    stock_status,
    display_priority
FROM homepage_featured_products
LIMIT 15;

-- =====================================================
-- 4. اختبار التجار المميزين
-- Test Featured Vendors
-- =====================================================

-- الحصول على التجار المميزين
SELECT * FROM get_featured_vendors(8, 0);

-- الحصول على التجار المميزين مع إحصائياتهم
SELECT 
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    active_products,
    available_products,
    avg_product_price,
    display_priority
FROM homepage_featured_vendors
LIMIT 8;

-- =====================================================
-- 5. اختبار إحصائيات الصفحة الرئيسية
-- Test Homepage Statistics
-- =====================================================

-- الحصول على إحصائيات الصفحة الرئيسية
SELECT * FROM get_homepage_statistics();

-- عرض الإحصائيات بشكل منظم
SELECT 
    'المنتجات' as category,
    total_products as total,
    active_products as active,
    available_products as available,
    new_products_week as new_week,
    new_products_month as new_month
FROM homepage_statistics
UNION ALL
SELECT 
    'التجار' as category,
    total_vendors as total,
    active_vendors as active,
    NULL as available,
    new_vendors_week as new_week,
    new_vendors_month as new_month
FROM homepage_statistics;

-- =====================================================
-- 6. اختبار البحث في المنتجات الجديدة
-- Test Search in New Products
-- =====================================================

-- البحث عن منتجات جديدة في الأسبوع الماضي
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    product_age_status,
    created_at
FROM homepage_latest_products
WHERE product_age_status = 'new'
ORDER BY created_at DESC;

-- البحث عن منتجات جديدة في الشهر الماضي
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    product_age_status,
    created_at
FROM homepage_latest_products
WHERE product_age_status IN ('new', 'recent')
ORDER BY created_at DESC;

-- =====================================================
-- 7. اختبار البحث في التجار الجدد
-- Test Search in New Vendors
-- =====================================================

-- البحث عن تجار جدد في الأسبوع الماضي
SELECT 
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    total_products,
    vendor_age_status,
    created_at
FROM homepage_latest_vendors
WHERE vendor_age_status = 'new'
ORDER BY created_at DESC;

-- البحث عن تجار جدد في الشهر الماضي
SELECT 
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    total_products,
    vendor_age_status,
    created_at
FROM homepage_latest_vendors
WHERE vendor_age_status IN ('new', 'recent')
ORDER BY created_at DESC;

-- =====================================================
-- 8. اختبار البحث حسب الفئة
-- Test Search by Category
-- =====================================================

-- البحث عن منتجات في فئة معينة
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    price,
    stock_status
FROM homepage_latest_products
WHERE vendor_category_title ILIKE '%إلكترونيات%'
ORDER BY display_priority DESC, created_at DESC;

-- البحث عن تجار في فئة معينة
SELECT 
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    avg_product_price
FROM homepage_latest_vendors
WHERE vendor_category_title ILIKE '%إلكترونيات%'
ORDER BY display_priority DESC, total_products DESC;

-- =====================================================
-- 9. اختبار البحث حسب الأولوية
-- Test Search by Priority
-- =====================================================

-- البحث عن منتجات عالية الأولوية
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    price,
    display_priority
FROM homepage_latest_products
WHERE display_priority >= 80
ORDER BY display_priority DESC, created_at DESC;

-- البحث عن تجار عاليي الأولوية
SELECT 
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    total_products,
    display_priority
FROM homepage_latest_vendors
WHERE display_priority >= 80
ORDER BY display_priority DESC, total_products DESC;

-- =====================================================
-- 10. اختبار البحث حسب حالة المخزون
-- Test Search by Stock Status
-- =====================================================

-- البحث عن منتجات متوفرة
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    stock_quantity,
    stock_status
FROM homepage_latest_products
WHERE stock_status = 'in_stock'
ORDER BY display_priority DESC, created_at DESC;

-- البحث عن منتجات قليلة التوفر
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    stock_quantity,
    stock_status
FROM homepage_latest_products
WHERE stock_status = 'low_stock'
ORDER BY display_priority DESC, created_at DESC;

-- =====================================================
-- 11. اختبار البحث حسب السعر
-- Test Search by Price
-- =====================================================

-- البحث عن منتجات بسعر معين
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    currency,
    stock_status
FROM homepage_latest_products
WHERE price BETWEEN 100 AND 500
ORDER BY price ASC, display_priority DESC;

-- البحث عن منتجات بأسعار منخفضة
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    currency,
    stock_status
FROM homepage_latest_products
WHERE price <= 100
ORDER BY price ASC, display_priority DESC;

-- =====================================================
-- 12. اختبار البحث مع التجميع
-- Test Search with Grouping
-- =====================================================

-- تجميع المنتجات حسب الفئة
SELECT 
    vendor_category_title,
    vendor_category_color,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price,
    COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count
FROM homepage_latest_products
GROUP BY vendor_category_title, vendor_category_color
ORDER BY product_count DESC;

-- تجميع التجار حسب الفئة
SELECT 
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    COUNT(*) as vendor_count,
    SUM(total_products) as total_products,
    AVG(avg_product_price) as avg_price
FROM homepage_latest_vendors
GROUP BY vendor_category_title, vendor_category_color, vendor_category_icon
ORDER BY vendor_count DESC;

-- =====================================================
-- 13. اختبار البحث مع التصفح
-- Test Search with Pagination
-- =====================================================

-- الصفحة الأولى من أحدث المنتجات
SELECT * FROM get_latest_products(10, 0);

-- الصفحة الثانية من أحدث المنتجات
SELECT * FROM get_latest_products(10, 10);

-- الصفحة الثالثة من أحدث المنتجات
SELECT * FROM get_latest_products(10, 20);

-- =====================================================
-- 14. اختبار البحث مع الترتيب المتقدم
-- Test Search with Advanced Sorting
-- =====================================================

-- ترتيب المنتجات حسب الأولوية والسعر
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    display_priority,
    created_at
FROM homepage_latest_products
ORDER BY display_priority DESC, price ASC, created_at DESC;

-- ترتيب التجار حسب الأولوية وعدد المنتجات
SELECT 
    vendor_name,
    vendor_category_title,
    total_products,
    display_priority,
    created_at
FROM homepage_latest_vendors
ORDER BY display_priority DESC, total_products DESC, created_at DESC;

-- =====================================================
-- 15. اختبار البحث مع التحليل المتقدم
-- Test Search with Advanced Analytics
-- =====================================================

-- تحليل شامل للمنتجات الجديدة
WITH new_products_analysis AS (
    SELECT 
        vendor_category_title,
        vendor_category_color,
        COUNT(*) as new_product_count,
        AVG(price) as avg_price,
        COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count
    FROM homepage_latest_products
    WHERE product_age_status = 'new'
    GROUP BY vendor_category_title, vendor_category_color
)
SELECT 
    vendor_category_title,
    vendor_category_color,
    new_product_count,
    avg_price,
    in_stock_count,
    ROUND((in_stock_count::DECIMAL / new_product_count) * 100, 2) as availability_percentage
FROM new_products_analysis
ORDER BY new_product_count DESC;

-- تحليل شامل للتجار الجدد
WITH new_vendors_analysis AS (
    SELECT 
        vendor_category_title,
        vendor_category_color,
        COUNT(*) as new_vendor_count,
        AVG(total_products) as avg_products_per_vendor,
        AVG(avg_product_price) as avg_price
    FROM homepage_latest_vendors
    WHERE vendor_age_status = 'new'
    GROUP BY vendor_category_title, vendor_category_color
)
SELECT 
    vendor_category_title,
    vendor_category_color,
    new_vendor_count,
    avg_products_per_vendor,
    avg_price
FROM new_vendors_analysis
ORDER BY new_vendor_count DESC;

-- =====================================================
-- انتهاء أمثلة اختبار Views الصفحة الرئيسية
-- End of Homepage Views Test Examples
-- =====================================================
