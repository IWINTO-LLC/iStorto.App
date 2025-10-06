-- =====================================================
-- أمثلة عملية لاختبار البحث الشامل (محدث)
-- Practical Examples for Testing Comprehensive Search (Updated)
-- =====================================================

-- =====================================================
-- 1. اختبار البحث الأساسي
-- Basic Search Test
-- =====================================================

-- البحث عن منتجات تحتوي على كلمة "هاتف"
SELECT * FROM search_comprehensive('هاتف', NULL, NULL, NULL, 10, 0);

-- البحث عن منتجات تحتوي على كلمة "laptop"
SELECT * FROM search_comprehensive('laptop', NULL, NULL, NULL, 10, 0);

-- البحث عن منتجات في فئة معينة
SELECT * FROM search_comprehensive('إلكترونيات', 'إلكترونيات', NULL, NULL, 10, 0);

-- =====================================================
-- 2. اختبار البحث المتقدم
-- Advanced Search Test
-- =====================================================

-- البحث عن منتجات تاجر معين
SELECT * FROM search_comprehensive('هاتف', NULL, 'محمد', NULL, 10, 0);

-- البحث عن منتجات متوفرة فقط
SELECT * FROM search_comprehensive('هاتف', NULL, NULL, 'in_stock', 10, 0);

-- البحث عن منتجات في فئة معينة ومتوفرة
SELECT * FROM search_comprehensive('هاتف', 'إلكترونيات', NULL, 'in_stock', 10, 0);

-- =====================================================
-- 3. اختبار البحث السريع
-- Quick Search Test
-- =====================================================

-- البحث السريع عن منتجات
SELECT * FROM quick_search_comprehensive('هاتف', 5);

-- البحث السريع عن منتجات تاجر
SELECT * FROM quick_search_comprehensive('محمد', 5);

-- البحث السريع عن فئة
SELECT * FROM quick_search_comprehensive('إلكترونيات', 5);

-- =====================================================
-- 4. اختبار إحصائيات البحث
-- Search Statistics Test
-- =====================================================

-- الحصول على إحصائيات عامة
SELECT * FROM get_search_statistics();

-- =====================================================
-- 5. اختبار البحث مع ترتيب النتائج
-- Search with Result Ordering Test
-- =====================================================

-- البحث مع ترتيب حسب الصلة والأولوية
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    stock_status,
    search_score,
    relevance_score
FROM search_comprehensive('هاتف', NULL, NULL, NULL, 20, 0)
ORDER BY relevance_score DESC, search_score DESC;

-- =====================================================
-- 6. اختبار البحث في فئات التخصص (محدث)
-- Search in Specialization Categories Test (Updated)
-- =====================================================

-- البحث عن منتجات في فئات عالية الأولوية (sort_order <= 2)
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_sort_order,
    vendor_category_color,
    vendor_category_icon
FROM comprehensive_search_materialized
WHERE vendor_category_sort_order <= 2
AND search_text ILIKE '%هاتف%'
ORDER BY vendor_category_sort_order ASC, search_score DESC;

-- =====================================================
-- 7. اختبار البحث حسب ترتيب الفئة
-- Search by Category Sort Order Test
-- =====================================================

-- البحث عن منتجات من فئات مرتبة حسب الأولوية
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_sort_order,
    search_score
FROM comprehensive_search_materialized
WHERE vendor_category_sort_order <= 5
AND search_text ILIKE '%إلكترونيات%'
ORDER BY vendor_category_sort_order ASC, search_score DESC;

-- =====================================================
-- 8. اختبار البحث حسب حالة التوفر
-- Search by Stock Status Test
-- =====================================================

-- البحث عن منتجات متوفرة
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    stock_quantity,
    stock_status
FROM comprehensive_search_materialized
WHERE stock_status = 'in_stock'
AND search_text ILIKE '%هاتف%'
ORDER BY stock_quantity DESC;

-- البحث عن منتجات قليلة التوفر
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    stock_quantity,
    stock_status
FROM comprehensive_search_materialized
WHERE stock_status = 'low_stock'
AND search_text ILIKE '%هاتف%'
ORDER BY stock_quantity ASC;

-- =====================================================
-- 9. اختبار البحث مع التجميع
-- Search with Grouping Test
-- =====================================================

-- تجميع النتائج حسب التاجر
SELECT 
    vendor_name,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    MAX(vendor_category_sort_order) as max_sort_order
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%هاتف%'
GROUP BY vendor_name
ORDER BY product_count DESC;

-- تجميع النتائج حسب فئة التاجر
SELECT 
    vendor_category_title,
    vendor_category_color,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    COUNT(DISTINCT vendor_id) as vendor_count
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
GROUP BY vendor_category_title, vendor_category_color
ORDER BY product_count DESC;

-- =====================================================
-- 10. اختبار البحث مع التصفية المتقدمة
-- Advanced Filtering Search Test
-- =====================================================

-- البحث مع تصفية متعددة
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    price,
    stock_status,
    vendor_category_sort_order
FROM comprehensive_search_materialized
WHERE 
    search_text ILIKE '%هاتف%'
    AND stock_status = 'in_stock'
    AND vendor_category_sort_order <= 3
ORDER BY vendor_category_sort_order ASC, search_score DESC;

-- =====================================================
-- 11. اختبار البحث مع التصفح (Pagination)
-- Search with Pagination Test
-- =====================================================

-- الصفحة الأولى
SELECT * FROM search_comprehensive('هاتف', NULL, NULL, NULL, 10, 0);

-- الصفحة الثانية
SELECT * FROM search_comprehensive('هاتف', NULL, NULL, NULL, 10, 10);

-- الصفحة الثالثة
SELECT * FROM search_comprehensive('هاتف', NULL, NULL, NULL, 10, 20);

-- =====================================================
-- 12. اختبار البحث مع الترتيب المتقدم
-- Advanced Sorting Search Test
-- =====================================================

-- ترتيب حسب السعر (من الأقل للأعلى)
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    stock_status
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%هاتف%'
ORDER BY price ASC, search_score DESC;

-- ترتيب حسب السعر (من الأعلى للأقل)
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    price,
    stock_status
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%هاتف%'
ORDER BY price DESC, search_score DESC;

-- ترتيب حسب ترتيب الفئة والسعر
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_sort_order,
    price,
    search_score
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
ORDER BY vendor_category_sort_order ASC, price ASC, search_score DESC;

-- =====================================================
-- 13. اختبار البحث مع الإحصائيات التفصيلية
-- Detailed Statistics Search Test
-- =====================================================

-- إحصائيات البحث حسب فئة التاجر
SELECT 
    vendor_category_title,
    vendor_category_color,
    COUNT(*) as total_products,
    COUNT(DISTINCT vendor_id) as total_vendors,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price,
    COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count,
    AVG(vendor_category_sort_order) as avg_sort_order
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
GROUP BY vendor_category_title, vendor_category_color
ORDER BY total_products DESC;

-- =====================================================
-- 14. اختبار البحث مع النتائج المميزة
-- Featured Results Search Test
-- =====================================================

-- البحث عن المنتجات المميزة (فئات عالية الأولوية)
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    vendor_category_sort_order,
    search_score,
    price
FROM comprehensive_search_materialized
WHERE 
    search_text ILIKE '%هاتف%'
    AND vendor_category_sort_order <= 2
ORDER BY vendor_category_sort_order ASC, search_score DESC;

-- =====================================================
-- 15. اختبار البحث مع التحليل المتقدم
-- Advanced Analytics Search Test
-- =====================================================

-- تحليل شامل للبحث
WITH search_analysis AS (
    SELECT 
        vendor_category_title,
        vendor_name,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        AVG(vendor_category_sort_order) as avg_sort_order,
        COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count
    FROM comprehensive_search_materialized
    WHERE search_text ILIKE '%هاتف%'
    GROUP BY vendor_category_title, vendor_name
)
SELECT 
    vendor_category_title,
    COUNT(DISTINCT vendor_name) as vendor_count,
    SUM(product_count) as total_products,
    AVG(avg_price) as category_avg_price,
    AVG(avg_sort_order) as category_avg_sort_order,
    SUM(in_stock_count) as total_in_stock
FROM search_analysis
GROUP BY vendor_category_title
ORDER BY total_products DESC;

-- =====================================================
-- 16. اختبار البحث حسب لون الفئة
-- Search by Category Color Test
-- =====================================================

-- البحث عن منتجات في فئات بلون معين
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    price
FROM comprehensive_search_materialized
WHERE vendor_category_color = '#FF5722'
AND search_text ILIKE '%إلكترونيات%'
ORDER BY search_score DESC;

-- =====================================================
-- 17. اختبار البحث حسب أيقونة الفئة
-- Search by Category Icon Test
-- =====================================================

-- البحث عن منتجات في فئات بأيقونة معينة
SELECT 
    product_name,
    vendor_name,
    vendor_category_title,
    vendor_category_color,
    vendor_category_icon,
    price
FROM comprehensive_search_materialized
WHERE vendor_category_icon = 'phone'
AND search_text ILIKE '%هاتف%'
ORDER BY search_score DESC;

-- =====================================================
-- 18. اختبار البحث مع ترتيب الفئات
-- Search with Category Sorting Test
-- =====================================================

-- البحث مع ترتيب الفئات حسب الأولوية
SELECT 
    vendor_category_title,
    vendor_category_color,
    vendor_category_sort_order,
    COUNT(*) as product_count,
    AVG(price) as avg_price
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
GROUP BY vendor_category_title, vendor_category_color, vendor_category_sort_order
ORDER BY vendor_category_sort_order ASC, product_count DESC;

-- =====================================================
-- انتهاء أمثلة الاختبار المحدثة
-- End of updated test examples
-- =====================================================
