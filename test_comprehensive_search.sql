-- =====================================================
-- اختبار البحث الشامل
-- Test Comprehensive Search
-- =====================================================

-- 1. فحص البيانات الموجودة
SELECT 
    'Products' as table_name,
    COUNT(*) as total_records
FROM products 
WHERE is_deleted = false

UNION ALL

SELECT 
    'Vendors' as table_name,
    COUNT(*) as total_records
FROM vendors

UNION ALL

SELECT 
    'Vendor Categories' as table_name,
    COUNT(*) as total_records
FROM vendor_categories;

-- 2. فحص الـ view
SELECT COUNT(*) as total_in_view FROM comprehensive_search_view;

-- 3. اختبار البحث في عنوان المنتج
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    LEFT(search_text, 100) as search_preview
FROM comprehensive_search_view 
WHERE product_title ILIKE '%منتج%'
LIMIT 5;

-- 4. اختبار البحث في وصف المنتج
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    LEFT(search_text, 100) as search_preview
FROM comprehensive_search_view 
WHERE product_description ILIKE '%جودة%'
LIMIT 5;

-- 5. اختبار البحث في اسم المتجر
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    LEFT(search_text, 100) as search_preview
FROM comprehensive_search_view 
WHERE vendor_name ILIKE '%متجر%'
LIMIT 5;

-- 6. اختبار البحث في فئة المتجر
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    LEFT(search_text, 100) as search_preview
FROM comprehensive_search_view 
WHERE vendor_category_title ILIKE '%إلكترونيات%'
LIMIT 5;

-- 7. اختبار البحث الشامل في النص المدمج
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    search_score,
    LEFT(search_text, 150) as search_preview
FROM comprehensive_search_view 
WHERE search_text ILIKE '%منتج%'
ORDER BY search_score DESC
LIMIT 10;

-- 8. اختبار البحث المتقدم (OR query)
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    search_score,
    LEFT(search_text, 150) as search_preview
FROM comprehensive_search_view 
WHERE product_title ILIKE '%جوال%'
   OR product_description ILIKE '%جوال%'
   OR vendor_name ILIKE '%جوال%'
   OR vendor_category_title ILIKE '%جوال%'
   OR search_text ILIKE '%جوال%'
ORDER BY search_score DESC
LIMIT 10;

-- 9. اختبار الأداء
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM comprehensive_search_view 
WHERE search_text ILIKE '%منتج%'
ORDER BY search_score DESC
LIMIT 20;

-- 10. فحص الفهارس
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
ORDER BY tablename, indexname;

-- 11. عينة من البيانات مع نص البحث الكامل
SELECT 
    product_title,
    vendor_name,
    vendor_category_title,
    search_text,
    search_score
FROM comprehensive_search_view 
LIMIT 3;

-- 12. إحصائيات البحث
SELECT 
    'Total Products' as metric,
    COUNT(*) as value
FROM comprehensive_search_view

UNION ALL

SELECT 
    'Products with Vendors' as metric,
    COUNT(*) as value
FROM comprehensive_search_view
WHERE vendor_name IS NOT NULL

UNION ALL

SELECT 
    'Products with Categories' as metric,
    COUNT(*) as value
FROM comprehensive_search_view
WHERE vendor_category_title IS NOT NULL

UNION ALL

SELECT 
    'Featured Products' as metric,
    COUNT(*) as value
FROM comprehensive_search_view
WHERE is_feature = true

UNION ALL

SELECT 
    'Verified Vendors' as metric,
    COUNT(*) as value
FROM comprehensive_search_view
WHERE is_verified = true;

-- =====================================================
-- انتهاء الاختبار
-- End of test
-- =====================================================
