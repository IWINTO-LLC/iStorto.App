-- =====================================================
-- أمثلة عملية لاختبار البحث الشامل
-- Practical Examples for Testing Comprehensive Search
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
    major_category_name,
    price,
    stock_status,
    search_score,
    relevance_score
FROM search_comprehensive('هاتف', NULL, NULL, NULL, 20, 0)
ORDER BY relevance_score DESC, search_score DESC;

-- =====================================================
-- 6. اختبار البحث في فئات التخصص
-- Search in Specialization Categories Test
-- =====================================================

-- البحث عن منتجات في فئات التخصص الأساسي
SELECT 
    product_name,
    vendor_name,
    major_category_name,
    specialization_level,
    vendor_category_primary
FROM comprehensive_search_materialized
WHERE vendor_category_primary = true
AND search_text ILIKE '%هاتف%'
ORDER BY specialization_level DESC, search_score DESC;

-- =====================================================
-- 7. اختبار البحث حسب مستوى التخصص
-- Search by Specialization Level Test
-- =====================================================

-- البحث عن منتجات من تجار متخصصين (مستوى 4-5)
SELECT 
    product_name,
    vendor_name,
    major_category_name,
    specialization_level,
    search_score
FROM comprehensive_search_materialized
WHERE specialization_level >= 4
AND search_text ILIKE '%إلكترونيات%'
ORDER BY specialization_level DESC, search_score DESC;

-- =====================================================
-- 8. اختبار البحث حسب حالة التوفر
-- Search by Stock Status Test
-- =====================================================

-- البحث عن منتجات متوفرة
SELECT 
    product_name,
    vendor_name,
    major_category_name,
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
    major_category_name,
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
    MAX(specialization_level) as max_specialization
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%هاتف%'
GROUP BY vendor_name
ORDER BY product_count DESC;

-- تجميع النتائج حسب الفئة
SELECT 
    major_category_name,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    COUNT(DISTINCT vendor_id) as vendor_count
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
GROUP BY major_category_name
ORDER BY product_count DESC;

-- =====================================================
-- 10. اختبار البحث مع التصفية المتقدمة
-- Advanced Filtering Search Test
-- =====================================================

-- البحث مع تصفية متعددة
SELECT 
    product_name,
    vendor_name,
    major_category_name,
    price,
    stock_status,
    specialization_level,
    vendor_category_primary
FROM comprehensive_search_materialized
WHERE 
    search_text ILIKE '%هاتف%'
    AND stock_status = 'in_stock'
    AND specialization_level >= 3
    AND vendor_category_primary = true
ORDER BY search_score DESC, price ASC;

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
    major_category_name,
    price,
    stock_status
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%هاتف%'
ORDER BY price ASC, search_score DESC;

-- ترتيب حسب السعر (من الأعلى للأقل)
SELECT 
    product_name,
    vendor_name,
    major_category_name,
    price,
    stock_status
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%هاتف%'
ORDER BY price DESC, search_score DESC;

-- ترتيب حسب مستوى التخصص والسعر
SELECT 
    product_name,
    vendor_name,
    major_category_name,
    specialization_level,
    price,
    search_score
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
ORDER BY specialization_level DESC, price ASC, search_score DESC;

-- =====================================================
-- 13. اختبار البحث مع الإحصائيات التفصيلية
-- Detailed Statistics Search Test
-- =====================================================

-- إحصائيات البحث حسب الفئة
SELECT 
    major_category_name,
    COUNT(*) as total_products,
    COUNT(DISTINCT vendor_id) as total_vendors,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price,
    COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count,
    COUNT(CASE WHEN vendor_category_primary = true THEN 1 END) as primary_category_count
FROM comprehensive_search_materialized
WHERE search_text ILIKE '%إلكترونيات%'
GROUP BY major_category_name
ORDER BY total_products DESC;

-- =====================================================
-- 14. اختبار البحث مع النتائج المميزة
-- Featured Results Search Test
-- =====================================================

-- البحث عن المنتجات المميزة (فئات أساسية + تخصص عالي)
SELECT 
    product_name,
    vendor_name,
    major_category_name,
    specialization_level,
    vendor_category_primary,
    search_score,
    price
FROM comprehensive_search_materialized
WHERE 
    search_text ILIKE '%هاتف%'
    AND vendor_category_primary = true
    AND specialization_level >= 4
ORDER BY search_score DESC, specialization_level DESC;

-- =====================================================
-- 15. اختبار البحث مع التحليل المتقدم
-- Advanced Analytics Search Test
-- =====================================================

-- تحليل شامل للبحث
WITH search_analysis AS (
    SELECT 
        major_category_name,
        vendor_name,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        AVG(specialization_level) as avg_specialization,
        COUNT(CASE WHEN stock_status = 'in_stock' THEN 1 END) as in_stock_count
    FROM comprehensive_search_materialized
    WHERE search_text ILIKE '%هاتف%'
    GROUP BY major_category_name, vendor_name
)
SELECT 
    major_category_name,
    COUNT(DISTINCT vendor_name) as vendor_count,
    SUM(product_count) as total_products,
    AVG(avg_price) as category_avg_price,
    AVG(avg_specialization) as category_avg_specialization,
    SUM(in_stock_count) as total_in_stock
FROM search_analysis
GROUP BY major_category_name
ORDER BY total_products DESC;

-- =====================================================
-- انتهاء أمثلة الاختبار
-- End of test examples
-- =====================================================
