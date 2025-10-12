-- =====================================================
-- اختبارات نظام المشاركة
-- Share System Tests
-- =====================================================

-- تنظيف بيانات الاختبار السابقة
DELETE FROM public.shares WHERE entity_id LIKE 'test-%';

-- =====================================================
-- اختبار 1: تسجيل مشاركة منتج
-- Test 1: Log Product Share
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 1: تسجيل مشاركة منتج' AS test_name;
SELECT 'Test 1: Log Product Share' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- تسجيل مشاركة منتج
SELECT public.log_share(
    'product',                  -- share_type
    'test-product-001',        -- entity_id
    NULL,                      -- user_id (سيستخدم المستخدم الحالي)
    'android',                 -- device_type
    'share_plus'              -- share_method
) AS share_id_1;

SELECT public.log_share(
    'product',
    'test-product-001',
    NULL,
    'ios',
    'share_plus'
) AS share_id_2;

SELECT public.log_share(
    'product',
    'test-product-002',
    NULL,
    'android',
    'share_plus'
) AS share_id_3;

-- عرض النتيجة
SELECT * FROM public.shares 
WHERE entity_id LIKE 'test-product-%'
ORDER BY shared_at DESC;

SELECT '✅ اختبار 1 مكتمل' AS result;

-- =====================================================
-- اختبار 2: تسجيل مشاركة متجر
-- Test 2: Log Vendor Share
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 2: تسجيل مشاركة متجر' AS test_name;
SELECT 'Test 2: Log Vendor Share' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- تسجيل مشاركات متاجر
SELECT public.log_share(
    'vendor',
    'test-vendor-001',
    NULL,
    'android',
    'share_plus'
) AS share_id_1;

SELECT public.log_share(
    'vendor',
    'test-vendor-001',
    NULL,
    'ios',
    'share_plus'
) AS share_id_2;

SELECT public.log_share(
    'vendor',
    'test-vendor-002',
    NULL,
    'web',
    'share_plus'
) AS share_id_3;

-- عرض النتيجة
SELECT * FROM public.shares 
WHERE entity_id LIKE 'test-vendor-%'
ORDER BY shared_at DESC;

SELECT '✅ اختبار 2 مكتمل' AS result;

-- =====================================================
-- اختبار 3: الحصول على عدد المشاركات
-- Test 3: Get Share Count
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 3: عدد المشاركات' AS test_name;
SELECT 'Test 3: Get Share Count' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- عدد مشاركات test-product-001 (يجب أن يكون 2)
SELECT 
    'test-product-001' AS entity,
    public.get_share_count('product', 'test-product-001') AS share_count,
    'Expected: 2' AS expected;

-- عدد مشاركات test-vendor-001 (يجب أن يكون 2)
SELECT 
    'test-vendor-001' AS entity,
    public.get_share_count('vendor', 'test-vendor-001') AS share_count,
    'Expected: 2' AS expected;

-- عدد مشاركات منتج غير موجود (يجب أن يكون 0)
SELECT 
    'non-existing-product' AS entity,
    public.get_share_count('product', 'non-existing-product') AS share_count,
    'Expected: 0' AS expected;

SELECT '✅ اختبار 3 مكتمل' AS result;

-- =====================================================
-- اختبار 4: أكثر المنتجات مشاركة
-- Test 4: Most Shared Products
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 4: أكثر المنتجات مشاركة' AS test_name;
SELECT 'Test 4: Most Shared Products' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- الحصول على أكثر 5 منتجات مشاركة
SELECT * FROM public.get_most_shared_products(5);

SELECT '✅ اختبار 4 مكتمل' AS result;

-- =====================================================
-- اختبار 5: أكثر المتاجر مشاركة
-- Test 5: Most Shared Vendors
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 5: أكثر المتاجر مشاركة' AS test_name;
SELECT 'Test 5: Most Shared Vendors' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- الحصول على أكثر 5 متاجر مشاركة
SELECT * FROM public.get_most_shared_vendors(5);

SELECT '✅ اختبار 5 مكتمل' AS result;

-- =====================================================
-- اختبار 6: Trigger تحديث العداد
-- Test 6: Share Count Trigger
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 6: Trigger تحديث العداد' AS test_name;
SELECT 'Test 6: Share Count Trigger' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- إنشاء منتج اختبار مؤقت
INSERT INTO public.products (
    id, 
    title, 
    price, 
    vendor_id,
    share_count
) VALUES (
    'test-trigger-product',
    'منتج اختبار Trigger',
    99.99,
    (SELECT id FROM public.vendors LIMIT 1),
    0
)
ON CONFLICT (id) DO UPDATE SET share_count = 0;

-- عرض العداد قبل المشاركة
SELECT 
    'Before Share' AS status,
    id,
    title,
    share_count
FROM public.products 
WHERE id = 'test-trigger-product';

-- إضافة مشاركة
SELECT public.log_share(
    'product',
    'test-trigger-product',
    NULL,
    'test',
    'trigger_test'
);

-- عرض العداد بعد المشاركة (يجب أن يكون 1)
SELECT 
    'After Share' AS status,
    id,
    title,
    share_count,
    'Expected: 1' AS expected
FROM public.products 
WHERE id = 'test-trigger-product';

-- تنظيف
DELETE FROM public.products WHERE id = 'test-trigger-product';
DELETE FROM public.shares WHERE entity_id = 'test-trigger-product';

SELECT '✅ اختبار 6 مكتمل' AS result;

-- =====================================================
-- اختبار 7: Views المشاركة
-- Test 7: Share Views
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 7: Views المشاركة' AS test_name;
SELECT 'Test 7: Share Views' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- اختبار product_share_view
SELECT 
    'product_share_view' AS view_name,
    COUNT(*) AS record_count
FROM public.product_share_view
LIMIT 1;

-- اختبار vendor_share_view
SELECT 
    'vendor_share_view' AS view_name,
    COUNT(*) AS record_count
FROM public.vendor_share_view
LIMIT 1;

-- اختبار daily_share_stats
SELECT 
    'daily_share_stats' AS view_name,
    COUNT(*) AS record_count
FROM public.daily_share_stats
LIMIT 1;

-- اختبار top_shared_products
SELECT 
    'top_shared_products' AS view_name,
    COUNT(*) AS record_count
FROM public.top_shared_products
LIMIT 1;

-- اختبار top_shared_vendors
SELECT 
    'top_shared_vendors' AS view_name,
    COUNT(*) AS record_count
FROM public.top_shared_vendors
LIMIT 1;

SELECT '✅ اختبار 7 مكتمل' AS result;

-- =====================================================
-- اختبار 8: RLS Policies
-- Test 8: RLS Policies
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 8: RLS Policies' AS test_name;
SELECT 'Test 8: RLS Policies' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- عرض جميع Policies على جدول shares
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'shares'
ORDER BY policyname;

SELECT '✅ اختبار 8 مكتمل' AS result;

-- =====================================================
-- اختبار 9: إحصائيات عامة
-- Test 9: General Statistics
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 9: إحصائيات عامة' AS test_name;
SELECT 'Test 9: General Statistics' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- إحصائيات حسب نوع المشاركة
SELECT 
    share_type,
    COUNT(*) AS total_shares,
    COUNT(DISTINCT entity_id) AS unique_entities,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT device_type) AS device_types
FROM public.shares
GROUP BY share_type;

-- إحصائيات حسب نوع الجهاز
SELECT 
    device_type,
    COUNT(*) AS share_count,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM public.shares) * 100, 2) AS percentage
FROM public.shares
WHERE device_type IS NOT NULL
GROUP BY device_type
ORDER BY share_count DESC;

-- المشاركات خلال آخر 7 أيام
SELECT 
    DATE(shared_at) AS share_date,
    COUNT(*) AS shares_count
FROM public.shares
WHERE shared_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(shared_at)
ORDER BY share_date DESC;

SELECT '✅ اختبار 9 مكتمل' AS result;

-- =====================================================
-- اختبار 10: دالة التنظيف
-- Test 10: Cleanup Function
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '🧪 اختبار 10: دالة التنظيف' AS test_name;
SELECT 'Test 10: Cleanup Function' AS test_name_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- إضافة مشاركة قديمة للاختبار
INSERT INTO public.shares (
    share_type,
    entity_id,
    shared_at
) VALUES (
    'product',
    'test-old-share',
    NOW() - INTERVAL '400 days'
);

-- عد المشاركات القديمة
SELECT 
    'Before Cleanup' AS status,
    COUNT(*) AS old_shares_count
FROM public.shares
WHERE shared_at < NOW() - INTERVAL '365 days';

-- تنظيف المشاركات الأقدم من سنة
SELECT 
    'Deleted Count' AS status,
    public.cleanup_old_shares(365) AS deleted_count;

-- عد المشاركات بعد التنظيف
SELECT 
    'After Cleanup' AS status,
    COUNT(*) AS old_shares_count,
    'Expected: 0' AS expected
FROM public.shares
WHERE shared_at < NOW() - INTERVAL '365 days';

SELECT '✅ اختبار 10 مكتمل' AS result;

-- =====================================================
-- ملخص نهائي
-- Final Summary
-- =====================================================

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '📊 ملخص الاختبارات النهائي' AS summary_title;
SELECT 'Final Test Summary' AS summary_title_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- عرض ملخص شامل
SELECT 
    'Tables' AS component,
    COUNT(*) AS count
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name IN ('shares')
UNION ALL
SELECT 
    'Functions' AS component,
    COUNT(*) AS count
FROM information_schema.routines
WHERE routine_schema = 'public' 
  AND routine_name IN (
      'log_share',
      'get_share_count',
      'get_most_shared_products',
      'get_most_shared_vendors',
      'update_share_count',
      'cleanup_old_shares'
  )
UNION ALL
SELECT 
    'Views' AS component,
    COUNT(*) AS count
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN (
      'product_share_view',
      'vendor_share_view',
      'daily_share_stats',
      'top_shared_products',
      'top_shared_vendors'
  )
UNION ALL
SELECT 
    'Triggers' AS component,
    COUNT(*) AS count
FROM information_schema.triggers
WHERE trigger_schema = 'public' AND trigger_name = 'trigger_update_share_count'
UNION ALL
SELECT 
    'Policies' AS component,
    COUNT(*) AS count
FROM pg_policies
WHERE tablename = 'shares';

-- عرض إحصائيات البيانات
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT 
    'Total Shares' AS metric,
    COUNT(*) AS value
FROM public.shares
UNION ALL
SELECT 
    'Product Shares' AS metric,
    COUNT(*) AS value
FROM public.shares WHERE share_type = 'product'
UNION ALL
SELECT 
    'Vendor Shares' AS metric,
    COUNT(*) AS value
FROM public.shares WHERE share_type = 'vendor'
UNION ALL
SELECT 
    'Unique Users' AS metric,
    COUNT(DISTINCT user_id) AS value
FROM public.shares;

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '✅ جميع الاختبارات مكتملة!' AS final_result;
SELECT '✅ All Tests Complete!' AS final_result_en;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- تنظيف بيانات الاختبار
DELETE FROM public.shares WHERE entity_id LIKE 'test-%';

SELECT '🧹 تم تنظيف بيانات الاختبار' AS cleanup_message;
SELECT '🧹 Test Data Cleaned Up' AS cleanup_message_en;

-- =====================================================
-- نهاية الاختبارات
-- End of Tests
-- =====================================================

