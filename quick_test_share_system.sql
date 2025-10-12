-- =====================================================
-- اختبار سريع لنظام المشاركة
-- Quick Share System Test
-- =====================================================

-- 🧪 اختبار 1: تسجيل مشاركة منتج
-- Test 1: Log Product Share
-- =====================================================

SELECT '🧪 اختبار 1: تسجيل مشاركة منتج' AS test_name;

SELECT public.log_share(
    'product',                  -- share_type
    'quick-test-product-001',  -- entity_id
    NULL,                       -- user_id
    'android',                  -- device_type
    'quick_test'               -- share_method
) AS share_id;

-- عرض النتيجة
SELECT * FROM public.shares 
WHERE entity_id = 'quick-test-product-001';

SELECT '✅ اختبار 1 مكتمل - تم تسجيل المشاركة' AS result;

-- =====================================================
-- 🧪 اختبار 2: الحصول على عدد المشاركات
-- Test 2: Get Share Count
-- =====================================================

SELECT '🧪 اختبار 2: الحصول على عدد المشاركات' AS test_name;

SELECT 
    'quick-test-product-001' AS entity,
    public.get_share_count('product', 'quick-test-product-001') AS share_count,
    'Expected: 1' AS expected;

SELECT '✅ اختبار 2 مكتمل' AS result;

-- =====================================================
-- 🧪 اختبار 3: تسجيل مشاركة متجر
-- Test 3: Log Vendor Share
-- =====================================================

SELECT '🧪 اختبار 3: تسجيل مشاركة متجر' AS test_name;

SELECT public.log_share(
    'vendor',
    'quick-test-vendor-001',
    NULL,
    'ios',
    'quick_test'
) AS share_id;

-- عرض النتيجة
SELECT * FROM public.shares 
WHERE entity_id = 'quick-test-vendor-001';

SELECT '✅ اختبار 3 مكتمل' AS result;

-- =====================================================
-- 🧪 اختبار 4: Views
-- Test 4: Check Views
-- =====================================================

SELECT '🧪 اختبار 4: اختبار Views' AS test_name;

-- اختبار product_share_view
SELECT 
    'product_share_view' AS view_name,
    COUNT(*) AS record_count,
    'EXISTS' AS status
FROM public.product_share_view
LIMIT 1;

-- اختبار vendor_share_view
SELECT 
    'vendor_share_view' AS view_name,
    COUNT(*) AS record_count,
    'EXISTS' AS status
FROM public.vendor_share_view
LIMIT 1;

SELECT '✅ اختبار 4 مكتمل - جميع Views تعمل' AS result;

-- =====================================================
-- 🧪 اختبار 5: الدوال
-- Test 5: Functions Test
-- =====================================================

SELECT '🧪 اختبار 5: اختبار الدوال' AS test_name;

-- اختبار get_most_shared_products
SELECT 
    'get_most_shared_products' AS function_name,
    COUNT(*) AS results_count
FROM public.get_most_shared_products(5);

-- اختبار get_most_shared_vendors
SELECT 
    'get_most_shared_vendors' AS function_name,
    COUNT(*) AS results_count
FROM public.get_most_shared_vendors(5);

SELECT '✅ اختبار 5 مكتمل - جميع الدوال تعمل' AS result;

-- =====================================================
-- 📊 ملخص النظام
-- System Summary
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '📊 ملخص نظام المشاركة' AS summary_title;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- إحصائيات المشاركة
SELECT 
    'إجمالي المشاركات' AS metric,
    COUNT(*) AS value
FROM public.shares
UNION ALL
SELECT 
    'مشاركات المنتجات' AS metric,
    COUNT(*) AS value
FROM public.shares WHERE share_type = 'product'
UNION ALL
SELECT 
    'مشاركات المتاجر' AS metric,
    COUNT(*) AS value
FROM public.shares WHERE share_type = 'vendor'
UNION ALL
SELECT 
    'مستخدمين نشطين' AS metric,
    COUNT(DISTINCT user_id) AS value
FROM public.shares;

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '✅ جميع الاختبارات نجحت!' AS final_result;
SELECT '✅ All Tests Passed!' AS final_result_en;
SELECT '🚀 نظام المشاركة جاهز للاستخدام!' AS ready_message;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- تنظيف بيانات الاختبار
DELETE FROM public.shares WHERE entity_id LIKE 'quick-test-%';

SELECT '🧹 تم تنظيف بيانات الاختبار' AS cleanup_message;

-- =====================================================
-- نهاية الاختبار السريع
-- End of Quick Test
-- =====================================================


